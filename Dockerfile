FROM eclipse-temurin:21-jdk-jammy

# Dossier de travail
WORKDIR /app

# Copier le fichier WAR généré par Maven
COPY target/*.war app.war
# Port exposé par l'application
EXPOSE 8080
# Lancer l'application
CMD ["java", "-jar", "app.war"]

