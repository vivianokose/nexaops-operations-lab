package com.nexaops.userservice;

/**
 * Represents one NexaOps user account.
 * Think of this as a single row in a spreadsheet: one person, with their details.
 */
public class User {

    private String id;
    private String name;
    private String email;
    private String role;

    public User(String id, String name, String email, String role) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.role = role;
    }

    public String getId()    { return id; }
    public String getName()  { return name; }
    public String getEmail() { return email; }
    public String getRole()  { return role; }

    @Override
    public String toString() {
        return String.format("User{id='%s', name='%s', email='%s', role='%s'}",
                id, name, email, role);
    }
}
