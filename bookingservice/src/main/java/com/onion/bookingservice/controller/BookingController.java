package com.onion.bookingservice.controller;

import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.onion.bookingservice.request.BookingRequest;
import com.onion.bookingservice.response.BookingResponse;
import com.onion.bookingservice.service.BookingService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1")
@Validated
public class BookingController {

    private final BookingService bookingService;

    // @Autowired
    public BookingController(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    @PostMapping(consumes = "application/json", produces = "application/json", path = "/booking")
    public BookingResponse createBooking(@RequestBody @Valid BookingRequest request) {
        return bookingService.createBooking(request);
    }
}
