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


# asciidoctor plus diagram and pdf extensions
sudo apt install ruby
sudo gem install prawn asciidoctor asciidoctor-diagram rouge --user-install
sudo gem install asciidoctor-pdf --pre --user-install

# install mathematical and asciidoctor-mathematical
sudo apt-get -qq -y install bison flex libffi-dev libxml2-dev libgdk-pixbuf2.0-dev libcairo2-dev libpango1.0-dev fonts-lyx cmake ruby-dev
sudo gem install mathematical --user-install
sudo gem install asciidoctor-mathematical --user-install
```

## Usage

```bash
# build
make build

# run application for ProblemX 
make Problem4
```