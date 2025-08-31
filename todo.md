## API Gateway

- [ ] Research existing solutions (Kong, AWS API Gateway, NGINX)
- [ ] Service discovery integration
- [ ] Rate limiting
- [ ] Request/response logging
- [ ] API versioning
- [ ] CORS configuration
- [ ] Request transformation
- [ ] Response caching
- [ ] Load balancing configuration
- [ ] Monitoring and alerting
- [ ] API analytics
- [ ] Request tracing

## Internal Security

- [ ] Secure microservice-to-microservice communication (mTLS)
- [ ] Add authentication between internal services
- [ ] Network segmentation to prevent subnet intrusions

## User Authentication

- [ ] Remove user IDs from request bodies
- [ ] Extract all user info from JWT claims only
- [ ] Implement proper JWT validation in all services
- [ ] Never trust user-provided identifiers
- [ ] Authentication and authorization for Inventory Service, Booking Service, and Order Service

## Testing

- [ ] Security audit of all endpoints
- [ ] Test authorization flows
- [ ] Penetration testing
- [ ] Unit and integration tests for all services
- [ ] Health checks

## Monitoring

- [ ] Look into Spring Boot JMX
- [ ] Look into Prometheus and Grafana dashboards

## Booking & Orders

- [ ] Booking retrieval and management
- [ ] Booking cancellation
- [ ] Booking status tracking
- [ ] Payment integration
- [ ] Booking history
- [ ] Seat selection
- [ ] Multiple ticket types
- [ ] Order status tracking
- [ ] Order cancellation
- [ ] Refund processing
