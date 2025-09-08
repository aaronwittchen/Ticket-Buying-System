package com.onion.inventoryservice;

import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;

public class TestConfig implements BeforeAllCallback {
    @Override
    public void beforeAll(ExtensionContext context) throws Exception {
        try {
            // Load the .env file from the project root
            File envFile = new File("../../.env");
            Properties props = new Properties();
            props.load(new FileReader(envFile));
            
            // Set each property as a system property
            props.forEach((key, value) -> 
                System.setProperty(key.toString(), value.toString().trim())
            );
        } catch (IOException e) {
            System.err.println("Could not load .env file: " + e.getMessage());
            throw e;
        }
    }
}
