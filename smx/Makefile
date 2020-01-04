start: run
run: ensure-java8-in-use ## run ServiceMix in backgroud
	./apache-servicemix-7.0.1/bin/start

status: ensure-java8-in-use ## check whether ServiceMix is run
	./apache-servicemix-7.0.1/bin/status

connect: ## connect to ServiceMix shell, user: smx/smx
	@ssh -p 8101 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null smx@localhost

stop: ensure-java8-in-use ## stop ServiceMix in backgroud
	./apache-servicemix-7.0.1/bin/stop

download-servicemix: ## download ServiceMix
	rm -rf apache-servicemix*
	curl -LOs https://repo.maven.apache.org/maven2/org/apache/servicemix/apache-servicemix/7.0.1/apache-servicemix-7.0.1.zip
	unzip -q apache-servicemix-7.0.1.zip
	rm -rf apache-servicemix-7.0.1.zip

download-java: ## download OpenJDK 8 and 11 and switch default to Java 8
	sudo apt install openjdk-8-jdk
	sudo apt install openjdk-8-source
	sudo apt install openjdk-11-jdk
	sudo apt install openjdk-11-source
	bash -i -c "\
		sdk i java 8-openjdk /usr/lib/jvm/java-8-openjdk-amd64; \
		sdk i java 11-openjdk /usr/lib/jvm/java-11-openjdk-amd64; \
		sdk d java 8-openjdk"

ensure-java8-in-use:
	bash -i -c "sdk d java 8-openjdk"

ensure-java11-in-use:
	bash -i -c "sdk d java 11-openjdk"

download-dependencies: download-java download-servicemix ## download Java and ServiceMix dependencies

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build show-dependencies-updates show-dependency-tree show-effective-pom show-plugins-updates