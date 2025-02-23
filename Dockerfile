# Use latest secure Maven with Java 17
FROM maven:3.9.5-eclipse-temurin-17 AS build
WORKDIR /app

# Copy only essential files
COPY pom.xml .
RUN mvn dependency:go-offline --batch-mode

COPY src/ ./src
RUN mvn package

# Use lightweight JRE (Alpine)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

ARG VAR
ENV VAR=${VAR}

# Rename the JAR file dynamically
COPY --from=build /app/target/*.jar /app/app.jar

# Rename the jar file inside the container
RUN mv /app/app.jar /app/app.jar${VAR}

CMD ["bash", "-c", "java -jar /app/app.jar${VAR}"]

