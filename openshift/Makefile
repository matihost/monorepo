RANGE = $(shell seq 1 3)

login:
	oc login https://master.matihost:8443 -u admin

cluster-status:
	@oc status -v --all-namespaces
	@echo "Pods with issues: `oc get po --all-namespaces --no-headers  | grep -q -v Running`"

add-pvs: 
	@$(foreach i, $(RANGE) , oc process -f pv-template.yaml --local -o yaml COUNTER=$(i) |oc apply -f - -n test ;)
	@oc get pv

.PHONY: add-pvs
