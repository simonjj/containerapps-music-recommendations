# Stage 1: Build with Maven
FROM maven:3.9.6-sapmachine-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
COPY frontend ./frontend
#RUN find /app -type f
RUN mvn clean package -e -Pproduction -Dvaadin.force.production.build=true -Dvaadin.frontend.hotdeploy=true
#RUN mvn clean package -e -Pproduction -Dvaadin.force.production.build=true -Dvaadin.frontend.hotdeploy=true
#RUN find /app -type f

# Stage 2: Create the Docker image 
FROM sapmachine:21.0.2-jre-headless-ubuntu
COPY --from=build /app/target/music-frontend-1.0.jar /usr/src/myapp/music-frontend-1.0.jar
EXPOSE 8080
CMD ["java", "-jar", "/usr/src/myapp/music-frontend-1.0.jar"]
