FROM openjdk:21
COPY ./target/full-music-frontend-1.0.jar /usr/src/myapp/full-music-frontend-1.0.jar
#RUN mkdir /usr/src/myapp
#WORKDIR /usr/src/myapp
#RUN javac full-music-frontend-1.0.jar
EXPOSE 8080
CMD ["java", "-jar", "/usr/src/myapp/full-music-frontend-1.0.jar"]


#FROM java:8
#WORKDIR /
#ADD HelloWorld.jar HelloWorld.jar
#EXPOSE 8080
#CMD java - jar HelloWorld.jar