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
        return ResponseEntity.ok(cartService.getCartItems(user.getId()));
    }

    @PostMapping
    public ResponseEntity<CartItem> addToCart(@RequestBody AddToCartRequest request,
                                               Authentication authentication) {
        User user = userService.getUserByEmail(authentication.getName());
        CartItem cartItem = cartService.addToCart(user.getId(), request.getProductId(), request.getQuantity());
        return ResponseEntity.ok(cartItem);
    }

    @PutMapping("/{productId}")
    public ResponseEntity<CartItem> updateCartItem(@PathVariable String productId,
                                                    @RequestParam Integer quantity,
                                                    Authentication authentication) {
        User user = userService.getUserByEmail(authentication.getName());
        return ResponseEntity.ok(cartService.updateCartItem(user.getId(), productId, quantity));
    }

    @DeleteMapping("/{productId}")
    public ResponseEntity<Void> removeFromCart(@PathVariable String productId,
                                                Authentication authentication) {
        User user = userService.getUserByEmail(authentication.getName());
        cartService.removeFromCart(user.getId(), productId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> clearCart(Authentication authentication) {
        User user = userService.getUserByEmail(authentication.getName());
        cartService.clearCart(user.getId());
        return ResponseEntity.noContent().build();
    }
}
