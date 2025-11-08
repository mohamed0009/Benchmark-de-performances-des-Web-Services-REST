package com.benchmark.jersey.resource;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.HashMap;
import java.util.Map;

@Path("/")
@Produces(MediaType.APPLICATION_JSON)
public class HealthResource {

    @GET
    @Path("/ping")
    public Response ping() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "pong");
        response.put("service", "JAX-RS (Jersey)");
        return Response.ok(response).build();
    }

    @GET
    @Path("/health")
    public Response health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "healthy");
        response.put("service", "JAX-RS (Jersey) + JPA/Hibernate");
        response.put("timestamp", System.currentTimeMillis());
        return Response.ok(response).build();
    }
}
