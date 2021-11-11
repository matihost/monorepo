ARG JAR_FILE
FROM eclipse-temurin:17 as jreBuilder
RUN jlink \
        --add-modules java.base,java.xml,java.net.http,java.desktop \
        --verbose \
        --strip-debug \
        --compress 2 \
        --no-header-files \
        --no-man-pages \
        --output /jre

FROM gcr.io/distroless/java-debian10:base
ARG JAR_FILE

COPY --from=jreBuilder /jre /usr/lib/jre
ENTRYPOINT ["/usr/lib/jre/bin/java", "-jar", "./app.jar"]
COPY ${JAR_FILE} ./app.jar
