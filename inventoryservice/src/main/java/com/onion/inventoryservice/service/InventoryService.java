package com.onion.inventoryservice.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.onion.inventoryservice.entity.Event;
import com.onion.inventoryservice.entity.Venue;
import com.onion.inventoryservice.exception.InvalidRequestException;
import com.onion.inventoryservice.exception.ResourceNotFoundException;
import com.onion.inventoryservice.repository.EventRepository;
import com.onion.inventoryservice.repository.VenueRepository;
import com.onion.inventoryservice.response.EventInventoryResponse;
import com.onion.inventoryservice.response.VenueInventoryResponse;

import lombok.extern.slf4j.Slf4j;

/**
 * InventoryService
 * ------------------
 * Handles business logic related to event and venue inventory.
 * Retrieves data from repositories and maps it to DTOs for API responses.
 */
@Service
@Slf4j
public class InventoryService {

    private final EventRepository eventRepository;
    private final VenueRepository venueRepository;

    public InventoryService(EventRepository eventRepository, VenueRepository venueRepository) {
        this.eventRepository = eventRepository;
        this.venueRepository = venueRepository;
    }

    /**
     * Retrieves all events and maps them to API response DTOs.
     *
     * @return list of EventInventoryResponse objects
     */
    public List<EventInventoryResponse> getAllEvents() {
        List<Event> events = eventRepository.findAll();
        return events.stream()
            .map(event -> EventInventoryResponse.builder()
                .event(event.getName())
                .capacity(event.getLeftCapacity())
                .venue(event.getVenue())
                .build())
            .collect(Collectors.toList());
    }

    /**
     * Retrieves information for a specific venue by ID.
     *
     * @param venueId the venue ID
     * @return VenueInventoryResponse object
     */
    public VenueInventoryResponse getVenueInformation(final Long venueId) {
        if (venueId == null) {
            throw new InvalidRequestException("Venue ID cannot be null");
        }

        Venue venue = venueRepository.findById(venueId)
            .orElseThrow(() -> new ResourceNotFoundException("Venue", "id", venueId));

        return VenueInventoryResponse.builder()
                .venueId(venue.getId())
                .venueName(venue.getName())
                .totalCapacity(venue.getTotalCapacity())
                .build();
    }

    /**
     * Retrieves inventory details for a specific event.
     *
     * @param eventId the event ID
     * @return EventInventoryResponse object
     */
    public EventInventoryResponse getEventInventory(final Long eventId) {
        if (eventId == null) {
            throw new InvalidRequestException("Event ID cannot be null");
        }

        Event event = eventRepository.findById(eventId)
            .orElseThrow(() -> new ResourceNotFoundException("Event", "id", eventId));

        return EventInventoryResponse.builder()
                .event(event.getName())
                .capacity(event.getLeftCapacity())
                .venue(event.getVenue())
                .ticketPrice(event.getTicketPrice())
                .eventId(event.getId())
                .build();
    }

    /**
     * Updates the remaining capacity for a specific event after tickets are booked.
     *
     * @param eventId      the event ID
     * @param ticketsBooked the number of tickets booked
     */
    public void updateEventCapacity(final Long eventId, final Long ticketsBooked) {
        if (eventId == null) {
            throw new InvalidRequestException("Event ID cannot be null");
        }
        if (ticketsBooked == null || ticketsBooked <= 0) {
            throw new InvalidRequestException("Tickets booked must be greater than 0");
        }

        Event event = eventRepository.findById(eventId)
            .orElseThrow(() -> new ResourceNotFoundException("Event", "id", eventId));

        if (event.getLeftCapacity() < ticketsBooked) {
            throw new InvalidRequestException(
                "Not enough capacity available. Available: " 
                + event.getLeftCapacity() + ", Requested: " + ticketsBooked);
        }

        event.setLeftCapacity(event.getLeftCapacity() - ticketsBooked);
        eventRepository.saveAndFlush(event);
        log.info("Updated event capacity for event id {}: {} tickets booked", eventId, ticketsBooked);
    }
}
