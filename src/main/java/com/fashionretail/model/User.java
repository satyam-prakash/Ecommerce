package com.fashionretail.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@DynamoDbBean
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    private String id;
    private String email;
    private String password;
    private String fullName;
    private String phoneNumber;
    private String address;
    private Set<String> roles = new HashSet<>();
    private Boolean enabled = true;
    private Long createdAt;

    @DynamoDbPartitionKey
    public String getId() {
        return id;
    }

    public void onCreate() {
        if (id == null) {
            id = UUID.randomUUID().toString();
        }
        if (createdAt == null) {
            createdAt = Instant.now().toEpochMilli();
        }
        if (roles.isEmpty()) {
            roles.add("ROLE_USER");
        }
    }
}
