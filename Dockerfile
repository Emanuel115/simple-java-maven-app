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

# Accept build argument and set it as an environment variable
ARG VAR
ENV VAR=${VAR}

# Copy the JAR file before switching user
COPY --from=build /app/target/*.jar /app/app.jar

# Rename the JAR file with the build argument
RUN mv /app/app.jar /app/app-${VAR}.jar

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Change ownership to the new user
RUN chown -R appuser:appgroup /app

USER appuser

# Run the renamed JAR file
CMD sh -c "java -jar /app/app-1.0.${VAR}.jar"

