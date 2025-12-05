FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Copie du JAR (exemple Maven)
COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
