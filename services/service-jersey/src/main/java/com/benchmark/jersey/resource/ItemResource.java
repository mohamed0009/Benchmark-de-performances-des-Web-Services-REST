package com.benchmark.jersey.resource;

import com.benchmark.jersey.dao.ItemDAO;
import com.benchmark.jersey.model.Item;
import com.benchmark.jersey.util.JPAUtil;

import javax.persistence.EntityManager;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Path("/items")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ItemResource {
    
    @GET
    public Response getAll(@QueryParam("page") @DefaultValue("0") int page,
                          @QueryParam("size") @DefaultValue("20") int size,
                          @QueryParam("categoryId") Long categoryId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            ItemDAO dao = new ItemDAO(em);
            List<Item> items;
            long total;
            
            if (categoryId != null) {
                items = dao.findByCategoryId(categoryId, page, size);
                total = dao.countByCategoryId(categoryId);
            } else {
                items = dao.findAll(page, size);
                total = dao.count();
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("content", items);
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
            ItemDAO dao = new ItemDAO(em);
            return dao.findById(id)
                    .map(item -> Response.ok(item).build())
                    .orElse(Response.status(Response.Status.NOT_FOUND).build());
        } finally {
            em.close();
        }
    }
    
    @POST
    public Response create(Item item) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            ItemDAO dao = new ItemDAO(em);
            Item saved = dao.save(item);
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
    public Response update(@PathParam("id") Long id, Item item) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            ItemDAO dao = new ItemDAO(em);
            if (!dao.findById(id).isPresent()) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            item.setId(id);
            Item updated = dao.save(item);
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
            ItemDAO dao = new ItemDAO(em);
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