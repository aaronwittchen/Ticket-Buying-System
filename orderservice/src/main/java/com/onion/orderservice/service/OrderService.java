package com.onion.orderservice.service;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.onion.bookingservice.event.BookingEvent;
import com.onion.orderservice.client.InventoryServiceClient;
import com.onion.orderservice.entity.Order;
import com.onion.orderservice.exception.OrderProcessingException;
import com.onion.orderservice.repository.OrderRepository;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class OrderService {

    private OrderRepository orderRepository;
    private InventoryServiceClient inventoryServiceClient;

    // @Autowired
    public OrderService(OrderRepository orderRepository,
                        InventoryServiceClient inventoryServiceClient) {
        this.orderRepository = orderRepository;
        this.inventoryServiceClient = inventoryServiceClient;
    }

    @KafkaListener(topics = "booking", groupId = "order-service")
    public void orderEvent(BookingEvent bookingEvent) {
        try {
            if (bookingEvent == null) {
                throw new OrderProcessingException("Booking event cannot be null");
            }
            
            log.info("Received order event: {}", bookingEvent);
            
            // Create Order object for DB
            Order order = createOrder(bookingEvent);
            orderRepository.saveAndFlush(order);

            // Update Inventory
            inventoryServiceClient.updateInventory(order.getEventId(), order.getTicketCount());
            log.info("Inventory updated for event: {}, less tickets: {}", order.getEventId(), order.getTicketCount());
        } catch (Exception e) {
            log.error("Error processing order event: {}", e.getMessage(), e);
            throw new OrderProcessingException("Failed to process order event", e);
        }
    }

    private Order createOrder(BookingEvent bookingEvent) {
        return Order.builder()
                .customerId(bookingEvent.getUserId())
                .eventId(bookingEvent.getEventId())
                .ticketCount(bookingEvent.getTicketCount())
                .totalPrice(bookingEvent.getTotalPrice())
                .build();
    }
}