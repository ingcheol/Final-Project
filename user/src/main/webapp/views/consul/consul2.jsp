<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>상담 신청 - AI 의료 매칭 시스템</title>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;600;700&display=swap" rel="stylesheet">

  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 20px;
    }

    .container {
      background: white;
      border-radius: 20px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.3);
      max-width: 700px;
      width: 100%;
      padding: 50px;
    }

    .header {
      text-align: center;
      margin-bottom: 40px;
    }

    .header h1 {
      color: #667eea;
      font-size: 32px;
      margin-bottom: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 10px;
    }

    .header p {
      color: #666;
      font-size: 16px;
    }

    .form-group {
      margin-bottom: 30px;
    }

    .form-group label {
      display: block;
      font-weight: 600;
      color: #333;
      margin-bottom: 10px;
      font-size: 16px;
    }

    .form-group label .required {
      color: #e74c3c;
      margin-left: 4px;
    }

    .form-group input[type="text"],
    .form-group input[type="date"],
    .form-group input[type="time"],
    .form-group select,
    .form-group textarea {
      width: 100%;
      padding: 15px;
      border: 2px solid #e0e0e0;
      border-radius: 12px;
      font-size: 15px;
      font-family: 'Noto Sans KR', sans-serif;
      transition: all 0.3s;
    }

    .form-group input:focus,
    .form-group select:focus,
    .form-group textarea:focus {
      outline: none;
      border-color: #667eea;
      box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    .form-group textarea {
      min-height: 150px;
      resize: vertical;
    }

    .date-time-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 15px;
    }

    .info-box {
      background: #f8f9ff;
      border-left: 4px solid #667eea;
      padding: 15px;
      border-radius: 8px;
      margin-bottom: 30px;
    }

    .info-box p {
      color: #555;
      font-size: 14px;
      line-height: 1.6;
    }

    .info-box ul {
      margin-top: 10px;
      margin-left: 20px;
      color: #555;
      font-size: 14px;
    }

    .info-box li {
      margin-bottom: 5px;
    }

    .btn-container {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 15px;
      margin-top: 40px;
    }

    .btn {
      padding: 18px;
      border: none;
      border-radius: 12px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
      font-family: 'Noto Sans KR', sans-serif;
    }

    .btn-primary {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }

    .btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
    }

    .btn-secondary {
      background: white;
      color: #666;
      border: 2px solid #e0e0e0;
    }

    .btn-secondary:hover {
      border-color: #667eea;
      color: #667eea;
    }

    .time-slots {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 10px;
      margin-top: 10px;
    }

    .time-slot {
      padding: 12px;
      border: 2px solid #e0e0e0;
      border-radius: 8px;
      text-align: center;
      cursor: pointer;
      transition: all 0.3s;
      font-size: 14px;
      font-weight: 500;
    }

    .time-slot:hover {
      border-color: #667eea;
      background: #f8f9ff;
    }

    .time-slot.selected {
      background: #667eea;
      color: white;
      border-color: #667eea;
    }

    .time-slot.disabled {
      background: #f5f5f5;
      color: #ccc;
      cursor: not-allowed;
      border-color: #e0e0e0;
    }

    .time-slot.disabled:hover {
      background: #f5f5f5;
      border-color: #e0e0e0;
    }

    @media (max-width: 768px) {
      .container {
        padding: 30px 20px;
      }

      .header h1 {
        font-size: 24px;
      }

      .date-time-row {
        grid-template-columns: 1fr;
      }

      .time-slots {
        grid-template-columns: repeat(3, 1fr);
      }

      .btn-container {
        grid-template-columns: 1fr;
      }
    }
  </style>
