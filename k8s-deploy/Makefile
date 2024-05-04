KUSTOMIZE = /usr/bin/env kustomize
KUBECTL = /usr/bin/env kubectl
MINIKUBE = /usr/bin/env minikube
working_dir = `pwd`
NAMESPACE = jmeter

minikube:
	$(MINIKUBE) start \
	--kubernetes-version=v1.29.0 \
	--vm-driver=hyperkit \
	--cpus=4 \
	--memory=16g \
	--bootstrapper=kubeadm \
	--extra-config=kubelet.authentication-token-webhook=true \
	--extra-config=kubelet.authorization-mode=Webhook \
	--extra-config=scheduler.address=0.0.0.0 \
	--extra-config=controller-manager.address=0.0.0.0
	minikube addons enable ingress

	minikube addons enable default-storageclass
	minikube addons enable storage-provisioner
	minikube addons enable metrics-server

deploy:
	$(KUSTOMIZE) build namespace | $(KUBECTL) apply -f -
	$(KUSTOMIZE) build deployments | $(KUBECTL) apply -f -
	$(KUSTOMIZE) build services | $(KUBECTL) apply -f -
	$(KUSTOMIZE) build ingress | $(KUBECTL) apply -f -

	# $(KUSTOMIZE) build jobs | $(KUBECTL) apply -f -


influxdb-local:
	# For InfluxDB 2.x only
	$(KUBECTL) port-forward service/jmeter-influxdb 8086:8086 -n $(NAMESPACE)

grafana-local:
	$(KUBECTL) port-forward service/grafana 3000:3000 -n $(NAMESPACE)

delete:
	$(KUBECTL) delete -f services/jmeter-master-service.yaml
	$(KUBECTL) delete -f services/jmeter-slave-service.yaml
	$(KUBECTL) delete -f deployments/jmeter-master.yaml
	$(KUBECTL) delete -f deployments/jmeter-slave.yaml
	$(KUBECTL) delete -f namespace/jmeter-namespace.yaml
