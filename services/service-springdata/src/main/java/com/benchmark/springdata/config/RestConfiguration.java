package com.benchmark.springdata.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.rest.core.config.RepositoryRestConfiguration;
import org.springframework.data.rest.webmvc.config.RepositoryRestConfigurer;
import org.springframework.web.servlet.config.annotation.CorsRegistry;

import com.benchmark.springdata.model.Item;

/**
 * Configuration for Spring Data REST
 */
@Configuration
public class RestConfiguration implements RepositoryRestConfigurer {

    @Override
    public void configureRepositoryRestConfiguration(RepositoryRestConfiguration config, CorsRegistry cors) {
        // Expose IDs in the response
        config.exposeIdsFor(Item.class);

        // Set base path for all Spring Data REST endpoints
        config.setBasePath("/api");

        // Return response body after POST/PUT
        config.setReturnBodyOnCreate(true);
        config.setReturnBodyOnUpdate(true);
    }
}
