package com.nexaops.userservice;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Manages a list of NexaOps users: add them, find them, count them.
 */
public class UserService {

    private final List<User> users = new ArrayList<>();

    public void addUser(User user) {
        users.add(user);
        System.out.println("[UserService] Added user: " + user.getName());
    }

    public Optional<User> findByEmail(String email) {
        return users.stream()
                .filter(u -> u.getEmail().equalsIgnoreCase(email))
                .findFirst();
    }

    public List<User> getAllUsers() {
        return new ArrayList<>(users);
    }

    public int getUserCount() {
        return users.size();
    }

    public static void main(String[] args) {
        System.out.println("=== NexaOps User Service v1.0.0 ===");

        UserService service = new UserService();

        service.addUser(new User("u001", "Alice Okafor", "alice@nexaops.com", "admin"));
        service.addUser(new User("u002", "Bob Mensah", "bob@nexaops.com", "engineer"));
        service.addUser(new User("u003", "Chidi Eze", "chidi@nexaops.com", "engineer"));

        System.out.println("\nAll users (" + service.getUserCount() + "):");
        service.getAllUsers().forEach(System.out::println);

        System.out.println("\nLookup by email:");
        service.findByEmail("bob@nexaops.com")
               .ifPresent(u -> System.out.println("Found: " + u));

        System.out.println("\nService running. Ready to accept requests.");
    }
}
