# Booking Service

Spring Boot microservice for ticket booking and reservation management.

## Features

- Ticket booking creation
- Kafka event publishing
- Inventory service integration
- MySQL database storage
- OpenAPI documentation
- Global exception handling
- Input validation with Bean Validation
- Metrics and monitoring with Spring Boot Actuator and Prometheus

## API Endpoints

- `POST /api/v1/booking` - Create a new booking

## Quick Start

1. Set environment variables:
   - `MYSQL_USER`
   - `MYSQL_PASSWORD`

2. Ensure Kafka is running on localhost:9092

3. Run the service:
   ```bash
   mvn spring-boot:run
   ```

4. Access API documentation:
   http://localhost:8081/swagger-ui.html

## Missing Features

- Booking retrieval and management
- Booking cancellation
- Booking status tracking
- Payment integration
- Authentication and authorization
- Unit and integration tests
- Health checks
- Booking history
- Seat selection
- Multiple ticket types

## Metrics and Monitoring

This service uses Spring Boot Actuator for health checks and metrics.

- Health endpoint: `http://localhost:8081/actuator/health`
- Metrics endpoint: `http://localhost:8081/actuator/metrics`

For advanced monitoring, Prometheus can scrape metrics and Grafana can visualize them.
