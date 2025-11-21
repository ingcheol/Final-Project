<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI 약물 일정 관리</title>
    <link href='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.css' rel='stylesheet' />
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js'></script>
    <script src='https://cdn.jsdelivr.net/npm/@fullcalendar/core@6.1.10/locales-all.global.min.js'></script>

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f7fa; }

        .calendar-section { max-width: 1200px; margin: 40px auto; padding: 0 15px; }
        #header-title { font-size: 28px; margin-bottom: 10px; color: #333; }
        #header-desc { color: #666; margin-bottom: 20px; }

        .calendar-controls { margin-bottom: 20px; padding: 15px; background: #fff; border: 1px solid #ddd; border-radius: 8px; display: flex; flex-wrap: wrap; gap: 10px; align-items: center; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        #header-controls { display: flex; gap: 8px; flex-wrap: wrap; }
        #header-controls button { padding: 10px 15px; border: 1px solid #ccc; cursor: pointer; border-radius: 4px; font-size: 14px; font-weight: 600; transition: all 0.3s ease; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.1); min-width: 80px; background: #fff; color: #333; }
        #header-controls button:hover { background: #f0f0f0; transform: translateY(-1px); box-shadow: 0 2px 6px rgba(0,0,0,0.15); }

        #add-manual-event { background-color: #ffc000 !important; color: #333 !important; border-color: #ffc000 !important; }
        #add-manual-event:hover { background-color: #e5a700 !important; }
        #scan-med-btn { background-color: #5b9bd5 !important; color: white !important; border-color: #5b9bd5 !important; }
        #scan-med-btn:hover { background-color: #4a8ac1 !important; }
        #speech-input-btn { background-color: #70ad47 !important; color: white !important; border-color: #70ad47 !important; }
        #speech-input-btn:hover { background-color: #5d9337 !important; }

        #calendar { border: 1px solid #ddd; padding: 15px; background: #fff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }

        .today-schedule-panel { position: fixed; right: -450px; top: 50%; transform: translateY(-50%); width: 420px; max-height: 85vh; background: white; box-shadow: -4px 0 20px rgba(0,0,0,0.2); transition: right 0.3s ease; z-index: 999; overflow-y: auto; border-radius: 12px 0 0 12px; }
        .today-schedule-panel.open { right: 0; }
        .panel-header { padding: 20px; background: linear-gradient(135deg, #5b9bd5 0%, #4a8ac1 100%); color: white; position: sticky; top: 0; z-index: 10; }
        .panel-header h3 { margin: 0 0 5px 0; font-size: 20px; }
        .panel-header .date-info { font-size: 14px; opacity: 0.9; }
        .panel-close { position: absolute; right: 15px; top: 15px; background: rgba(255,255,255,0.3); border: none; color: white; font-size: 28px; cursor: pointer; width: 40px; height: 40px; border-radius: 50%; transition: all 0.2s; display: flex; align-items: center; justify-content: center; font-weight: bold; line-height: 1; }
        .panel-close:hover { background: rgba(255,255,255,0.5); transform: rotate(90deg); }
        .panel-content { padding: 20px; }

        .schedule-item { background: #f8f9fa; border-left: 4px solid #5b9bd5; padding: 15px; margin-bottom: 12px; border-radius: 6px; transition: all 0.2s; cursor: pointer; }
        .schedule-item:hover { transform: translateX(-5px); box-shadow: 0 2px 8px rgba(0,0,0,0.1); background: #e8f4ff; }
        .schedule-item.medication { border-left-color: #ff7f50; }
        .schedule-item-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
        .schedule-item-title { font-weight: 600; font-size: 15px; color: #333; }
        .schedule-item-time { font-size: 13px; color: #666; background: white; padding: 2px 8px; border-radius: 4px; }
        .schedule-item-desc { font-size: 13px; color: #666; line-height: 1.5; }

        .no-schedule { text-align: center; padding: 40px 20px; color: #999; }
        .no-schedule-icon { font-size: 48px; margin-bottom: 10px; }
        .notification-badge { position: absolute; top: -5px; right: -5px; background: #ff4444; color: white; font-size: 11px; padding: 2px 6px; border-radius: 10px; font-weight: 600; }

        .fc-daygrid-day-frame { position: relative; cursor: pointer; }
        .fc-daygrid-day-top { display: flex; justify-content: space-between; align-items: center; }
        .add-event-btn { width: 18px; height: 18px; border-radius: 50%; background: #5b9bd5; color: white; border: none; cursor: pointer; font-size: 14px; line-height: 16px; opacity: 0; transition: all 0.2s; z-index: 10; display: flex; align-items: center; justify-content: center; margin-right: 4px; }
        .fc-daygrid-day:hover .add-event-btn { opacity: 1; }
        .add-event-btn:hover { background: #4a8ac1; transform: scale(1.15); }

        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.5); animation: fadeIn 0.3s; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        .modal-content { background-color: #fff; margin: 5% auto; padding: 30px; border: none; width: 90%; max-width: 500px; border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.2); animation: slideDown 0.3s; }
        @keyframes slideDown { from { transform: translateY(-50px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        .modal-content h3 { border-bottom: 2px solid #5b9bd5; padding-bottom: 10px; margin-bottom: 20px; color: #333; }
        .close { color: #aaa; float: right; font-size: 28px; font-weight: bold; line-height: 20px; cursor: pointer; transition: color 0.2s; }
        .close:hover, .close:focus { color: #000; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #555; }
        .form-group input[type="text"], .form-group input[type="date"], .form-group input[type="time"], .form-group textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; transition: border-color 0.3s; }
        .form-group input:focus, .form-group textarea:focus { outline: none; border-color: #5b9bd5; box-shadow: 0 0 0 3px rgba(91, 155, 213, 0.1); }
        .form-group textarea { resize: vertical; min-height: 80px; font-family: inherit; }

        .modal-buttons { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; }
        .modal-buttons button { padding: 10px 20px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 600; transition: all 0.3s; }
        .btn-primary { background-color: #5b9bd5; color: white; }
        .btn-primary:hover { background-color: #4a8ac1; }
        .btn-primary:disabled { background-color: #ccc; cursor: not-allowed; }
        .btn-secondary { background-color: #e0e0e0; color: #333; }
        .btn-secondary:hover { background-color: #d0d0d0; }

        .toast { position: fixed; bottom: 30px; right: 30px; background: #333; color: white; padding: 15px 20px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.3); z-index: 2000; animation: slideInRight 0.3s, fadeOut 0.3s 2.7s; max-width: 300px; }
        @keyframes slideInRight { from { transform: translateX(400px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        @keyframes fadeOut { to { opacity: 0; } }
        .toast.success { background: #70ad47; }
        .toast.error { background: #d9534f; }
        .toast.info { background: #5b9bd5; }

        .ai-badge { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; margin-left: 8px; }

        .file-upload-wrapper { position: relative; display: inline-block; width: 100%; }
        .file-upload-wrapper input[type="file"] { position: absolute; opacity: 0; width: 100%; height: 100%; cursor: pointer; z-index: 2; }
        .file-upload-label { display: flex; align-items: center; justify-content: center; padding: 30px; border: 2px dashed #ddd; border-radius: 8px; background: #f9f9f9; cursor: pointer; transition: all 0.3s; font-size: 15px; color: #666; }
        .file-upload-label:hover { border-color: #5b9bd5; background: #f0f7ff; }
        .file-upload-label.has-file { border-color: #70ad47; background: #f0f9f0; color: #70ad47; }

        #image-preview { margin-top: 15px; text-align: center; }
        #preview-img { max-width: 100%; max-height: 300px; border-radius: 8px; border: 2px solid #ddd; }
    </style>
</head>
<body>

<section class="calendar-section">
    <h2 id="header-title">📅 AI 약물 일정 관리</h2>
    <p id="header-desc">약봉투를 업로드하거나 음성으로 일정을 추가해보세요.</p>

    <div class="calendar-controls">
        <div id="header-controls">
            <button onclick="calendarManager.toggleTodayPanel()" data-key="todaySchedule" style="position: relative;">
                📋 오늘 일정
                <span class="notification-badge" id="today-count" style="display: none;">0</span>
            </button>
            <button onclick="calendarManager.goToToday()" data-key="today">오늘로 이동</button>
            <button onclick="calendarManager.clearEvents()" data-key="clearEvents">일정 초기화</button>
            <button id="add-manual-event" onclick="calendarManager.openQuickAddModal()" data-key="addManualEvent">
                ✍️ 일정 추가 <span class="ai-badge">AI</span>
            </button>
            <button id="scan-med-btn" onclick="calendarManager.openMedicationModal()" data-key="scanButton">
                💊 약봉투 스캔
            </button>
            <button id="speech-input-btn" onclick="calendarManager.startSpeechInput()" data-key="voiceButton">
                🎙️ 음성 입력
            </button>
        </div>
    </div>

    <div id="calendar"></div>
</section>

<!-- 오늘 일정 패널 -->
<div id="todaySchedulePanel" class="today-schedule-panel">
    <div class="panel-header">
        <button class="panel-close" onclick="calendarManager.closeTodayPanel()">✕</button>
        <h3>📋 오늘의 일정</h3>
        <div class="date-info" id="panel-date-info"></div>
    </div>
    <div class="panel-content" id="today-schedule-list">
        <div class="no-schedule">
            <div class="no-schedule-icon">📭</div>
            <p>오늘은 일정이 없습니다</p>
        </div>
    </div>
</div>

<!-- 빠른 일정 추가 모달 -->
<div id="quickAddModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="calendarManager.closeQuickAddModal()">&times;</span>
        <h3>✍️ 일정 추가 <span class="ai-badge">AI 자동 분석</span></h3>

        <div class="form-group">
            <label for="quick-event-input">일정 내용을 자유롭게 입력하세요</label>
            <textarea id="quick-event-input" rows="3" placeholder="예: 다음주 수요일 오후 3시 병원 예약&#10;예: 내일 저녁 7시 약 복용&#10;예: 12월 25일 건강검진" style="font-size: 15px;"></textarea>
            <small style="color: #666; margin-top: 5px; display: block;">
                💡 날짜, 시간, 내용을 자유롭게 입력하면 AI가 자동으로 분석합니다
            </small>
        </div>

        <div class="modal-buttons">
            <button class="btn-secondary" onclick="calendarManager.closeQuickAddModal()">취소</button>
            <button class="btn-primary" onclick="calendarManager.saveQuickEvent()">일정 추가</button>
        </div>
    </div>
</div>

<!-- 날짜별 일정 추가 모달 -->
<div id="dateEventModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="calendarManager.closeDateEventModal()">&times;</span>
        <h3 id="date-modal-title">📝 일정 추가</h3>

        <div class="form-group">
            <label for="date-event-title">제목</label>
            <input type="text" id="date-event-title" placeholder="일정 제목을 입력하세요">
        </div>

        <div class="form-group">
            <label for="date-event-time">시간 (선택)</label>
            <input type="time" id="date-event-time">
        </div>

        <div class="form-group">
            <label for="date-event-desc">메모</label>
            <textarea id="date-event-desc" rows="4" placeholder="추가 메모사항을 입력하세요"></textarea>
        </div>

        <div class="modal-buttons">
            <button class="btn-secondary" onclick="calendarManager.closeDateEventModal()">취소</button>
            <button class="btn-primary" onclick="calendarManager.saveDateEvent()">저장</button>
        </div>
    </div>
</div>

<!-- 약물 정보 입력 모달 -->
<div id="medicationModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="calendarManager.closeMedicationModal()">&times;</span>
        <h3>💊 약물 정보 입력 <span class="ai-badge">AI 분석</span></h3>

        <div class="form-group">
            <label>약봉투 이미지 업로드</label>
            <div class="file-upload-wrapper">
                <input type="file" id="modal-image-upload" accept="image/*" onchange="calendarManager.handleFileSelect(this)">
                <div class="file-upload-label" id="file-upload-display">
                    📷 이미지 선택 또는 드래그&드롭
                </div>
            </div>
            <div id="image-preview" style="display: none;">
                <img id="preview-img" alt="미리보기">
            </div>
        </div>

        <div class="form-group">
            <label for="modal-text-input">또는 약물 정보 직접 입력</label>
            <textarea id="modal-text-input" rows="5" placeholder="예: 톡스엔정 1일 1회 저녁 식후 2일치&#10;펠루스정 1일 3회 식후 5일치"></textarea>
        </div>

        <div class="modal-buttons">
            <button class="btn-secondary" onclick="calendarManager.closeMedicationModal()">취소</button>
            <button class="btn-primary" id="modal-submit-btn" onclick="calendarManager.processModalInput()">일정 추가</button>
        </div>
    </div>
</div>

<script>
    // Toast 알림
    function showToast(message, type) {
        type = type || 'success';
        const toast = document.createElement('div');
        toast.className = 'toast ' + type;
        toast.textContent = message;
        document.body.appendChild(toast);
        setTimeout(function() { toast.remove(); }, 3000);
    }

    // Calendar Manager
    const calendarManager = {
        calendar: null,
        selectedDate: null,
        todayPanelOpen: false,
        recognition: null,
        imageData: null,
        speechSynthesis: window.speechSynthesis,

        // 음성 출력 함수
        speak: function(text) {
            if (!this.speechSynthesis) {
                console.log('음성 합성을 지원하지 않는 브라우저입니다.');
                return;
            }

            // 이전 음성 중지
            this.speechSynthesis.cancel();

            const utterance = new SpeechSynthesisUtterance(text);
            utterance.lang = 'ko-KR';
            utterance.rate = 0.9; // 속도 (0.1 ~ 10)
            utterance.pitch = 1; // 음높이 (0 ~ 2)
            utterance.volume = 1; // 볼륨 (0 ~ 1)

            this.speechSynthesis.speak(utterance);
        },

        init: function() {
            const calendarEl = document.getElementById('calendar');
            if (!calendarEl) return;

            this.calendar = new FullCalendar.Calendar(calendarEl, {
                initialDate: new Date(),
                initialView: 'dayGridMonth',
                locale: 'ko',
                height: 'auto',
                headerToolbar: {
                    left: 'prev,next',
                    center: 'title',
                    right: 'dayGridMonth,dayGridWeek'
                },
                eventClick: (info) => {
                    this.showEventDetail(info.event);
                },
                datesSet: () => {
                    setTimeout(() => this.addPlusButtons(), 100);
                    this.updateTodaySchedule();
                },
                eventDidMount: (info) => {
                    this.checkUpcomingNotifications(info.event);
                }
            });

            this.calendar.render();
            this.addPlusButtons();
            this.updateTodaySchedule();
            this.setupNotificationCheck();
            this.initSpeechRecognition();
            this.setupDragAndDrop();
        },

        // 드래그앤드롭 설정
        setupDragAndDrop: function() {
            const dropZone = document.getElementById('file-upload-display');
            if (!dropZone) return;

            ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
                dropZone.addEventListener(eventName, (e) => {
                    e.preventDefault();
                    e.stopPropagation();
                });
            });

            ['dragenter', 'dragover'].forEach(eventName => {
                dropZone.addEventListener(eventName, () => {
                    dropZone.style.borderColor = '#5b9bd5';
                    dropZone.style.background = '#f0f7ff';
                });
            });

            ['dragleave', 'drop'].forEach(eventName => {
                dropZone.addEventListener(eventName, () => {
                    dropZone.style.borderColor = '#ddd';
                    dropZone.style.background = '#f9f9f9';
                });
            });

            dropZone.addEventListener('drop', (e) => {
                const files = e.dataTransfer.files;
                if (files.length > 0) {
                    const input = document.getElementById('modal-image-upload');
                    input.files = files;
                    this.handleFileSelect(input);
                }
            });
        },

        // 음성 인식 초기화
        initSpeechRecognition: function() {
            if (!('webkitSpeechRecognition' in window) && !('SpeechRecognition' in window)) {
                console.log('음성 인식을 지원하지 않는 브라우저입니다.');
                return;
            }

            const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
            this.recognition = new SpeechRecognition();
            this.recognition.lang = 'ko-KR';
            this.recognition.continuous = false;
            this.recognition.interimResults = false;

            this.recognition.onresult = (event) => {
                const transcript = event.results[0][0].transcript;
                this.processSpeechInput(transcript);
            };

            this.recognition.onerror = (event) => {
                showToast('음성 인식 오류: ' + event.error, 'error');
            };

            this.recognition.onend = () => {
                document.getElementById('speech-input-btn').textContent = '🎙️ 음성 입력';
            };
        },

        // 음성 입력 시작
        startSpeechInput: function() {
            if (!this.recognition) {
                showToast('음성 인식을 지원하지 않는 브라우저입니다', 'error');
                return;
            }

            const btn = document.getElementById('speech-input-btn');
            btn.textContent = '🎤 듣는 중...';
            showToast('음성 인식을 시작합니다. 말씀해주세요...', 'info');

            try {
                this.recognition.start();
            } catch(e) {
                console.error('음성 인식 시작 오류:', e);
                btn.textContent = '🎙️ 음성 입력';
            }
        },

        // 음성 입력 처리
        processSpeechInput: function(text) {
            showToast('인식: ' + text, 'success');

            const parsed = this.parseNaturalLanguage(text);

            this.addEvents([{
                title: parsed.title,
                start: parsed.date,
                backgroundColor: '#70ad47',
                borderColor: '#70ad47',
                extendedProps: {
                    time: parsed.time || '',
                    desc: '음성 입력 일정',
                    type: 'voice'
                }
            }]);

            showToast('일정이 추가되었습니다', 'success');
        },

        // AI 자연어 파싱 (개선 버전)
        parseNaturalLanguage: function(text) {
            let date = new Date();
            let title = text;
            let time = '';

            // 날짜 파싱
            if (text.includes('오늘')) {
                // 오늘 그대로
            } else if (text.includes('내일')) {
                date.setDate(date.getDate() + 1);
            } else if (text.includes('모레')) {
                date.setDate(date.getDate() + 2);
            } else if (text.includes('다음주')) {
                date.setDate(date.getDate() + 7);
                // 요일 파싱
                if (text.includes('월요일')) date.setDate(date.getDate() + (1 - date.getDay() + 7) % 7);
                else if (text.includes('화요일')) date.setDate(date.getDate() + (2 - date.getDay() + 7) % 7);
                else if (text.includes('수요일')) date.setDate(date.getDate() + (3 - date.getDay() + 7) % 7);
                else if (text.includes('목요일')) date.setDate(date.getDate() + (4 - date.getDay() + 7) % 7);
                else if (text.includes('금요일')) date.setDate(date.getDate() + (5 - date.getDay() + 7) % 7);
                else if (text.includes('토요일')) date.setDate(date.getDate() + (6 - date.getDay() + 7) % 7);
                else if (text.includes('일요일')) date.setDate(date.getDate() + (7 - date.getDay() + 7) % 7);
            }

            // 특정 날짜 파싱 (12월 25일, 12/25)
            const datePattern1 = text.match(/(\d{1,2})월\s*(\d{1,2})일/);
            const datePattern2 = text.match(/(\d{1,2})\/(\d{1,2})/);
            if (datePattern1) {
                date.setMonth(parseInt(datePattern1[1]) - 1);
                date.setDate(parseInt(datePattern1[2]));
            } else if (datePattern2) {
                date.setMonth(parseInt(datePattern2[1]) - 1);
                date.setDate(parseInt(datePattern2[2]));
            }

            // 시간 파싱 (오전/오후, 24시간제)
            let hour = null;
            let minute = 0;

            // "오후 3시", "오전 9시" 형태
            const ampmMatch = text.match(/(오전|오후)\s*(\d{1,2})시/);
            if (ampmMatch) {
                hour = parseInt(ampmMatch[2]);
                if (ampmMatch[1] === '오후' && hour !== 12) hour += 12;
                if (ampmMatch[1] === '오전' && hour === 12) hour = 0;
            }

            // "15시", "9시" 형태
            const hourMatch = text.match(/(\d{1,2})시/);
            if (hourMatch && !ampmMatch) {
                hour = parseInt(hourMatch[1]);
            }

            // "30분", "반" 형태
            const minuteMatch = text.match(/(\d{1,2})분/);
            if (minuteMatch) {
                minute = parseInt(minuteMatch[1]);
            } else if (text.includes('반')) {
                minute = 30;
            }

            if (hour !== null) {
                time = String(hour).padStart(2, '0') + ':' + String(minute).padStart(2, '0');
            }

            // 제목 정리 (날짜/시간 표현 제거)
            title = text
                .replace(/오늘|내일|모레|다음주/g, '')
                .replace(/월요일|화요일|수요일|목요일|금요일|토요일|일요일/g, '')
                .replace(/\d{1,2}월\s*\d{1,2}일/g, '')
                .replace(/\d{1,2}\/\d{1,2}/g, '')
                .replace(/(오전|오후)\s*\d{1,2}시/g, '')
                .replace(/\d{1,2}시/g, '')
                .replace(/\d{1,2}분/g, '')
                .replace(/반/g, '')
                .trim();

            // 제목이 비어있으면 원본 사용
            if (!title) title = text;

            return {
                title: title,
                date: date.toISOString().split('T')[0],
                time: time
            };
        },

        // + 버튼 추가
        addPlusButtons: function() {
            const dayCells = document.querySelectorAll('.fc-daygrid-day');
            dayCells.forEach(cell => {
                const topEl = cell.querySelector('.fc-daygrid-day-top');
                if (topEl && !topEl.querySelector('.add-event-btn')) {
                    const btn = document.createElement('button');
                    btn.className = 'add-event-btn';
                    btn.innerHTML = '+';
                    btn.onclick = (e) => {
                        e.stopPropagation();
                        const dateStr = cell.getAttribute('data-date');
                        this.openDateEventModal(dateStr);
                    };
                    topEl.appendChild(btn);
                }
            });
        },

        // 빠른 추가 모달
        openQuickAddModal: function() {
            document.getElementById('quickAddModal').style.display = 'block';
            document.getElementById('quick-event-input').focus();
        },

        closeQuickAddModal: function() {
            document.getElementById('quickAddModal').style.display = 'none';
            document.getElementById('quick-event-input').value = '';
        },

        saveQuickEvent: function() {
            const input = document.getElementById('quick-event-input').value.trim();
            if (!input) {
                showToast('일정 내용을 입력해주세요', 'error');
                return;
            }

            const parsed = this.parseNaturalLanguage(input);
            this.addEvents([{
                title: parsed.title,
                start: parsed.date,
                backgroundColor: '#ffc000',
                borderColor: '#ffc000',
                extendedProps: {
                    time: parsed.time || '',
                    desc: '사용자 추가 일정',
                    type: 'user'
                }
            }]);

            showToast(parsed.title + ' 일정이 추가되었습니다', 'success');
            this.closeQuickAddModal();
        },

        // 날짜별 일정 모달
        openDateEventModal: function(dateStr) {
            this.selectedDate = dateStr;
            const date = new Date(dateStr + 'T00:00:00');
            const formattedDate = (date.getMonth() + 1) + '월 ' + date.getDate() + '일';
            document.getElementById('date-modal-title').textContent = '📝 ' + formattedDate + ' 일정 추가';
            document.getElementById('dateEventModal').style.display = 'block';
            document.getElementById('date-event-title').focus();
        },

        closeDateEventModal: function() {
            document.getElementById('dateEventModal').style.display = 'none';
            document.getElementById('date-event-title').value = '';
            document.getElementById('date-event-time').value = '';
            document.getElementById('date-event-desc').value = '';
        },

        saveDateEvent: function() {
            const title = document.getElementById('date-event-title').value.trim();
            if (!title) {
                showToast('제목을 입력해주세요', 'error');
                return;
            }

            const time = document.getElementById('date-event-time').value;
            const desc = document.getElementById('date-event-desc').value;

            this.addEvents([{
                title: title,
                start: this.selectedDate,
                backgroundColor: '#70ad47',
                borderColor: '#70ad47',
                extendedProps: {
                    time: time,
                    desc: desc,
                    type: 'appointment'
                }
            }]);

            showToast('일정이 추가되었습니다', 'success');
            this.closeDateEventModal();
        },

        // 약물 모달
        openMedicationModal: function() {
            document.getElementById('medicationModal').style.display = 'block';
        },

        closeMedicationModal: function() {
            document.getElementById('medicationModal').style.display = 'none';
            document.getElementById('modal-image-upload').value = '';
            document.getElementById('modal-text-input').value = '';
            document.getElementById('file-upload-display').textContent = '📷 이미지 선택 또는 드래그&드롭';
            document.getElementById('file-upload-display').classList.remove('has-file');
            document.getElementById('image-preview').style.display = 'none';
            this.imageData = null;
        },

        // 파일 선택 핸들러
        handleFileSelect: function(input) {
            const label = document.getElementById('file-upload-display');
            const previewDiv = document.getElementById('image-preview');
            const previewImg = document.getElementById('preview-img');

            if (input.files && input.files[0]) {
                const file = input.files[0];
                label.textContent = '✅ ' + file.name;
                label.classList.add('has-file');

                // 이미지 미리보기
                const reader = new FileReader();
                reader.onload = (e) => {
                    this.imageData = e.target.result;
                    previewImg.src = e.target.result;
                    previewDiv.style.display = 'block';
                };
                reader.readAsDataURL(file);
            } else {
                label.textContent = '📷 이미지 선택 또는 드래그&드롭';
                label.classList.remove('has-file');
                previewDiv.style.display = 'none';
                this.imageData = null;
            }
        },

        // 약물 정보 처리
        processModalInput: function() {
            const imageFile = document.getElementById('modal-image-upload').files[0];
            const textInput = document.getElementById('modal-text-input').value.trim();

            if (!imageFile && !textInput) {
                showToast('이미지나 텍스트를 입력해주세요', 'error');
                return;
            }

            const btn = document.getElementById('modal-submit-btn');
            const originalText = btn.textContent;
            btn.textContent = 'AI 분석 중...';
            btn.disabled = true;

            // AI 분석 시뮬레이션
            setTimeout(() => {
                let medicationData;

                if (imageFile && this.imageData) {
                    medicationData = this.extractMedicationFromImage(this.imageData);
                    showToast('이미지에서 약물 정보를 추출했습니다', 'success');
                } else {
                    medicationData = this.extractMedicationFromText(textInput);
                    showToast('텍스트에서 약물 정보를 추출했습니다', 'success');
                }

                this.generateAndAddMedicationEvents(medicationData);
                this.closeMedicationModal();

                btn.textContent = originalText;
                btn.disabled = false;
                showToast('약물 일정이 캘린더에 등록되었습니다', 'success');

                // 알림 설정
                this.setupMedicationNotifications(medicationData);
            }, 2000);
        },

        // 이미지에서 약물 정보 추출 (Mock)
        extractMedicationFromImage: function(imageData) {
            // 실제로는 OCR API나 Claude Vision API 사용
            return {
                startDate: new Date().toISOString().split('T')[0],
                duration: 5,
                medications: [
                    { name: '톡스엔정 50mg', dose: 1, daily: 1, times: ['저녁'], totalDays: 2, color: '#ff7f50' },
                    { name: '펠루스정', dose: 1, daily: 3, times: ['아침', '점심', '저녁'], totalDays: 5, color: '#4682b4' },
                    { name: '덱스부프로펜정 150mg', dose: 1, daily: 3, times: ['아침', '점심', '저녁'], totalDays: 5, color: '#9370db' }
                ]
            };
        },

        // 텍스트에서 약물 정보 추출
        extractMedicationFromText: function(text) {
            const medications = [];
            const lines = text.split(/[,\n]/);

            lines.forEach(line => {
                const trimmed = line.trim();
                if (!trimmed) return;

                const nameMatch = trimmed.match(/^([가-힣a-zA-Z0-9]+)/);
                const dailyMatch = trimmed.match(/(\d+)회/);
                const daysMatch = trimmed.match(/(\d+)일/);

                if (nameMatch) {
                    const daily = dailyMatch ? parseInt(dailyMatch[1]) : 3;
                    const times = daily === 1 ? ['저녁'] : daily === 2 ? ['아침', '저녁'] : ['아침', '점심', '저녁'];

                    medications.push({
                        name: nameMatch[1],
                        dose: 1,
                        daily: daily,
                        times: times,
                        totalDays: daysMatch ? parseInt(daysMatch[1]) : 5,
                        color: '#4682b4'
                    });
                }
            });

            return {
                startDate: new Date().toISOString().split('T')[0],
                duration: medications.length > 0 ? Math.max(...medications.map(m => m.totalDays)) : 5,
                medications: medications.length > 0 ? medications : [
                    { name: '약물', dose: 1, daily: 3, times: ['아침', '점심', '저녁'], totalDays: 5, color: '#4682b4' }
                ]
            };
        },

        // 약물 일정 생성
        generateAndAddMedicationEvents: function(data) {
            const events = [];
            const startDay = new Date(data.startDate);

            data.medications.forEach(med => {
                for (let i = 0; i < med.totalDays; i++) {
                    const eventDate = new Date(startDay);
                    eventDate.setDate(startDay.getDate() + i);

                    med.times.forEach(time => {
                        events.push({
                            title: '💊 ' + med.name,
                            start: eventDate.toISOString().split('T')[0],
                            backgroundColor: med.color,
                            borderColor: med.color,
                            extendedProps: {
                                time: time + ' 식후 30분',
                                desc: '복용량: ' + med.dose + '정',
                                type: 'medication'
                            }
                        });
                    });
                }
            });

            this.addEvents(events);
        },

        // 약물 알림 설정
        setupMedicationNotifications: function(data) {
            if (Notification.permission !== 'granted') {
                Notification.requestPermission().then(permission => {
                    if (permission === 'granted') {
                        showToast('알림이 활성화되었습니다', 'success');
                    }
                });
            }
        },

        // 알림 체크 설정 (시간별 알림만)
        setupNotificationCheck: function() {
            // 알림 권한 요청
            if (Notification.permission === 'default') {
                Notification.requestPermission();
            }

            // 1분마다 오늘 일정의 시간 체크
            setInterval(() => {
                this.checkTodayEventTimes();
            }, 60000); // 1분마다
        },

        // 오늘 일정 시간 체크 (시간이 설정된 일정만)
        checkTodayEventTimes: function() {
            if (Notification.permission !== 'granted') return;

            const now = new Date();
            const todayStr = now.toISOString().split('T')[0];
            const currentTime = String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0');

            const events = this.calendar.getEvents().filter(e => {
                const eventDate = new Date(e.start);
                return eventDate.toISOString().split('T')[0] === todayStr;
            });

            events.forEach(event => {
                const eventTime = event.extendedProps.time;
                if (eventTime) {
                    // 시간만 추출 (예: "09:00", "15:30")
                    const timeMatch = eventTime.match(/^(\d{2}):(\d{2})/);
                    if (timeMatch) {
                        const eventTimeStr = timeMatch[1] + ':' + timeMatch[2];

                        // 정확히 그 시간이면 알림
                        if (eventTimeStr === currentTime) {
                            new Notification('⏰ ' + event.title, {
                                body: '일정 시간입니다!',
                                icon: '🔔',
                                tag: event.id,
                                requireInteraction: false
                            });
                            showToast(event.title + ' 시간입니다!', 'info');
                        }
                    }
                }
            });
        },

        checkUpcomingNotifications: function(event) {
            // 이 함수는 제거 (1일 전 알림 기능 제거)
        },

        // 일정 상세 보기
        showEventDetail: function(event) {
            let message = event.title + '\n';
            if (event.extendedProps.time) {
                message += '시간: ' + event.extendedProps.time + '\n';
            }
            if (event.extendedProps.desc) {
                message += event.extendedProps.desc + '\n';
            }
            message += '\n이 일정을 삭제하시겠습니까?';

            if (confirm(message)) {
                event.remove();
                showToast('일정이 삭제되었습니다', 'success');
                this.updateTodaySchedule();
            }
        },

        // 오늘 일정 패널
        toggleTodayPanel: function() {
            const panel = document.getElementById('todaySchedulePanel');
            this.todayPanelOpen = !this.todayPanelOpen;
            if (this.todayPanelOpen) {
                panel.classList.add('open');

                // 음성 안내
                const today = new Date();
                const events = this.calendar.getEvents().filter(e => {
                    const eventDate = new Date(e.start);
                    eventDate.setHours(0, 0, 0, 0);
                    return eventDate.toISOString().split('T')[0] === today.toISOString().split('T')[0];
                });

                if (events.length === 0) {
                    this.speak('오늘은 일정이 없습니다.');
                } else {
                    let message = '오늘은 총 ' + events.length + '개의 일정이 있습니다. ';
                    events.forEach((event, index) => {
                        message += (index + 1) + '번째, ' + event.title;
                        if (event.extendedProps.time) {
                            message += ', ' + event.extendedProps.time;
                        }
                        message += '. ';
                    });
                    this.speak(message);
                }
            } else {
                panel.classList.remove('open');
            }
            this.updateTodaySchedule();
        },

        closeTodayPanel: function() {
            document.getElementById('todaySchedulePanel').classList.remove('open');
            this.todayPanelOpen = false;
            this.speechSynthesis.cancel(); // 음성 중지
        },

        // 오늘 일정 업데이트 (날짜 필터링)
        updateTodaySchedule: function() {
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const todayStr = today.toISOString().split('T')[0];

            // 오늘 날짜의 일정만 필터링
            const events = this.calendar.getEvents().filter(e => {
                const eventDate = new Date(e.start);
                eventDate.setHours(0, 0, 0, 0);
                return eventDate.toISOString().split('T')[0] === todayStr;
            });

            const dateInfo = document.getElementById('panel-date-info');
            const days = ['일', '월', '화', '수', '목', '금', '토'];
            dateInfo.textContent = (today.getMonth() + 1) + '월 ' + today.getDate() + '일 (' + days[today.getDay()] + ')';

            const listEl = document.getElementById('today-schedule-list');

            if (events.length === 0) {
                listEl.innerHTML = '<div class="no-schedule"><div class="no-schedule-icon">📭</div><p>오늘은 일정이 없습니다</p></div>';
                document.getElementById('today-count').style.display = 'none';
            } else {
                // 시간순 정렬
                events.sort((a, b) => {
                    const timeA = a.extendedProps.time || '99:99';
                    const timeB = b.extendedProps.time || '99:99';
                    return timeA.localeCompare(timeB);
                });

                let html = '';
                events.forEach((event, index) => {
                    const className = event.extendedProps.type === 'medication' ? 'schedule-item medication' : 'schedule-item';
                    html += '<div class="' + className + '" onclick="calendarManager.speakEventDetail(event, ' + index + ')" style="cursor: pointer;">';
                    html += '<div class="schedule-item-header">';
                    html += '<span class="schedule-item-title">' + event.title + '</span>';
                    if (event.extendedProps.time) {
                        html += '<span class="schedule-item-time">' + event.extendedProps.time + '</span>';
                    }
                    html += '</div>';
                    if (event.extendedProps.desc) {
                        html += '<div class="schedule-item-desc">' + event.extendedProps.desc + '</div>';
                    }
                    html += '</div>';
                });
                listEl.innerHTML = html;

                // 이벤트 리스너 추가 (클릭 시 음성 안내)
                const items = listEl.querySelectorAll('.schedule-item');
                items.forEach((item, index) => {
                    item.addEventListener('click', () => {
                        const event = events[index];
                        let message = event.title;
                        if (event.extendedProps.time) {
                            message += ', ' + event.extendedProps.time;
                        }
                        if (event.extendedProps.desc) {
                            message += ', ' + event.extendedProps.desc;
                        }
                        this.speak(message);
                    });
                });

                const badge = document.getElementById('today-count');
                badge.textContent = events.length;
                badge.style.display = 'inline-block';
            }
        },

        // 일정 추가 시 음성 안내
        addEvents: function(eventsArray) {
            this.calendar.addEventSource(eventsArray);
            this.updateTodaySchedule();

            // 추가된 일정 음성 안내
            if (eventsArray.length > 0) {
                const firstEvent = eventsArray[0];
                this.speak(eventsArray.length + '개의 일정이 추가되었습니다. ' + firstEvent.title);
            }
        },

        // 일정 초기화
        clearEvents: function() {
            if (confirm('모든 일정을 삭제하시겠습니까?')) {
                this.calendar.removeAllEvents();
                showToast('일정이 초기화되었습니다', 'info');
                this.speak('모든 일정이 삭제되었습니다.');
                this.updateTodaySchedule();
            }
        },

        // 오늘로 이동
        goToToday: function() {
            this.calendar.today();
            showToast('오늘 날짜로 이동했습니다', 'info');
            this.speak('오늘 날짜로 이동했습니다.');
        }
    };

    // 모달 외부 클릭시 닫기
    window.onclick = function(event) {
        if (event.target.classList.contains('modal')) {
            event.target.style.display = 'none';
        }
    };

    // 초기화
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            calendarManager.init();
        });
    } else {
        calendarManager.init();
    }
</script>

</body>
</html>