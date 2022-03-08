ARG JAR_FILE
FROM eclipse-temurin:17 as jreBuilder
# build JRE with only modules app depens on
# + jfr and jcmd tooling (jcmd,jps,jmap,jstack etc.) ~ adds 6 MiB to image size
RUN jlink \
        --add-modules java.base,java.logging,java.naming,java.net.http,java.desktop,jdk.jcmd,jdk.jfr,jdk.management.jfr \
        --verbose \
        --strip-debug \
        --compress 2 \
        --no-header-files \
        --no-man-pages \
        --output /jre

# distrolless with only libs java needs, nonroot and shell included
FROM gcr.io/distroless/java:base-debug-nonroot
ARG JAR_FILE

COPY --from=jreBuilder /jre /usr/lib/jre
ENV PATH="/usr/lib/jre/bin:${PATH}"
ENTRYPOINT ["/usr/lib/jre/bin/java", "-jar", "./app.jar"]
COPY ${JAR_FILE} ./app.jar
