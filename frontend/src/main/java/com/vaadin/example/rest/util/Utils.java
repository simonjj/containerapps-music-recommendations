package com.vaadin.example.rest.util;
import java.util.logging.Logger;

public class Utils {
    private static final Logger LOGGER = Logger.getLogger(Utils.class.getName());

    public static String getBackendServer() {
        String backendServer = System.getenv("UI_BACKEND");
        if (backendServer == null || backendServer.isEmpty()) {
            // Log an error message
            LOGGER.severe("Environment variable UI_BACKEND is not set. Using localhost as the default ui backend endpoint.");
            // return default server if UI_BACKEND is not set
            backendServer = "localhost";
        }
        return backendServer;
    }
}