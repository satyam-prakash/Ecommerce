package com.fashionretail.repository;

import com.fashionretail.model.CartItem;
import org.springframework.stereotype.Repository;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Key;
import software.amazon.awssdk.enhanced.dynamodb.model.QueryConditional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Repository
public class CartItemRepository {

    private final DynamoDbTable<CartItem> cartItemTable;

    public CartItemRepository(DynamoDbTable<CartItem> cartItemTable) {
        this.cartItemTable = cartItemTable;
    }

    public CartItem save(CartItem cartItem) {
        cartItem.onCreate();
        cartItemTable.putItem(cartItem);
        return cartItem;
    }

    public List<CartItem> findByUserId(String userId) {
        QueryConditional queryConditional = QueryConditional.keyEqualTo(
                Key.builder().partitionValue(userId).build());
        return cartItemTable.query(queryConditional).items().stream()
                .collect(Collectors.toList());
    }

    public Optional<CartItem> findByUserIdAndProductId(String userId, String productId) {
        Key key = Key.builder()
                .partitionValue(userId)
                .sortValue(productId)
                .build();
        CartItem item = cartItemTable.getItem(key);
        return Optional.ofNullable(item);
    }

    public void deleteByUserIdAndProductId(String userId, String productId) {
        Key key = Key.builder()
                .partitionValue(userId)
                .sortValue(productId)
                .build();
        cartItemTable.deleteItem(key);
    }

    public void deleteByUserId(String userId) {
        List<CartItem> items = findByUserId(userId);
        items.forEach(cartItemTable::deleteItem);
    }
}
