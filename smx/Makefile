start: run
run: ## run ServiceMix in backgroud
	@sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/bin/java && \
	export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 && \
	./apache-servicemix-7.0.1/bin/start

status: ## check whether ServiceMix is run
	@-sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/bin/java && \
	export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 && \
	./apache-servicemix-7.0.1/bin/status

connect: ## connect to ServiceMix shell
	@ssh -p 8101 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null smx@localhost

stop: ## stop ServiceMix in backgroud
	@sudo update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/bin/java && \
	export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 && \
	./apache-servicemix-7.0.1/bin/stop

download-servicemix: ## download ServiceMix
	rm -rf apache-servicemix*
	curl -LOs http://repo1.maven.apache.org/maven2/org/apache/servicemix/apache-servicemix/7.0.1/apache-servicemix-7.0.1.zip
	unzip apache-servicemix-7.0.1.zip
	rm -rf apache-servicemix-7.0.1.zip

download-java8: ## download OpenJDK 8
	sudo apt install openjdk-8-jdk
	sudo apt install openjdk-8-source
	sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-openjdk-amd64/bin/java 666

download-dependencies: download-java8 download-servicemix ## download Java 8 and ServiceMix dependencies

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build show-dependencies-updates show-dependency-tree show-effective-pom show-plugins-updates