# Builds and runs the bundled "users" mock API (support/MockServerMain) as a standalone
# container, on a fixed port - the containerized equivalent of
# `mvn test-compile exec:java` (see README.md / scripts/mock-start.sh). There is no separate
# application: the mock *is* a Karate feature file (src/test/java/mock/users-api.feature),
# so the image just needs Maven + the test classpath to run it.
FROM maven:3.9.9-eclipse-temurin-17

WORKDIR /app

# Cache dependency resolution in its own layer, invalidated only when pom.xml changes.
COPY pom.xml .
RUN mvn --batch-mode -q dependency:go-offline

COPY src ./src
RUN mvn --batch-mode -q test-compile

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

ENTRYPOINT ["mvn", "--batch-mode", "-q", "-o", "test-compile", "exec:java"]
