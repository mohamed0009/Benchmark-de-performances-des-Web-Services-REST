package com.benchmark.springmvc.repository;

import com.benchmark.springmvc.model.Item;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ItemRepository extends JpaRepository<Item, Long> {

    Optional<Item> findBySku(String sku);

    @Query("SELECT i FROM Item i WHERE i.category.id = :categoryId")
    Page<Item> findByCategoryId(@Param("categoryId") Long categoryId, Pageable pageable);

    @Query("SELECT i FROM Item i LEFT JOIN FETCH i.category WHERE i.id = :id")
    Optional<Item> findByIdWithCategory(@Param("id") Long id);

    @Query(value = "SELECT DISTINCT i FROM Item i LEFT JOIN FETCH i.category", countQuery = "SELECT COUNT(DISTINCT i) FROM Item i")
    Page<Item> findAllWithCategory(Pageable pageable);
}