</head>
<body>
<div class="container">
  <div class="header">
    <h1>💬 상담 신청</h1>
    <p>전문 상담사와의 1:1 상담을 예약하세요</p>
  </div>

  <div class="info-box">
    <p><strong>📌 상담 안내</strong></p>
    <ul>
      <li>상담 시간은 30분 단위로 진행됩니다</li>
      <li>예약은 현재 시간 이후부터 가능합니다</li>
      <li>상담 시간: 평일 09:00 ~ 18:00</li>
    </ul>
  </div>

  <form id="consultForm" action="${pageContext.request.contextPath}/consul/consul2" method="post">

    <!-- 상담 내용 -->
    <div class="form-group">
      <label for="consultContent">
        상담 내용
        <span class="required">*</span>
      </label>
      <textarea
              id="consultContent"
              name="consultContent"
              placeholder="상담하고 싶은 내용을 자세히 적어주세요&#10;예) 건강검진 결과 상담, 만성질환 관리, 증상 관련 문의 등"
              required
      ></textarea>
    </div>

    <!-- 상담 날짜 -->
    <div class="form-group">
      <label for="consultDate">
        상담 희망 날짜
        <span class="required">*</span>
      </label>
      <input
              type="date"
              id="consultDate"
              name="consultDate"
              required
      >
    </div>

    <!-- 상담 시간 선택 -->
    <div class="form-group">
      <label>
        상담 희망 시간
        <span class="required">*</span>
      </label>
      <input type="hidden" id="consultTime" name="consultTime" required>
      <div class="time-slots" id="timeSlots">
        <!-- JavaScript로 동적 생성 -->
      </div>
    </div>

    <!-- 연락처 -->
    <div class="form-group">
      <label for="phone">
        연락처
        <span class="required">*</span>
      </label>
      <input
              type="text"
              id="phone"
              name="phone"
              placeholder="010-1234-5678"
              pattern="[0-9]{3}-[0-9]{4}-[0-9]{4}"
              required
      >
    </div>

    <!-- 버튼 -->
    <div class="btn-container">
      <button type="button" class="btn btn-secondary" onclick="history.back()">
        취소
      </button>
      <button type="submit" class="btn btn-primary">
        상담 신청하기
      </button>
    </div>
  </form>
</div>

<script>
  // 오늘 날짜를 최소값으로 설정
  const today = new Date();
  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, '0');
  const day = String(today.getDate()).padStart(2, '0');
  const minDate = `${year}-${month}-${day}`;

  document.getElementById('consultDate').min = minDate;
  document.getElementById('consultDate').value = minDate;

  // 상담 가능 시간대 (09:00 ~ 18:00, 30분 단위)
  const timeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30'
  ];

  // 시간 슬롯 생성
  function generateTimeSlots(selectedDate) {
    const timeSlotsContainer = document.getElementById('timeSlots');
    timeSlotsContainer.innerHTML = '';

    const now = new Date();
    const isToday = selectedDate === minDate;

    timeSlots.forEach(time => {
      const slot = document.createElement('div');
      slot.className = 'time-slot';
      slot.textContent = time;
      slot.dataset.time = time;

      // 오늘 날짜인 경우, 현재 시간 이전 슬롯은 비활성화
      if (isToday) {
        const [hour, minute] = time.split(':').map(Number);
        const slotTime = new Date(now);
        slotTime.setHours(hour, minute, 0, 0);

        if (slotTime <= now) {
          slot.classList.add('disabled');
          return;
        }
      }

      slot.addEventListener('click', function() {
        if (this.classList.contains('disabled')) return;

        // 기존 선택 해제
        document.querySelectorAll('.time-slot').forEach(s => {
          s.classList.remove('selected');
        });

        // 새로운 선택
        this.classList.add('selected');
        document.getElementById('consultTime').value = this.dataset.time;
      });

      timeSlotsContainer.appendChild(slot);
    });
  }

  // 날짜 변경 시 시간 슬롯 재생성
  document.getElementById('consultDate').addEventListener('change', function() {
    generateTimeSlots(this.value);
    document.getElementById('consultTime').value = ''; // 선택 초기화
  });

  // 초기 시간 슬롯 생성
  generateTimeSlots(minDate);

  // 폼 제출 전 검증
  document.getElementById('consultForm').addEventListener('submit', function(e) {
    const consultContent = document.getElementById('consultContent').value.trim();
    const consultDate = document.getElementById('consultDate').value;
    const consultTime = document.getElementById('consultTime').value;
    const phone = document.getElementById('phone').value.trim();

    if (!consultContent) {
      e.preventDefault();
      alert('상담 내용을 입력해주세요.');
      return;
    }

    if (!consultDate) {
      e.preventDefault();
      alert('상담 날짜를 선택해주세요.');
      return;
    }

    if (!consultTime) {
      e.preventDefault();
      alert('상담 시간을 선택해주세요.');
      return;
    }

    if (!phone) {
      e.preventDefault();
      alert('연락처를 입력해주세요.');
      return;
    }

    console.log('=== 상담 신청 데이터 ===');
    console.log('상담 내용:', consultContent);
    console.log('날짜:', consultDate);
    console.log('시간:', consultTime);
    console.log('연락처:', phone);
  });

  // 연락처 자동 하이픈 추가
  document.getElementById('phone').addEventListener('input', function(e) {
    let value = e.target.value.replace(/[^0-9]/g, '');

    if (value.length > 3 && value.length <= 7) {
      value = value.slice(0, 3) + '-' + value.slice(3);
    } else if (value.length > 7) {
      value = value.slice(0, 3) + '-' + value.slice(3, 7) + '-' + value.slice(7, 11);
    }

    e.target.value = value;
  });
</script>
</body>
</html>