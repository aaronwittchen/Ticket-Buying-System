package com.onion.inventoryservice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.onion.inventoryservice.entity.Event;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {
}
