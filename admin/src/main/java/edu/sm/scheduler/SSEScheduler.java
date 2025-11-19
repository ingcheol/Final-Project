package edu.sm.scheduler;

import edu.sm.app.dto.AdminMsg;
import edu.sm.sse.SseEmitters;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Random;

@Component
@Slf4j
@RequiredArgsConstructor
public class SSEScheduler {

    private final SseEmitters sseEmitters;

    @Scheduled(cron = "*/10 * * * * *")
    public void sendCount() {

        Random r = new Random();
        int count = r.nextInt(1000)+1;
        sseEmitters.count(count);
    }

    @Scheduled(cron = "*/5 * * * * *")
    public void cronJobDailyUpdate() {
        log.info("====================================================");
        Random r = new Random();
        int content1 = r.nextInt(100)+1;
        int content2 = r.nextInt(1000)+1;
        int content3 = r.nextInt(500)+1;
        int content4 = r.nextInt(10)+1;
        AdminMsg adminMsg = new AdminMsg();
        adminMsg.setContent1(content1);
        adminMsg.setContent2(content2);
        adminMsg.setContent3(content3);
        adminMsg.setContent4(content4);

        sseEmitters.sendData(adminMsg);
       // sseEmitters.count();
//        simpMessageSendingOperations.convertAndSend("/send2",adminMsg);
    }

}