# Order Service

Spring Boot microservice for order processing via Kafka events.

## Features

- Kafka event consumption
- Order creation and persistence
- Inventory service integration
- MySQL database storage
- Event-driven architecture
- Global exception handling
- Input validation with Bean Validation
- Metrics and monitoring with Spring Boot Actuator and Prometheus

## API Endpoints

No REST endpoints - service processes orders via Kafka events from Booking Service.

## Quick Start

1. Set environment variables:
   - `MYSQL_USER`
   - `MYSQL_PASSWORD`

2. Ensure Kafka is running on localhost:9092

3. Run the service:
   ```bash
   mvn spring-boot:run
   ```

## Missing Features

- REST API endpoints for order management
- Order status tracking
- Payment processing
- Order history and retrieval
- Authentication and authorization
- Unit and integration tests
- Health checks
- Order cancellation
- Refund processing

## Metrics and Monitoring

This service uses Spring Boot Actuator for health checks and metrics.

- Health endpoint: `http://localhost:8082/actuator/health`
- Metrics endpoint: `http://localhost:8082/actuator/metrics`

For advanced monitoring, Prometheus can scrape metrics and Grafana can visualize them.
