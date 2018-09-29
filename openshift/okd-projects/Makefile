login:
	oc login https://master.matihost:8443 -u admin

cluster-status:
	@oc status -v --all-namespaces
	@echo "Pods with issues: `oc get po --all-namespaces --no-headers  | grep -q -v Running`"

.PHONY: login cluster-status
