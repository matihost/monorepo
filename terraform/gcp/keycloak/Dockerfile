FROM quay.io/keycloak/keycloak:latest AS builder

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_FEATURES=token-exchange
ENV KC_DB=postgres

# This is needed in order to use com.google.cloud.sql.postgres.SocketFactory
# https://github.com/GoogleCloudPlatform/cloud-sql-jdbc-socket-factory/blob/main/docs/jdbc-postgres.md
ENV KC_DB_KIND=postgres
ENV KC_DB_DIALECT=org.hibernate.dialect.PostgreSQL10Dialect
ENV KC_DB_DRIVER=org.postgresql.Driver
COPY target/postgres-socket-factory-jar-with-dependencies.jar /opt/keycloak/providers/

# Install custom providers
COPY target/keycloak-metrics-spi.jar /opt/keycloak/providers/

RUN /opt/keycloak/bin/kc.sh build --transaction-xa-enabled=false

FROM quay.io/keycloak/keycloak:latest

COPY target/postgres-socket-factory-jar-with-dependencies.jar /opt/keycloak/providers/

COPY --from=builder /opt/keycloak /opt/keycloak
WORKDIR /opt/keycloak

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_FEATURES=token-exchange

ENV KEYCLOAK_ADMIN=keycloak
ENV KEYCLOAK_ADMIN_PASSWORD=keycloak

ENV KC_DB=postgres
ENV KC_DB_KIND=postgres
ENV KC_DB_DIALECT=org.hibernate.dialect.PostgreSQLDialect
ENV KC_DB_DRIVER=org.postgresql.Driver
ENV KC_TRANSACTION_XA_ENABLED=false

# change these values to point to a running postgres instance
ENV KC_DB_URL="jdbc:postgresql:///<DATABASE_NAME>?cloudSqlInstance=<INSTANCE_CONNECTION_NAME>&socketFactory=com.google.cloud.sql.postgres.SocketFactory"
ENV KC_DB_USERNAME=keycloak
ENV KC_DB_PASSWORD=keycloak


# See https://www.keycloak.org/server/hostname
# for current flags Keycloak uses for exposure via proxy
ENV KC_HTTP_ENABLED=true
ENV KC_HTTP_PORT=8080


# The previous optimized build will be overridden with the following build options:
# - db-dialect=org.hibernate.dialect.PostgreSQL10Dialect > db-dialect=org.hibernate.dialect.PostgreSQLDialect
# To avoid that, run the 'build' command again and then start the optimized server instance using the '--optimized' flag.
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start"]
