package com.onion.bookingservice.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.onion.bookingservice.response.InventoryResponse;

@Service
public class InventoryServiceClient {

    private final RestTemplate restTemplate;
    private final String inventoryServiceUrl;

    public InventoryServiceClient(RestTemplateBuilder builder, 
                                  @Value("${inventory.service.url}") String inventoryServiceUrl) {
        this.restTemplate = builder.build();
        this.inventoryServiceUrl = inventoryServiceUrl;
    }

    public InventoryResponse getInventory(Long eventId) {
        return restTemplate.getForObject(inventoryServiceUrl + "/event/" + eventId, InventoryResponse.class);
    }
}
