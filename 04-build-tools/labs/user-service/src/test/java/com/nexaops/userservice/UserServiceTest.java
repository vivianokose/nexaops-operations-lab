package com.nexaops.userservice;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Small checks that confirm UserService behaves correctly.
 */
class UserServiceTest {

    private UserService service;

    @BeforeEach
    void setUp() {
        service = new UserService();
        service.addUser(new User("u001", "Alice Okafor", "alice@nexaops.com", "admin"));
        service.addUser(new User("u002", "Bob Mensah", "bob@nexaops.com", "engineer"));
    }

    @Test
    void testGetUserCount() {
        assertEquals(2, service.getUserCount(), "Should have 2 users after setup");
    }

    @Test
    void testFindByEmailReturnsCorrectUser() {
        var user = service.findByEmail("alice@nexaops.com");
        assertTrue(user.isPresent(), "User should be found");
        assertEquals("Alice Okafor", user.get().getName());
    }

    @Test
    void testFindByEmailCaseInsensitive() {
        var user = service.findByEmail("BOB@NEXAOPS.COM");
        assertTrue(user.isPresent(), "Email lookup should be case-insensitive");
    }

    @Test
    void testFindByEmailNotFound() {
        var user = service.findByEmail("nobody@nexaops.com");
        assertFalse(user.isPresent(), "Non-existent user should not be found");
    }
}
