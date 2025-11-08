package com.benchmark.springmvc.service;

import com.benchmark.springmvc.model.Item;
import com.benchmark.springmvc.repository.ItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@Transactional
public class ItemService {
    
    @Autowired
    private ItemRepository itemRepository;
    
    @Value("${app.use-join-fetch:false}")
    private boolean useJoinFetch;
    
    public Page<Item> findAll(Pageable pageable) {
        if (useJoinFetch) {
            return itemRepository.findAllWithCategory(pageable);
        }
        return itemRepository.findAll(pageable);
    }
    
    public Page<Item> findByCategoryId(Long categoryId, Pageable pageable) {
        return itemRepository.findByCategoryId(categoryId, pageable);
    }
    
    public Optional<Item> findById(Long id) {
        if (useJoinFetch) {
            return itemRepository.findByIdWithCategory(id);
        }
        return itemRepository.findById(id);
    }
    
    public Optional<Item> findBySku(String sku) {
        return itemRepository.findBySku(sku);
    }
    
    public Item save(Item item) {
        return itemRepository.save(item);
    }
    
    public void deleteById(Long id) {
        itemRepository.deleteById(id);
    }
    
    public long count() {
        return itemRepository.count();
    }
}