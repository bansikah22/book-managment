FROM maven:3.9.4-eclipse-temurin-17 AS build

WORKDIR /app

#copy files
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src ./src
COPY .env .env

#Grant permissions
RUN chmod +x mvnw && ./mvnw clean package -DskipTests

#Multipi stage build
FROM openjdk:17-slim

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar
COPY .env .env

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "app.jar"]