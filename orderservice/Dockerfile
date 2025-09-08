# Use a lightweight Java image
FROM eclipse-temurin:21-jdk-alpine

# Copy the built jar
COPY target/*.jar app.jar

# Run the app
ENTRYPOINT ["java", "-jar", "/app.jar"]
