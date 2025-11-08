package com.benchmark.springmvc.service;

import com.benchmark.springmvc.model.Category;
import com.benchmark.springmvc.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@Transactional
public class CategoryService {

    @Autowired
    private CategoryRepository categoryRepository;

    @Value("${app.use-join-fetch:false}")
    private boolean useJoinFetch;

    public Page<Category> findAll(Pageable pageable) {
        return categoryRepository.findAllCategories(pageable);
    }

    public Optional<Category> findById(Long id) {
        if (useJoinFetch) {
            return categoryRepository.findByIdWithItems(id);
        }
        return categoryRepository.findById(id);
    }

    public Optional<Category> findByCode(String code) {
        return categoryRepository.findByCode(code);
    }

    public Category save(Category category) {
        return categoryRepository.save(category);
    }

    public void deleteById(Long id) {
        categoryRepository.deleteById(id);
    }

    public long count() {
        return categoryRepository.count();
    }
}
