FROM --platform=$BUILDPLATFORM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY health-checker/pom.xml ./pom.xml
COPY health-checker/src ./src
RUN mvn -B -ntp -Dmaven.test.skip=true package

FROM eclipse-temurin:17-jre
LABEL authors="da.knyazev"
WORKDIR /app
COPY --from=build /build/target/home-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8000
ENTRYPOINT ["java", "-jar", "app.jar"]
