# API Gateway

Spring Cloud Gateway for centralized routing and security management.

## Features

- Service routing and load balancing
- OAuth2 JWT authentication
- Circuit breaker with Resilience4j
- OpenAPI documentation aggregation
- Health monitoring with Actuator
- Global exception handling
- Input validation with Bean Validation
- Metrics and monitoring with Spring Boot Actuator and Prometheus

## API Endpoints

- Routes booking requests to Booking Service
- Routes inventory requests to Inventory Service
- Provides aggregated API documentation
- Health check endpoints via Actuator

## Quick Start

1. Ensure Keycloak is running on localhost:8091

2. Run the service:
   ```bash
   mvn spring-boot:run
   ```

3. Access API documentation:
   http://localhost:8090/swagger-ui.html

## Missing Features

- Service discovery integration
- Rate limiting
- Request/response logging
- API versioning
- CORS configuration
- Request transformation
- Response caching
- Load balancing configuration
- Monitoring and alerting
- API analytics
- Request tracing

## Metrics and Monitoring

This service uses Spring Boot Actuator for health checks and metrics.

- Health endpoint: `http://localhost:8090/actuator/health`
- Metrics endpoint: `http://localhost:8090/actuator/metrics`

For advanced monitoring, Prometheus can scrape metrics and Grafana can visualize them.
