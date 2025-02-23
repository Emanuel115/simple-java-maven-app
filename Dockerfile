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

COPY --from=build /app/target/*.jar app.jar
CMD ["java", "-jar", "app.jar"]
