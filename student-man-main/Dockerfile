# Base officielle Eclipse Temurin (remplace openjdk:17-jdk-slim)
FROM eclipse-temurin:17-jdk


# Crée un volume temporaire (utile pour Spring Boot)
VOLUME /tmp

# Copie le JAR construit par Maven
COPY target/*.jar app.jar

# Commande pour lancer l'application
ENTRYPOINT ["java","-jar","/app.jar"]
