# [Project Euler](http://projecteuler.net/)  ::  Algorithms

Project Euler algorithms [description](algorithms.md).

## Prerequisites

```bash
# Ubuntu JDK 11
sudo apt install openjdk-11-jdk
sudo apt install openjdk-11-source

# maven (via sdkman)
curl -s "https://get.sdkman.io" | bash
source "/home/mati/.sdkman/bin/sdkman-init.sh"

sdk i maven
```

## Usage

```bash
# build
mvn clean install

# run
java -cp target/project-euler-1.0.0-SNAPSHOT.jar org.matihost.algorithms.euler.Problem1
```