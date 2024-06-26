FROM adoptopenjdk/openjdk11:alpine-jre

EXPOSE 8075
ARG artifact=target/spring-boot-web.jar

ENV APP_HOME /usr/src/app

COPY ${artifact} $APP_HOME/app.jar

WORKDIR $APP_HOME

ENTRYPOINT ["java","-jar","app.jar"]