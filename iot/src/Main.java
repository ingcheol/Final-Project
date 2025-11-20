import util.HttpSendData;

import java.io.IOException;
import java.util.Random;

public class Main {
  public static void main(String[] args) {
    // 서버 URL (User 애플리케이션의 IP와 포트에 맞게 수정)
    String url = "https://127.0.0.1:8444/iot/data";
    long patientId = 1L; // 데이터를 전송할 환자 ID (테스트용)

    Random r = new Random();

    // 무한 루프로 주기적 데이터 전송
    while (true) {
      try {
        // 1. 심박수 (60 ~ 100 bpm 정상 범위)
        double heartRate = 60 + r.nextInt(41);
        sendData(url, patientId, "SmartWatch", "HEART_RATE", heartRate);

        // 2. 체온 (36.5도 기준 +- 랜덤)
        double temp = 37.0 + (r.nextInt(15) / 10.0);
        sendData(url, patientId, "Thermometer", "TEMPERATURE", temp);

        // 3. 혈당 (70 ~ 140 mg/dL)
        double bloodSugar = 70 + r.nextInt(71);
        sendData(url, patientId, "Glucometer", "BLOOD_SUGAR", bloodSugar);

        // 4. 혈압 (수축기: 90~120, 이완기: 60~80)
        double sysBp = 90 + r.nextInt(31);
        double diaBp = 60 + r.nextInt(21);
        sendData(url, patientId, "BloodPressureMonitor", "BP_SYSTOLIC", sysBp);
        sendData(url, patientId, "BloodPressureMonitor", "BP_DIASTOLIC", diaBp);

        System.out.println("Sent vital data for patient " + patientId);

        // 5초마다 전송
        Thread.sleep(5000);

      } catch (Exception e) {
        e.printStackTrace();
        System.out.println("Retrying...");
        try { Thread.sleep(5000); } catch (InterruptedException ex) {}
      }
    }
  }

  private static void sendData(String baseUrl, long patientId, String device, String type, double value) throws IOException {
    // 쿼리 스트링 구성: ?patientId=1&deviceType=SmartWatch&vitalType=HEART_RATE&value=75.0
    String queryString = "?patientId=" + patientId +
        "&deviceType=" + device +
        "&vitalType=" + type +
        "&value=" + value;

    HttpSendData.send(baseUrl, queryString);
  }
}