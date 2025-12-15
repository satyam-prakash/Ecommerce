package com.fashionretail.repository;

import com.fashionretail.model.Product;
import org.springframework.stereotype.Repository;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Key;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Repository
public class ProductRepository {

    private final DynamoDbTable<Product> productTable;

    public ProductRepository(DynamoDbTable<Product> productTable) {
        this.productTable = productTable;
    }

    public Product save(Product product) {
        product.onCreate();
        productTable.putItem(product);
        return product;
    }

    public Optional<Product> findById(String id) {
        Product product = productTable.getItem(Key.builder().partitionValue(id).build());
        return Optional.ofNullable(product);
    }

    public List<Product> findAll() {
        return productTable.scan().items().stream().collect(Collectors.toList());
    }

    public List<Product> findByActiveTrue() {
        return productTable.scan().items().stream()
                .filter(Product::getActive)
                .collect(Collectors.toList());
    }

    public List<Product> findByCategory(String category) {
        return productTable.scan().items().stream()
                .filter(p -> category.equals(p.getCategory()))
                .collect(Collectors.toList());
    }

    public List<Product> findByNameContainingIgnoreCase(String name) {
        return productTable.scan().items().stream()
                .filter(p -> p.getName() != null && p.getName().toLowerCase().contains(name.toLowerCase()))
                .collect(Collectors.toList());
    }

    public void deleteById(String id) {
        productTable.deleteItem(Key.builder().partitionValue(id).build());
    }
}
