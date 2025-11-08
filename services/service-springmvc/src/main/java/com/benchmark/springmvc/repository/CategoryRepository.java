package com.benchmark.springmvc.repository;

import com.benchmark.springmvc.model.Category;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    Optional<Category> findByCode(String code);

    @Query("SELECT c FROM Category c LEFT JOIN FETCH c.items WHERE c.id = :id")
    Optional<Category> findByIdWithItems(@Param("id") Long id);

    @Query("SELECT c FROM Category c")
    Page<Category> findAllCategories(Pageable pageable);
}
