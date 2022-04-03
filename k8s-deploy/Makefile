KUSTOMIZE = /usr/bin/env kustomize
KUBECTL = /usr/bin/env kubectl

deploy:
	$(KUSTOMIZE) build . | $(KUBECTL) apply -f -
	$(KUSTOMIZE) build deployments | $(KUBECTL) apply -f -
	$(KUSTOMIZE) build services | $(KUBECTL) apply -f -

delete:
	$(KUBECTL) delete -f services/jmeter-master-service.yaml
	$(KUBECTL) delete -f services/jmeter-slave-service.yaml
	$(KUBECTL) delete -f deployments/jmeter-master.yaml
	$(KUBECTL) delete -f deployments/jmeter-slave.yaml
	$(KUBECTL) delete -f jmeter-namespace.yaml
