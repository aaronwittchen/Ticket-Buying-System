package com.onion.bookingservice.service;

import java.math.BigDecimal;

import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import com.onion.bookingservice.client.InventoryServiceClient;
import com.onion.bookingservice.entity.Customer;
import com.onion.bookingservice.event.BookingEvent;
import com.onion.bookingservice.exception.BookingException;
import com.onion.bookingservice.repository.CustomerRepository;
import com.onion.bookingservice.request.BookingRequest;
import com.onion.bookingservice.response.BookingResponse;
import com.onion.bookingservice.response.InventoryResponse;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class BookingService {

    private final CustomerRepository customerRepository;
    private final InventoryServiceClient inventoryServiceClient;
     private final KafkaTemplate<String, BookingEvent> kafkaTemplate;

    // @Autowired
    public BookingService(final CustomerRepository customerRepository,
                          final InventoryServiceClient inventoryServiceClient,
                          final KafkaTemplate<String, BookingEvent> kafkaTemplate) {
        this.customerRepository = customerRepository;
        this.inventoryServiceClient = inventoryServiceClient;
        this.kafkaTemplate = kafkaTemplate;
    }
    
    public BookingResponse createBooking(final BookingRequest request) {
        if (request == null) {
            throw new BookingException("Booking request cannot be null");
        }
        if (request.getUserId() == null) {
            throw new BookingException("User ID cannot be null");
        }
        if (request.getEventId() == null) {
            throw new BookingException("Event ID cannot be null");
        }
        if (request.getTicketCount() == null || request.getTicketCount() <= 0) {
            throw new BookingException("Ticket count must be greater than 0");
        }
        
        // check if user exists
        final Customer customer = customerRepository.findById(request.getUserId()).orElse(null);
        if (customer == null) {
            throw new BookingException("User not found with ID: " + request.getUserId());
        }
        
        // check if there is enough inventory
        final InventoryResponse inventoryResponse = inventoryServiceClient.getInventory(request.getEventId());
        log.info("Inventory Response: {}", inventoryResponse);
        if (inventoryResponse.getCapacity() < request.getTicketCount()) {
            throw new BookingException("Not enough inventory. Available: " + inventoryResponse.getCapacity() + ", Requested: " + request.getTicketCount());
        }

        // create booking
        final BookingEvent bookingEvent = createBookingEvent(request, customer, inventoryResponse);

        // send booking to Order Service on a Kafka Topic
        kafkaTemplate.send("booking", bookingEvent);
        log.info("Booking sent to Kafka: {}", bookingEvent);
        return BookingResponse.builder()
                .userId(bookingEvent.getUserId())
                .eventId(bookingEvent.getEventId())
                .ticketCount(bookingEvent.getTicketCount())
                .totalPrice(bookingEvent.getTotalPrice())
                .build();
    }

    private BookingEvent createBookingEvent(final BookingRequest request,
                                            final Customer customer,
                                            final InventoryResponse inventoryResponse) {
        return BookingEvent.builder()
                .userId(customer.getId())
                .eventId(request.getEventId())
                .ticketCount(request.getTicketCount())
                .totalPrice(inventoryResponse.getTicketPrice().multiply(BigDecimal.valueOf(request.getTicketCount())))
                .build();
    }
}