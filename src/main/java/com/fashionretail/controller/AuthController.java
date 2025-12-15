package com.fashionretail.controller;

import com.fashionretail.dto.LoginRequest;
import com.fashionretail.dto.RegisterRequest;
import com.fashionretail.model.User;
import com.fashionretail.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private final UserService userService;
    private final AuthenticationManager authenticationManager;

    @PostMapping("/register")
    public ResponseEntity<Map<String, String>> register(@RequestBody RegisterRequest request) {
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(request.getPassword());
        user.setFullName(request.getFullName());
        user.setPhoneNumber(request.getPhoneNumber());
        
        User registeredUser = userService.registerUser(user);
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "User registered successfully");
        response.put("email", registeredUser.getEmail());
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        User user = userService.getUserByEmail(request.getEmail());
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Login successful");
        response.put("email", user.getEmail());
        response.put("fullName", user.getFullName());
        
        return ResponseEntity.ok(response);
    }
}
