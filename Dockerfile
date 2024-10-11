FROM openjdk:17-slim
WORKDIR /app
COPY . .
RUN ./gradlew bootJar
# COPY step18_empApp-0.0.1-SNAPSHOT.jar app.jar

# FROM openjdk:17-slim
# WORKDIR /app
# COPY --from=0 /app/app.jar app.jar

ENTRYPOINT ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "build/libs/step18_empApp-0.0.1-SNAPSHOT.jar"]