# Terraform :: RDS deployment

Terraform scripts deploy Aurora Serverless v2 PostgreSQL database

In particular it creates:

- RDS cluster

- single RDS write instance attached to cluster

- (TODO) add option to add read instance

The RDS is accessible from within provided VPC.

This setup use AWS resources eligible to AWS Free Tier __only__ when possible.

## Prerequisites

- Logged to AWS Account

```bash
aws configure
```

- Latest Terraform installed

- The scripts assume that [aws-network-setup](../aws-network-setup) is already deployed (aka private networking is present).

## Usage

```bash

# deploy RDSs
make run MODE=apply [ENV=dev] [PARTITION=aws]

# get postgress password for RDS clusters
make get-postgres-pass [ENV=dev] [PARTITION=aws]

# get psql command to connect to DBs (from within VPC)
make get-postgres-cmd [ENV=dev] [PARTITION=aws]


# show Terraform state
make show-state
```


```bash
/usr/share/dbeaver-ce/jre/bin/java \
-XX:+IgnoreUnrecognizedVMOptions  \
-Dosgi.requiredJavaVersion=21 \
-Dfile.encoding=UTF-8 \
--add-modules=ALL-DEFAULT \
--add-opens=java.base/java.io=ALL-UNNAMED \
--add-opens=java.base/java.lang=ALL-UNNAMED \
--add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
--add-opens=java.base/java.net=ALL-UNNAMED \
--add-opens=java.base/java.nio=ALL-UNNAMED \
--add-opens=java.base/java.nio.charset=ALL-UNNAMED \
--add-opens=java.base/java.text=ALL-UNNAMED \
--add-opens=java.base/java.time=ALL-UNNAMED \
--add-opens=java.base/java.util=ALL-UNNAMED \
--add-opens=java.base/java.util.concurrent=ALL-UNNAMED \
--add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.vm=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.misc=ALL-UNNAMED \
--add-opens=java.base/sun.nio.ch=ALL-UNNAMED \
--add-opens=java.base/sun.nio.fs=ALL-UNNAMED \
--add-opens=java.base/sun.security.ssl=ALL-UNNAMED \
--add-opens=java.base/sun.security.action=ALL-UNNAMED \
--add-opens=java.base/sun.security.util=ALL-UNNAMED \
--add-opens=java.security.jgss/sun.security.jgss=ALL-UNNAMED \
--add-opens=java.security.jgss/sun.security.krb5=ALL-UNNAMED \
--add-opens=java.desktop/java.awt=ALL-UNNAMED \
--add-opens=java.desktop/java.awt.peer=ALL-UNNAMED \
--add-opens=java.sql/java.sql=ALL-UNNAMED \
-Xms64m \
-Xmx1024m \
-Ddbeaver.distribution.type=deb \
-jar /usr/share/dbeaver-ce//plugins/org.jkiss.dbeaver.launcher_1.0.46.202602021734.jar \
-os linux \
-ws gtk \
-arch x86_64 \
-showsplash \
-launcher /usr/share/dbeaver-ce/dbeaver \
-name Dbeaver \
--launcher.library /usr/share/dbeaver-ce//plugins/org.eclipse.equinox.launcher.gtk.linux.x86_64_1.2.1500.v20250801-0854/eclipse_11916.so \
-startup /usr/share/dbeaver-ce//plugins/org.jkiss.dbeaver.launcher_1.0.46.202602021734.jar \
--launcher.overrideVmargs \
-exitdata 1000c \
-vm /usr/share/dbeaver-ce/jre/bin/java \
-vmargs \
-XX:+IgnoreUnrecognizedVMOptions \
-Dosgi.requiredJavaVersion=21 \
-Dfile.encoding=UTF-8 \
--add-modules=ALL-DEFAULT \
--add-opens=java.base/java.io=ALL-UNNAMED \
--add-opens=java.base/java.lang=ALL-UNNAMED \
--add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
--add-opens=java.base/java.net=ALL-UNNAMED \
--add-opens=java.base/java.nio=ALL-UNNAMED \
--add-opens=java.base/java.nio.charset=ALL-UNNAMED \
--add-opens=java.base/java.text=ALL-UNNAMED \
--add-opens=java.base/java.time=ALL-UNNAMED \
--add-opens=java.base/java.util=ALL-UNNAMED \
--add-opens=java.base/java.util.concurrent=ALL-UNNAMED \
--add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.vm=ALL-UNNAMED \
--add-opens=java.base/jdk.internal.misc=ALL-UNNAMED \
--add-opens=java.base/sun.nio.ch=ALL-UNNAMED \
--add-opens=java.base/sun.nio.fs=ALL-UNNAMED \
--add-opens=java.base/sun.security.ssl=ALL-UNNAMED \
--add-opens=java.base/sun.security.action=ALL-UNNAMED \
--add-opens=java.base/sun.security.util=ALL-UNNAMED \
--add-opens=java.security.jgss/sun.security.jgss=ALL-UNNAMED \
--add-opens=java.security.jgss/sun.security.krb5=ALL-UNNAMED \
--add-opens=java.desktop/java.awt=ALL-UNNAMED \
--add-opens=java.desktop/java.awt.peer=ALL-UNNAMED \
--add-opens=java.sql/java.sql=ALL-UNNAMED \
-Xms64m \
-Xmx1024m \
-Ddbeaver.distribution.type=deb \
-jar /usr/share/dbeaver-ce//plugins/org.jkiss.dbeaver.launcher_1.0.46.202602021734.jar
```
