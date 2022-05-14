provider "aws" {
  region = "ap-southeast-1"
  profile = "dd_aws"

  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
}

module "eks" {
  source              = "Young-ook/eks/aws"
  name                = "${var.friendly_name_prefix}-eks-${var.friendly_name_suffix}"
  tags                = var.common_tags
  subnets             = var.network_private_subnets
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.managed_node_groups
  node_groups         = var.node_groups
}

data "aws_partition" "current" {}
data "aws_iam_policy" "efs_policy" {
  arn = format("arn:%s:iam::aws:policy/AmazonElasticFileSystemFullAccess", data.aws_partition.current.partition)
}


data "aws_iam_role" "node_group" {
  name = "${var.friendly_name_prefix}-eks-${var.friendly_name_suffix}-ng"
   depends_on = [
    module.eks
  ]
}

resource "aws_iam_role_policy_attachment" "efs-ng-attach" {
  role       = data.aws_iam_role.node_group.name
  policy_arn = data.aws_iam_policy.efs_policy.arn
}
data "aws_iam_role" "cp" {
  name = "${var.friendly_name_prefix}-eks-${var.friendly_name_suffix}-cp"
   depends_on = [
    module.eks
  ]
}

resource "aws_iam_role_policy_attachment" "efs-cp-attach" {
  role       = data.aws_iam_role.cp.name
  policy_arn = data.aws_iam_policy.efs_policy.arn
}


module "irsa" {
  source  = "Young-ook/eks/aws//modules/iam-role-for-serviceaccount"

  namespace      = "kube-system"
  serviceaccount = "efs-csi-controller-sa"
  oidc_url       = module.eks.oidc.url
  oidc_arn       = module.eks.oidc.arn
  policy_arns    = [data.aws_iam_policy.efs_policy.arn]
  tags           = var.common_tags
}

module "irsa2" {
  source  = "Young-ook/eks/aws//modules/iam-role-for-serviceaccount"

  namespace      = "kube-system"
  serviceaccount = "efs-csi-node-sa"
  oidc_url       = module.eks.oidc.url
  oidc_arn       = module.eks.oidc.arn
  policy_arns    = [data.aws_iam_policy.efs_policy.arn]
  tags           = var.common_tags
}

data "aws_caller_identity" "current" {}


resource "kubernetes_service_account" "efs-csi-node-sa" {
  metadata {
    name = "efs-csi-node-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa2.arn
    }
  }
  secret {
    name = "${kubernetes_secret.efs-csi-node-sa.metadata.0.name}"
  }
}

resource "kubernetes_secret" "efs-csi-node-sa" {
  metadata {
    name = "efs-csi-node-sa"
  }
}


resource "kubernetes_service_account" "efs-csi-controller-sa" {
  metadata {
    name = "efs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa.arn
    }
  }
  secret {
    name = "${kubernetes_secret.efs-csi-controller-sa.metadata.0.name}"
  }
}

resource "kubernetes_secret" "efs-csi-controller-sa" {
  metadata {
    name = "efs-csi-controller-sa"
  }
}

data "aws_eks_cluster" "eks" {
  name       = "${var.friendly_name_prefix}-eks-${var.friendly_name_suffix}"
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name       = "${var.friendly_name_prefix}-eks-${var.friendly_name_suffix}"
  depends_on = [module.eks]
}


provider "kubectl" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token

  config_path    = "~/.kube/config"
  config_context = data.aws_eks_cluster.eks.arn
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token

  config_path    = "~/.kube/config"
  config_context = data.aws_eks_cluster.eks.arn
}
provider "helm" {
  debug = true
  # kubernetes {
  #   config_path = "~/.kube/config"
  # }
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
    config_path            = "~/.kube/config"
    config_context         = data.aws_eks_cluster.eks.arn
  }

}
resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "nginx-ingress"
  create_namespace = true
  depends_on = [
    module.eks
  ]
}

resource "helm_release" "cert_manager" {

  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v1.2.0"
  set {
    name  = "installCRDs"
    value = true
  }
  depends_on = [
    module.eks
  ]
}

resource "helm_release" "le_ssl_cert" {
  name  = "lets-encrypt-cert"
  chart = "./charts/lets-encrypt-cert"

  set {
    name  = "certificate.dnsNames[0]"
    value = "jmeter.dttdev.com.hk"
  }
  set {
    name  = "clusterIssuer.email"
    value = "kenpun@deloitte.com.hk"
  }
  set {
    name  = "clusterIssuer.namespace"
    value = "jmeter"
  }
  set {
    name  = "certificate.namespace"
    value = "jmeter"
  }
}

