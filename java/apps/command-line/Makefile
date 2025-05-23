BASE := quay.io/matihost/commandline
TAG := latest

run: ## run command-line
	mvn -am spring-boot:run

build: ## build
	mvn -am clean package

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	DEBUG_FLAG := -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005
endif

JMX := false
ifeq ($(strip $(JMX)),true)
	JMX_FLAG := -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.local.port=9998 -Dcom.sun.management.jmxremote.rmi.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false
endif

CURRENCY := USD

.EXPORT_ALL_VARIABLES:
BUILDKIT_PROGRESS=plain


run-jar: ## run built jar; usage: make run-jar [CURRENCY=USD] [DEBUG=false] [JMX=false]
	java -XshowSettings:* -XX:+PrintFlagsFinal -XX:NativeMemoryTracking=summary -Xlog:async -Xlog:gc*=debug,gc+ergo*=trace,gc+age*=trace,safepoint*:file=/tmp/command-line.gc.log:level,tags,utctime,uptime,pid:filecount=5,filesize=100m \
		$(JMX_FLAG) $(DEBUG_FLAG)\
		-XX:OnOutOfMemoryError='kill -9 %p' -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp \
		-XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+UseNUMA -XX:+PreserveFramePointer \
		-Xms128m -Xmx128m \
		-XX:ThreadStackSize=1024 -XX:MaxDirectMemorySize=3G -XX:MaxMetaspaceSize=64m -XX:ReservedCodeCacheSize=32m -XX:CompressedClassSpaceSize=32m\
		-jar target/command-line-*.jar --currency=$(CURRENCY)

build-image: build ## build docker image
	docker build --load --build-arg JAR_FILE=target/*.jar -t $(BASE):$(TAG) .

run-container: ## run app from docker
	docker run -it --rm $(BASE):${TAG}

push: ## push image with tag to quay.io repository (assume docker login quay.io has been perfomed)
	docker push $(BASE):$(TAG)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build show-dependencies-updates show-dependency-tree show-effective-pom show-plugins-updates
