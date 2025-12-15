package com.fashionretail.repository;

import com.fashionretail.model.Order;
import org.springframework.stereotype.Repository;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Key;

import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Repository
public class OrderRepository {

    private final DynamoDbTable<Order> orderTable;

    public OrderRepository(DynamoDbTable<Order> orderTable) {
        this.orderTable = orderTable;
    }

    public Order save(Order order) {
        order.onCreate();
        orderTable.putItem(order);
        return order;
    }

    public Optional<Order> findById(String id) {
        Order order = orderTable.getItem(Key.builder().partitionValue(id).build());
        return Optional.ofNullable(order);
    }

    public List<Order> findByUserId(String userId) {
        return orderTable.scan().items().stream()
                .filter(order -> userId.equals(order.getUserId()))
                .collect(Collectors.toList());
    }

    public List<Order> findByUserIdOrderByCreatedAtDesc(String userId) {
        return orderTable.scan().items().stream()
                .filter(order -> userId.equals(order.getUserId()))
                .sorted(Comparator.comparing(Order::getCreatedAt).reversed())
                .collect(Collectors.toList());
    }

    public void deleteById(String id) {
        orderTable.deleteItem(Key.builder().partitionValue(id).build());
    }
}
