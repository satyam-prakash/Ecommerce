package com.fashionretail.repository;

import com.fashionretail.model.User;
import org.springframework.stereotype.Repository;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.Key;

import java.util.Optional;

@Repository
public class UserRepository {

    private final DynamoDbTable<User> userTable;

    public UserRepository(DynamoDbTable<User> userTable) {
        this.userTable = userTable;
    }

    public User save(User user) {
        user.onCreate();
        userTable.putItem(user);
        return user;
    }

    public Optional<User> findById(String id) {
        User user = userTable.getItem(Key.builder().partitionValue(id).build());
        return Optional.ofNullable(user);
    }

    public Optional<User> findByEmail(String email) {
        // Scan for user by email (consider adding GSI for production)
        return userTable.scan().items().stream()
                .filter(user -> email.equals(user.getEmail()))
                .findFirst();
    }

    public Boolean existsByEmail(String email) {
        return findByEmail(email).isPresent();
    }

    public void deleteById(String id) {
        userTable.deleteItem(Key.builder().partitionValue(id).build());
    }
}
