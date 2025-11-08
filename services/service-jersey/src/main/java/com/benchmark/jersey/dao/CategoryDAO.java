package com.benchmark.jersey.dao;

import com.benchmark.jersey.model.Category;
import javax.persistence.*;
import java.util.List;
import java.util.Optional;

public class CategoryDAO {

    private final EntityManager em;
    private final boolean useJoinFetch;

    public CategoryDAO(EntityManager em) {
        this.em = em;
        this.useJoinFetch = "true".equalsIgnoreCase(System.getenv("USE_JOIN_FETCH"));
    }

    public List<Category> findAll(int page, int size) {
        String jpql = "SELECT c FROM Category c ORDER BY c.id";
        return em.createQuery(jpql, Category.class)
                .setFirstResult(page * size)
                .setMaxResults(size)
                .getResultList();
    }

    public long count() {
        return em.createQuery("SELECT COUNT(c) FROM Category c", Long.class)
                .getSingleResult();
    }

    public Optional<Category> findById(Long id) {
        String jpql = useJoinFetch
                ? "SELECT c FROM Category c LEFT JOIN FETCH c.items WHERE c.id = :id"
                : "SELECT c FROM Category c WHERE c.id = :id";

        try {
            Category category = em.createQuery(jpql, Category.class)
                    .setParameter("id", id)
                    .getSingleResult();
            return Optional.of(category);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }

    public Optional<Category> findByCode(String code) {
        try {
            Category category = em.createQuery(
                    "SELECT c FROM Category c WHERE c.code = :code", Category.class)
                    .setParameter("code", code)
                    .getSingleResult();
            return Optional.of(category);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }

    public Category save(Category category) {
        if (category.getId() == null) {
            em.persist(category);
            return category;
        } else {
            return em.merge(category);
        }
    }

    public void delete(Long id) {
        Category category = em.find(Category.class, id);
        if (category != null) {
            em.remove(category);
        }
    }
}
