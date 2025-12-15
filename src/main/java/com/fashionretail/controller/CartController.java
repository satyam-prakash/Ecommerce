package com.fashionretail.controller;

import com.fashionretail.dto.AddToCartRequest;
import com.fashionretail.model.CartItem;
import com.fashionretail.model.User;
import com.fashionretail.service.CartService;
import com.fashionretail.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CartController {

    private final CartService cartService;
    private final UserService userService;

    @GetMapping
    public ResponseEntity<List<CartItem>> getCartItems(Authentication authentication) {
        User user = userService.getUserByEmail(authentication.getName());
        return ResponseEntity.ok(cartService.getCartItems(user));
    }

    @PostMapping
    public ResponseEntity<CartItem> addToCart(@RequestBody AddToCartRequest request,
                                               Authentication authentication) {
        User user = userService.getUserByEmail(authentication.getName());
        CartItem cartItem = cartService.addToCart(user, request.getProductId(), request.getQuantity());
        return ResponseEntity.ok(cartItem);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CartItem> updateCartItem(@PathVariable Long id,
                                                    @RequestParam Integer quantity) {
        return ResponseEntity.ok(cartService.updateCartItem(id, quantity));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> removeFromCart(@PathVariable Long id) {
        cartService.removeFromCart(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> clearCart(Authentication authentication) {
        User user = userService.getUserByEmail(authentication.getName());
        cartService.clearCart(user);
        return ResponseEntity.noContent().build();
    }
}
