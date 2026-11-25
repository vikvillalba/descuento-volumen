# Etapa 1: compilar y probar con Maven
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B package

# Etapa 2: imagen base oficial de Lambda para Java 21
FROM public.ecr.aws/lambda/java:21
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}
COPY --from=build /app/target/classes ${LAMBDA_TASK_ROOT}
CMD ["mx.itson.devops.descuento.Handler::handleRequest"]
