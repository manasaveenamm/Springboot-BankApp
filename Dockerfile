# Stage 1: Build environment (Matches your project compilation)
FROM maven:3.8.5-openjdk-17 AS builder
LABEL maintainer="manasa"
WORKDIR /app

# Copy the source code files safely
COPY pom.xml .
COPY src ./src

# Compile and package the application artifact
RUN mvn clean package -DskipTests

# Stage 2: Clean production runtime deployment environment
FROM eclipse-temurin:17-jre-alpine AS deployer
WORKDIR /opt/tomcat/webapps/

# Copy the built war file from Stage 1 into the runtime container
COPY --from=builder /app/target/banking-portal.war ./ROOT.war

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "ROOT.war"]
