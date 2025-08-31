package com.onion.orderservice.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class InventoryServiceClient {

    private final RestTemplate restTemplate;
    private final String inventoryServiceUrl;

    public InventoryServiceClient(RestTemplate restTemplate,
                                  @Value("${inventory.service.url}") String inventoryServiceUrl) {
        this.restTemplate = restTemplate;
        this.inventoryServiceUrl = inventoryServiceUrl;
    }

    public ResponseEntity<Void> updateInventory(final Long eventId,
                                                final Long ticketCount) {
        restTemplate.put(inventoryServiceUrl + "/event/" + eventId + "/capacity/" + ticketCount, null);
        return ResponseEntity.ok().build();
    }
}
