
package com.example.bankapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication
public class BankappApplication extends SpringBootServletInitializer {

    // This override block tells standalone Apache Tomcat how to launch the Spring Boot app context
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
        return builder.sources(BankappApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(BankappApplication.class, args);
    }
}
