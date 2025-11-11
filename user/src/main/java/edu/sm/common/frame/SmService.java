package edu.sm.common.frame;

import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface SmService<V,K> {
    @Transactional
    void register(V v) throws Exception;
    @Transactional
    void modify(V v) throws Exception;
    @Transactional
    void remove(K k) throws Exception;
    List<V> get() throws Exception;
    V get(K k) throws Exception;
}