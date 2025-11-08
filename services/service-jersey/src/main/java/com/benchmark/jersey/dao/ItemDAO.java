package com.benchmark.jersey.dao;

import com.benchmark.jersey.model.Item;
import javax.persistence.*;
import java.util.List;
import java.util.Optional;

public class ItemDAO {
    
    private final EntityManager em;
    private final boolean useJoinFetch;
    
    public ItemDAO(EntityManager em) {
        this.em = em;
        this.useJoinFetch = "true".equalsIgnoreCase(System.getenv("USE_JOIN_FETCH"));
    }
    
    public List<Item> findAll(int page, int size) {
        String jpql = useJoinFetch
            ? "SELECT DISTINCT i FROM Item i LEFT JOIN FETCH i.category ORDER BY i.id"
            : "SELECT i FROM Item i ORDER BY i.id";
        
        return em.createQuery(jpql, Item.class)
                .setFirstResult(page * size)
                .setMaxResults(size)
                .getResultList();
    }
    
    public List<Item> findByCategoryId(Long categoryId, int page, int size) {
        String jpql = useJoinFetch
            ? "SELECT i FROM Item i LEFT JOIN FETCH i.category WHERE i.category.id = :categoryId ORDER BY i.id"
            : "SELECT i FROM Item i WHERE i.category.id = :categoryId ORDER BY i.id";
        
        return em.createQuery(jpql, Item.class)
                .setParameter("categoryId", categoryId)
                .setFirstResult(page * size)
                .setMaxResults(size)
                .getResultList();
    }
    
    public long count() {
        return em.createQuery("SELECT COUNT(i) FROM Item i", Long.class)
                .getSingleResult();
    }
    
    public long countByCategoryId(Long categoryId) {
        return em.createQuery(
                "SELECT COUNT(i) FROM Item i WHERE i.category.id = :categoryId", Long.class)
                .setParameter("categoryId", categoryId)
                .getSingleResult();
    }
    
    public Optional<Item> findById(Long id) {
        String jpql = useJoinFetch
            ? "SELECT i FROM Item i LEFT JOIN FETCH i.category WHERE i.id = :id"
            : "SELECT i FROM Item i WHERE i.id = :id";
        
        try {
            Item item = em.createQuery(jpql, Item.class)
                    .setParameter("id", id)
                    .getSingleResult();
            return Optional.of(item);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }
    
    public Optional<Item> findBySku(String sku) {
        try {
            Item item = em.createQuery(
                    "SELECT i FROM Item i WHERE i.sku = :sku", Item.class)
                    .setParameter("sku", sku)
                    .getSingleResult();
            return Optional.of(item);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }
    
    public Item save(Item item) {
        if (item.getId() == null) {
            em.persist(item);
            return item;
        } else {
            return em.merge(item);
        }
    }
    
    public void delete(Long id) {
        Item item = em.find(Item.class, id);
        if (item != null) {
            em.remove(item);
        }
    }
}