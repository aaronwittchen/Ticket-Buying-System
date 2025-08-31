package com.onion.bookingservice.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

@Data   
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class BookingRequest {
    @NotNull(message = "User ID is required")
    @Min(value = 1, message = "User ID must be greater than 0")
    private Long userId;
    
    @NotNull(message = "Event ID is required")
    @Min(value = 1, message = "Event ID must be greater than 0")
    private Long eventId;
    
    @NotNull(message = "Ticket count is required")
    @Min(value = 1, message = "Ticket count must be at least 1")
    private Long ticketCount;
}