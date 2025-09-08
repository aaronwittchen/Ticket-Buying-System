# Ticket Booking System

![Java](https://img.shields.io/badge/Java-17-blue)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.2.0-green)
![Maven](https://img.shields.io/badge/Maven-3.9.0-blue)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)
![Kafka](https://img.shields.io/badge/Kafka-3.6.0-orange)
![Prometheus](https://img.shields.io/badge/Prometheus-monitoring-lightgrey)
![Grafana](https://img.shields.io/badge/Grafana-dashboard-orange)
![Keycloak](https://img.shields.io/badge/Keycloak-authentication-red)
![License](https://img.shields.io/badge/License-MIT-blue)
![Build](https://img.shields.io/badge/build-passing-brightgreen)
![API Docs](https://img.shields.io/badge/API-OpenAPI-blueviolet)

A **microservices-based ticket booking application** with event inventory management, booking processing, and order management.

![Ticket Buying System Diagram](public/Ticket%20Buying%20System%20Diagram.png)

---

## Features

- Event inventory and venue capacity management
- Real-time inventory updates
- Ticket booking creation
- Kafka-based event publishing and consumption
- Order creation and persistence
- Integration with MySQL and Flyway migrations
- Event-driven architecture with service routing and load balancing
- OAuth2 JWT authentication via Keycloak
- Circuit breaker using Resilience4j
- OpenAPI documentation (individual & aggregated)
- Global exception handling & input validation
- Health monitoring with Spring Boot Actuator
- Metrics collection with Prometheus & visualization via Grafana

---

## Architecture

| Service           | Port |
| ----------------- | ---- |
| Inventory Service | 8080 |
| Booking Service   | 8081 |
| Order Service     | 8082 |
| API Gateway       | 8090 |

---

## Quick Start

1. **Start MySQL**
   Ensure a database named `ticketing` exists.

2. **Run Docker containers**

   ```bash
   docker-compose up -d
   ```

3. **Start services**

   ```bash
   cd inventoryservice && mvn spring-boot:run
   cd bookingservice && mvn spring-boot:run
   cd orderservice && mvn spring-boot:run
   cd apigateway && mvn spring-boot:run
   ```

````

## Environment Variables

Set the following variables:

```bash
MYSQL_USER=<your_mysql_username>
MYSQL_PASSWORD=<your_mysql_password>
````

---

## 📡 API Endpoints

### Inventory Service

- `GET /api/v1/inventory/events` – List all events
- `GET /api/v1/inventory/venue/{venueId}` – Get venue info
- `GET /api/v1/inventory/event/{eventId}` – Get event inventory
- `PUT /api/v1/inventory/event/{eventId}/capacity/{capacity}` – Update event capacity

### Booking Service

- `POST /api/v1/booking` – Create a new booking

### Order Service

- Processes orders via Kafka events from Booking Service (no REST endpoints)

### API Gateway

- Routes booking & inventory requests
- Aggregated API documentation
- Health checks via Actuator

---

## Metrics & Monitoring

All services use **Spring Boot Actuator**:

| Service           | Health Endpoint                         | Metrics Endpoint                         |
| ----------------- | --------------------------------------- | ---------------------------------------- |
| Inventory Service | `http://localhost:8080/actuator/health` | `http://localhost:8080/actuator/metrics` |
| Booking Service   | `http://localhost:8081/actuator/health` | `http://localhost:8081/actuator/metrics` |
| Order Service     | `http://localhost:8082/actuator/health` | `http://localhost:8082/actuator/metrics` |
| API Gateway       | `http://localhost:8090/actuator/health` | `http://localhost:8090/actuator/metrics` |

Prometheus scrapes metrics from all services and Grafana provides dashboards.

---

## API Documentation

- Centralized via API Gateway: `http://localhost:8090/swagger-ui.html`
- Inventory Service: `http://localhost:8080/swagger-ui.html`
- Booking Service: `http://localhost:8081/swagger-ui.html`
