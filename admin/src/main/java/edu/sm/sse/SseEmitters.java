package edu.sm.sse;

import edu.sm.app.dto.AdminMsg;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class SseEmitters {
    private final Map<String, SseEmitter> emitters = new ConcurrentHashMap<>();

    public void sendData(AdminMsg adminMsg) {

        this.emitters.keySet().stream().filter(s->s.equals("admin") || s.equals("admin2")).forEach(key -> {
            try {
                log.info("-------------------------------------"+key.toString());
                this.emitters.get(key).send(SseEmitter.event()
                        .name("adminmsg")
                        .data(adminMsg));
            } catch ( IOException e) {
                throw new RuntimeException(e);
            }
        });
    }
    public void count(int num) {

        this.emitters.values().forEach(emitter -> {
            try {
                emitter.send(SseEmitter.event()
                        .name("count")
                        .data(num));
            } catch ( IOException e) {
                throw new RuntimeException(e);
            }
        });
    }
    public SseEmitter add(String clientId, SseEmitter emitter) {
        this.emitters.put(clientId,emitter);
        log.info("new emitter added: {}", emitter);
        log.info("emitter list size: {}", emitters.size());

        // 연결 완료, 오류, 타임아웃 이벤트 핸들러 등록
        emitter.onCompletion(() -> {
            log.info("onCompletion: {}", emitter);

            emitters.remove(clientId);
            cleanupEmitter(emitter);
        });
        emitter.onError((ex) -> {
            log.info("onError:---------------------------- ");

            emitters.remove(clientId);
            cleanupEmitter(emitter);
        });
        emitter.onTimeout(() -> {
            emitters.remove(clientId);
            cleanupEmitter(emitter);
        });
        return emitter;
    }
    public void close(String clientId) {
        emitters.remove(clientId);
        log.info("new emitter close...........: {}", clientId);
    }
    private void cleanupEmitter(SseEmitter emitter) {
        try {
            emitter.complete();
        } catch (Exception e) {
            // 예외 처리
        }
    }
}