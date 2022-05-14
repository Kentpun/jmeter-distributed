variable "friendly_name_prefix" {
  type        = string
  description = "(Required) Friendly name prefix used for tagging and naming AWS resources."
  default     = "jmeter"
}

variable "friendly_name_suffix" {
  type        = string
  description = "(Required) Friendly name suffix used for tagging and naming AWS resources. (i.e. env)"
  default     = "dev"
}

variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
  default     = { "service" = "jmeter" }
}

variable "kubernetes_version" {
  description = "The target version of kubernetes"
  type        = string
  default = "1.21"
}

variable "node_groups" {
  description = "Node groups definition"
  default     = []
}

variable "managed_node_groups" {
  description = "Amazon managed node groups definition"
  default     = [ {
    name          = "eks-node-group"
    min_size      = 1
    max_size      = 3
    desired_size  = 3
    instance_type = "t3.medium"
  }]
}

variable "fargate_profiles" {
  description = "Amazon Fargate for EKS profiles"
  default     = [  {
    name      = "jmeter"
    namespace = "jmeter"
    labels ={ env="fargate"}
  }]
}

variable "network_private_subnets" {
    type = list(string)
    default = ["subnet-02cb263f9d742a1ff", "subnet-024e45a2625804a59"]
}
