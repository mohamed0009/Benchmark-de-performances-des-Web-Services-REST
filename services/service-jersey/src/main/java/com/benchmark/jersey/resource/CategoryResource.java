package com.benchmark.jersey.resource;

import com.benchmark.jersey.dao.CategoryDAO;
import com.benchmark.jersey.model.Category;
import com.benchmark.jersey.util.JPAUtil;

import javax.persistence.EntityManager;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Path("/categories")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CategoryResource {
    
    @GET
    public Response getAll(@QueryParam("page") @DefaultValue("0") int page,
                          @QueryParam("size") @DefaultValue("20") int size) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            CategoryDAO dao = new CategoryDAO(em);
            List<Category> categories = dao.findAll(page, size);
            long total = dao.count();
            
            Map<String, Object> response = new HashMap<>();
            response.put("content", categories);
            response.put("page", page);
            response.put("size", size);
            response.put("totalElements", total);
            response.put("totalPages", (int) Math.ceil((double) total / size));
            
            return Response.ok(response).build();
        } finally {
            em.close();
        }
    }
    
    @GET
    @Path("/{id}")
    public Response getById(@PathParam("id") Long id) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            CategoryDAO dao = new CategoryDAO(em);
            return dao.findById(id)
                    .map(cat -> Response.ok(cat).build())
                    .orElse(Response.status(Response.Status.NOT_FOUND).build());
        } finally {
            em.close();
        }
    }
    
    @GET
    @Path("/{id}/items")
    public Response getCategoryItems(@PathParam("id") Long id) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            CategoryDAO dao = new CategoryDAO(em);
            return dao.findById(id)
                    .map(cat -> Response.ok(cat.getItems()).build())
                    .orElse(Response.status(Response.Status.NOT_FOUND).build());
        } finally {
            em.close();
        }
    }
    
    @POST
    public Response create(Category category) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            CategoryDAO dao = new CategoryDAO(em);
            Category saved = dao.save(category);
            em.getTransaction().commit();
            return Response.status(Response.Status.CREATED).entity(saved).build();
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }
    
    @PUT
    @Path("/{id}")
    public Response update(@PathParam("id") Long id, Category category) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            CategoryDAO dao = new CategoryDAO(em);
            if (!dao.findById(id).isPresent()) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            category.setId(id);
            Category updated = dao.save(category);
            em.getTransaction().commit();
            return Response.ok(updated).build();
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }
    
    @DELETE
    @Path("/{id}")
    public Response delete(@PathParam("id") Long id) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            CategoryDAO dao = new CategoryDAO(em);
            if (!dao.findById(id).isPresent()) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            dao.delete(id);
            em.getTransaction().commit();
            return Response.noContent().build();
        } catch (Exception e) {
            em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}