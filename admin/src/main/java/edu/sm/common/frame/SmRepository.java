package edu.sm.common.frame;

import java.util.List;

public interface SmRepository<V,K> {
    // Database에 CRUD 기능 정의
    // INSERT(C), SELECT(R), UPDATE(U), DELETE(D)
    void insert(V v) throws Exception;
    void update(V v) throws Exception;;
    void delete(K k) throws Exception;;
    List<V> selectAll() throws Exception;;
    V select(K k) throws Exception;;
}