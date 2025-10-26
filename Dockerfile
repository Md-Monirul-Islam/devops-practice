# Stage 1: Build the application JAR (java application Runtime) using Maven
FROM maven:3.8.3-openjdk-17 AS build

WORKDIR /app

COPY . .

# create jar file
RUN mvn clean package -DskipTests=true

#stage 2: Create the final image with OpenJDK
FROM openjdk:17-jdk-alpine

WORKDIR /app

COPY --from=build /app/target/*.jar /app/expenseapp/app.jar

ENTRYPOINT ["java", "-jar", "/app/expenseapp/app.jar"]
