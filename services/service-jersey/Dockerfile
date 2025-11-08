# Dockerfile for JAX-RS (Jersey) Service
FROM maven:3.9.5-eclipse-temurin-17-alpine AS build

WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Runtime stage
FROM jetty:9-jre17-alpine

# Switch to root to install packages
USER root

# Install wget for downloading JMX Exporter
RUN apk add --no-cache wget

# Download JMX Prometheus Exporter
RUN wget -O /opt/jmx_prometheus_javaagent.jar \
    https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar

# Copy JMX Exporter config
COPY jmx-exporter-config.yaml /opt/jmx-exporter-config.yaml

# Copy the WAR file from build stage
COPY --from=build /app/target/service-jersey.war /var/lib/jetty/webapps/ROOT.war

# Switch back to jetty user
USER jetty

# Expose ports (8080 for app, 9090 for JMX metrics)
EXPOSE 8080 9090

# Start Jetty with JMX Exporter
CMD ["java", "-javaagent:/opt/jmx_prometheus_javaagent.jar=9090:/opt/jmx-exporter-config.yaml", "-jar", "/usr/local/jetty/start.jar"]
