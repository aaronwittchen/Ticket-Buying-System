package com.onion.orderservice.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.onion.orderservice.entity.Order;

public interface OrderRepository extends JpaRepository<Order, Long> {   
}
