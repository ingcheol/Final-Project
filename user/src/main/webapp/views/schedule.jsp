<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>일정 관리</title>
    <link href='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.css' rel='stylesheet' />
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js'></script>
    <script src='https://cdn.jsdelivr.net/npm/@fullcalendar/core@6.1.10/locales-all.global.min.js'></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f7fa; }

        /* Layout & Calendar Section */
        .calendar-section { max-width: 1200px; margin: 40px auto; padding: 0 15px; }
        #header-title { font-size: 28px; margin-bottom: 10px; color: #333; }
        #header-desc { color: #666; margin-bottom: 20px; }

        /* Controls */
        .calendar-controls { margin-bottom: 20px; padding: 15px; background: #fff; border: 1px solid #ddd; border-radius: 8px; display: flex; flex-wrap: wrap; gap: 10px; align-items: center; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        #header-controls { display: flex; gap: 8px; flex-wrap: wrap; }
        #header-controls button { padding: 10px 15px; border: 1px solid #ccc; cursor: pointer; border-radius: 4px; font-size: 14px; font-weight: 600; transition: all 0.3s ease; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.1); min-width: 80px; background: #fff; color: #333; }
        #header-controls button:hover { background: #f0f0f0; transform: translateY(-1px); box-shadow: 0 2px 6px rgba(0,0,0,0.15); }

        /* Buttons Colors */
        #add-manual-event { background-color: #ffc000 !important; color: #333 !important; border-color: #ffc000 !important; }
        #add-manual-event:hover { background-color: #e5a700 !important; }
        #scan-med-btn { background-color: #5b9bd5 !important; color: white !important; border-color: #5b9bd5 !important; }
        #scan-med-btn:hover { background-color: #4a8ac1 !important; }
        #speech-input-btn { background-color: #70ad47 !important; color: white !important; border-color: #70ad47 !important; }
        #speech-input-btn:hover { background-color: #5d9337 !important; }

        /* Calendar Container */
        #calendar { border: 1px solid #ddd; padding: 15px; background: #fff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }

        /* Right Side Panel */
        .today-schedule-panel { position: fixed; right: -450px; top: 50%; transform: translateY(-50%); width: 420px; max-height: 85vh; background: white; box-shadow: -4px 0 20px rgba(0,0,0,0.2); transition: right 0.3s ease; z-index: 999; overflow-y: auto; border-radius: 12px 0 0 12px; }
        .today-schedule-panel.open { right: 0; }
        .panel-header { padding: 20px; background: linear-gradient(135deg, #5b9bd5 0%, #4a8ac1 100%); color: white; position: sticky; top: 0; z-index: 10; }
        .panel-header h3 { margin: 0 0 5px 0; font-size: 20px; }
        .panel-header .date-info { font-size: 14px; opacity: 0.9; }
        .panel-close { position: absolute; right: 15px; top: 15px; background: rgba(255,255,255,0.3); border: none; color: white; font-size: 28px; cursor: pointer; width: 40px; height: 40px; border-radius: 50%; transition: all 0.2s; display: flex; align-items: center; justify-content: center; font-weight: bold; line-height: 1; }
        .panel-close:hover { background: rgba(255,255,255,0.5); transform: rotate(90deg); }
        .panel-content { padding: 20px; }

        /* Schedule Items */
        .schedule-item { background: #f8f9fa; border-left: 4px solid #5b9bd5; padding: 15px; margin-bottom: 12px; border-radius: 6px; transition: all 0.2s; cursor: pointer; }
        .schedule-item:hover { transform: translateX(-5px); box-shadow: 0 2px 8px rgba(0,0,0,0.1); background: #e8f4ff; }
        .schedule-item.medication { border-left-color: #ff7f50; }
        .schedule-item.appointment { border-left-color: #70ad47; }
        .schedule-item-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
        .schedule-item-title { font-weight: 600; font-size: 15px; color: #333; }
        .schedule-item-time { font-size: 13px; color: #666; background: white; padding: 2px 8px; border-radius: 4px; }
        .schedule-item-desc { font-size: 13px; color: #666; line-height: 1.5; }

        /* Status Badges */
        .schedule-item-status { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; margin-left: 8px; }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-confirmed { background: #d4edda; color: #155724; }
        .status-cancelled { background: #f8d7da; color: #721c24; }
        .status-completed { background: #d1ecf1; color: #0c5460; }

        /* Empty State & Notification */
        .no-schedule { text-align: center; padding: 40px 20px; color: #999; }
        .no-schedule-icon { font-size: 48px; margin-bottom: 10px; }
        .notification-badge { position: absolute; top: -5px; right: -5px; background: #ff4444; color: white; font-size: 11px; padding: 2px 6px; border-radius: 10px; font-weight: 600; }

        /* FullCalendar Customization */
        .fc-daygrid-day-frame { position: relative; cursor: pointer; }
        .fc-daygrid-day-top { display: flex; justify-content: space-between; align-items: center; }
        .add-event-btn { width: 18px; height: 18px; border-radius: 50%; background: #5b9bd5; color: white; border: none; cursor: pointer; font-size: 14px; line-height: 16px; opacity: 0; transition: all 0.2s; z-index: 10; display: flex; align-items: center; justify-content: center; margin-right: 4px; }
        .fc-daygrid-day:hover .add-event-btn { opacity: 1; }
        .add-event-btn:hover { background: #4a8ac1; transform: scale(1.15); }

        /* Modals */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0,0,0,0.5); animation: fadeIn 0.3s; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        .modal-content { background-color: #fff; margin: 5% auto; padding: 30px; border: none; width: 90%; max-width: 500px; border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.2); animation: slideDown 0.3s; }
        @keyframes slideDown { from { transform: translateY(-50px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        .modal-content h3 { border-bottom: 2px solid #5b9bd5; padding-bottom: 10px; margin-bottom: 20px; color: #333; }
        .close { color: #aaa; float: right; font-size: 28px; font-weight: bold; line-height: 20px; cursor: pointer; transition: color 0.2s; }
        .close:hover, .close:focus { color: #000; }

        /* Form Elements */
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #555; }
        .form-group input[type="text"], .form-group input[type="date"], .form-group input[type="time"], .form-group input[type="datetime-local"], .form-group select, .form-group textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; transition: border-color 0.3s; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { outline: none; border-color: #5b9bd5; box-shadow: 0 0 0 3px rgba(91, 155, 213, 0.1); }
        .form-group textarea { resize: vertical; min-height: 80px; font-family: inherit; }

        /* Modal Buttons */
        .modal-buttons { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; }
        .modal-buttons button { padding: 10px 20px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 600; transition: all 0.3s; }
        .btn-primary { background-color: #5b9bd5; color: white; }
        .btn-primary:hover { background-color: #4a8ac1; }
        .btn-primary:disabled { background-color: #ccc; cursor: not-allowed; }
        .btn-secondary { background-color: #e0e0e0; color: #333; }
        .btn-secondary:hover { background-color: #d0d0d0; }
        .btn-danger { background-color: #d9534f; color: white; }
        .btn-danger:hover { background-color: #c9302c; }

        /* Toasts & Badges */
        .toast { position: fixed; bottom: 30px; right: 30px; background: #333; color: white; padding: 15px 20px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.3); z-index: 2000; animation: slideInRight 0.3s, fadeOut 0.3s 2.7s; max-width: 300px; }
        @keyframes slideInRight { from { transform: translateX(400px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        @keyframes fadeOut { to { opacity: 0; } }
        .toast.success { background: #70ad47; }
        .toast.error { background: #d9534f; }
        .toast.info { background: #5b9bd5; }
        .ai-badge { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; margin-left: 8px; }

        /* File Upload */
        .file-upload-wrapper { position: relative; display: inline-block; width: 100%; }
        .file-upload-wrapper input[type="file"] { position: absolute; opacity: 0; width: 100%; height: 100%; cursor: pointer; z-index: 2; }
        .file-upload-label { display: flex; align-items: center; justify-content: center; padding: 30px; border: 2px dashed #ddd; border-radius: 8px; background: #f9f9f9; cursor: pointer; transition: all 0.3s; font-size: 15px; color: #666; }
        .file-upload-label:hover { border-color: #5b9bd5; background: #f0f7ff; }
        .file-upload-label.has-file { border-color: #70ad47; background: #f0f9f0; color: #70ad47; }
        #image-preview { margin-top: 15px; text-align: center; }
        #preview-img { max-width: 100%; max-height: 300px; border-radius: 8px; border: 2px solid #ddd; }

        /* Appointment Selector */
        .appointment-type-selector { display: flex; gap: 10px; margin-top: 10px; }
        .appointment-type-option { flex: 1; padding: 15px; border: 2px solid #ddd; border-radius: 8px; text-align: center; cursor: pointer; transition: all 0.3s; }
        .appointment-type-option:hover { border-color: #5b9bd5; background: #f0f7ff; }
        .appointment-type-option.selected { border-color: #5b9bd5; background: #e8f4ff; }
        .appointment-type-icon { font-size: 24px; margin-bottom: 5px; }
    </style>
</head>
<body>

<section class="calendar-section">
    <h2 id="header-title">📅 일정 관리</h2>
    <p id="header-desc">약봉투를 업로드하거나 음성 및 텍스트로 일정을 추가해보세요.</p>

    <div class="calendar-controls">
        <div id="header-controls">
            <button onclick="calendarManager.toggleTodayPanel()" data-key="todaySchedule" style="position: relative;">
                📋 오늘 일정
                <span class="notification-badge" id="today-count" style="display: none;">0</span>
            </button>
            <button onclick="calendarManager.goToToday()" data-key="today">오늘로 이동</button>
            <button onclick="calendarManager.openAppointmentModal()" data-key="addAppointment">
                🏥 상담 예약
            </button>
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

<div id="appointmentModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="calendarManager.closeAppointmentModal()">&times;</span>
        <h3>🏥 상담 예약</h3>

        <div class="form-group">
            <label>상담 유형 선택</label>
            <div class="appointment-type-selector">
                <div class="appointment-type-option" data-type="video" onclick="calendarManager.selectAppointmentType('video')">
                    <div class="appointment-type-icon">📹</div>
                    <div>화상 상담</div>
                </div>
                <div class="appointment-type-option" data-type="chat" onclick="calendarManager.selectAppointmentType('chat')">
                    <div class="appointment-type-icon">💬</div>
                    <div>채팅 상담</div>
                </div>
                <div class="appointment-type-option" data-type="phone" onclick="calendarManager.selectAppointmentType('phone')">
                    <div class="appointment-type-icon">📞</div>
                    <div>전화 상담</div>
                </div>
            </div>
        </div>

        <div class="form-group">
            <label for="appointment-datetime">예약 일시</label>
            <input type="datetime-local" id="appointment-datetime" required>
        </div>

        <div class="form-group">
            <label for="appointment-notes">상담 내용 (선택)</label>
            <textarea id="appointment-notes" rows="4" placeholder="상담받고 싶은 내용을 입력해주세요"></textarea>
        </div>

        <div class="modal-buttons">
            <button class="btn-secondary" onclick="calendarManager.closeAppointmentModal()">취소</button>
            <button class="btn-primary" onclick="calendarManager.saveAppointment()">예약 신청</button>
        </div>
    </div>
</div>

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

<div id="appointmentDetailModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="calendarManager.closeAppointmentDetailModal()">&times;</span>
        <h3>🏥 예약 상세</h3>

        <div id="appointment-detail-content">
        </div>

        <div class="modal-buttons" id="appointment-detail-buttons">
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
        setTimeout(function() {
            toast.remove();
        }, 3000);
    }

    // Calendar Manager
    const calendarManager = {
        calendar: null,
        selectedDate: null,
        todayPanelOpen: false,
        recognition: null,
        imageData: null,
        speechSynthesis: window.speechSynthesis,
        selectedAppointmentType: 'video',
        currentAppointmentId: null,

        // 음성 출력 함수
        speak: function(text) {
            if (!this.speechSynthesis) return;
            this.speechSynthesis.cancel();
            const utterance = new SpeechSynthesisUtterance(text);
            utterance.lang = 'ko-KR';
            utterance.rate = 0.9;
            utterance.pitch = 1;
            utterance.volume = 1;
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
                // ⭐ 이미 여기서 데이터를 로드하고 있습니다
                events: function(info, successCallback, failureCallback) {
                    fetch('/appointment/calendar/events?start=' + info.startStr + '&end=' + info.endStr)
                        .then(response => response.json())
                        .then(data => {
                            successCallback(data);
                        })
                        .catch(error => {
                            console.error('예약 데이터 로드 실패:', error);
                            failureCallback(error);
                        });
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
            // ❌ 이 줄 삭제 - loadAppointments() 호출 제거
            // this.loadAppointments();
            this.updateTodaySchedule();
            this.setupNotificationCheck();
            this.initSpeechRecognition();
            this.setupDragAndDrop();
        },

        // DB에서 예약 데이터 로드
        loadAppointments: function() {
            fetch('/appointment/calendar/events')
                .then(response => response.json())
                .then(events => {
                    if (events && events.length > 0) {
                        this.calendar.addEventSource(events);
                        this.updateTodaySchedule();
                    }
                })
                .catch(error => {
                    console.error('예약 데이터 로드 실패:', error);
                });
        },

        // 상태에 따른 색상
        getAppointmentColor: function(status) {
            switch (status) {
                case 'pending': return '#ffc107';
                case 'confirmed': return '#70ad47';
                case 'cancelled': return '#d9534f';
                case 'completed': return '#5b9bd5';
                default: return '#6c757d';
            }
        },

        // 상담 예약 모달 열기
        openAppointmentModal: function() {
            document.getElementById('appointmentModal').style.display = 'block';
            this.selectedAppointmentType = 'video';
            document.querySelectorAll('.appointment-type-option').forEach(el => {
                el.classList.remove('selected');
            });
            document.querySelector('[data-type="video"]').classList.add('selected');

            // 기본값: 내일 오전 10시
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            tomorrow.setHours(10, 0, 0, 0);
            const datetimeStr = tomorrow.toISOString().slice(0, 16);
            document.getElementById('appointment-datetime').value = datetimeStr;
        },

        closeAppointmentModal: function() {
            document.getElementById('appointmentModal').style.display = 'none';
            document.getElementById('appointment-notes').value = '';
        },

        selectAppointmentType: function(type) {
            this.selectedAppointmentType = type;
            document.querySelectorAll('.appointment-type-option').forEach(el => {
                el.classList.remove('selected');
            });
            document.querySelector('[data-type="' + type + '"]').classList.add('selected');
        },

        // 예약 저장
        saveAppointment: function() {
            const datetime = document.getElementById('appointment-datetime').value;
            const notes = document.getElementById('appointment-notes').value;

            if (!datetime) {
                showToast('예약 일시를 선택해주세요', 'error');
                return;
            }

            const appointmentData = {
                appointmentTime: datetime,
                appointmentType: this.selectedAppointmentType,
                notes: notes,
                status: 'pending'
            };

            $.ajax({
                url: '/appointment/create',
                type: 'POST',
                data: appointmentData,
                success: (response) => {
                    showToast('예약 신청이 완료되었습니다. 승인 후 알림을 보내드립니다.', 'success');
                    this.closeAppointmentModal();
                    // 페이지 새로고침하여 예약 데이터 다시 로드
                    location.reload();
                },
                error: (xhr, status, error) => {
                    console.error('예약 실패:', error);
                    const errorMsg = xhr.responseJSON?.message || '예약 신청 중 오류가 발생했습니다.';
                    showToast(errorMsg, 'error');
                }
            });
        },

        // 예약 상세 모달
        openAppointmentDetailModal: function(appointment) {
            this.currentAppointmentId = appointment.appointmentId;

            let html = '<div style="padding: 10px 0;">';
            html += '<div style="margin-bottom: 15px;">';
            html += '<strong>상담 유형:</strong> ' + appointment.appointmentTypeKr;
            html += '<span class="schedule-item-status status-' + appointment.status + '">' + appointment.statusKr + '</span>';
            html += '</div>';
            html += '<div style="margin-bottom: 15px;"><strong>예약 일시:</strong> ' + appointment.formattedDateTime + '</div>';
            if (appointment.notes) {
                html += '<div style="margin-bottom: 15px;"><strong>상담 내용:</strong><br>' + appointment.notes + '</div>';
            }
            html += '</div>';

            document.getElementById('appointment-detail-content').innerHTML = html;

            // 버튼 생성
            let buttons = '';
            buttons += '<button class="btn-secondary" onclick="calendarManager.closeAppointmentDetailModal()">닫기</button>';

            // 승인 대기 또는 확정 상태일 때만 취소 가능
            if (appointment.status === 'pending' || appointment.status === 'confirmed') {
                buttons += '<button class="btn-danger" onclick="calendarManager.cancelAppointment(' + appointment.appointmentId + ')">예약 취소</button>';
            }

            document.getElementById('appointment-detail-buttons').innerHTML = buttons;
            document.getElementById('appointmentDetailModal').style.display = 'block';
        },

        closeAppointmentDetailModal: function() {
            document.getElementById('appointmentDetailModal').style.display = 'none';
            this.currentAppointmentId = null;
        },

        // 예약 취소
        cancelAppointment: function(appointmentId) {
            if (!confirm('정말 이 예약을 취소하시겠습니까?')) {
                return;
            }

            const reason = prompt('취소 사유를 입력해주세요 (선택사항):');

            $.ajax({
                url: '/appointment/cancel/' + appointmentId,
                type: 'POST',
                data: {
                    reason: reason || '환자 요청'
                },
                success: (response) => {
                    showToast('예약이 취소되었습니다.', 'success');
                    this.closeAppointmentDetailModal();
                    location.reload();
                },
                error: (xhr, status, error) => {
                    console.error('예약 취소 실패:', error);
                    showToast('예약 취소 중 오류가 발생했습니다.', 'error');
                }
            });
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
            } catch (e) {
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
                    type: 'voice',
                    dbRecord: false
                }
            }]);

            showToast('일정이 추가되었습니다', 'success');
        },

        // AI 자연어 파싱
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

            // 시간 파싱
            let hour = null;
            let minute = 0;

            const ampmMatch = text.match(/(오전|오후)\s*(\d{1,2})시/);
            if (ampmMatch) {
                hour = parseInt(ampmMatch[2]);
                if (ampmMatch[1] === '오후' && hour !== 12) hour += 12;
                if (ampmMatch[1] === '오전' && hour === 12) hour = 0;
            }

            const hourMatch = text.match(/(\d{1,2})시/);
            if (hourMatch && !ampmMatch) {
                hour = parseInt(hourMatch[1]);
            }

            const minuteMatch = text.match(/(\d{1,2})분/);
            if (minuteMatch) {
                minute = parseInt(minuteMatch[1]);
            } else if (text.includes('반')) {
                minute = 30;
            }

            if (hour !== null) {
                time = String(hour).padStart(2, '0') + ':' + String(minute).padStart(2, '0');
            }

            // 제목 정리
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
                    type: 'user',
                    dbRecord: false
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
                    type: 'appointment',
                    dbRecord: false
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

                this.setupMedicationNotifications(medicationData);
            }, 2000);
        },

        // 이미지에서 약물 정보 추출 (Mock)
        extractMedicationFromImage: function(imageData) {
            return {
                startDate: new Date().toISOString().split('T')[0],
                duration: 5,
                medications: [{
                    name: '톡스엔정 50mg',
                    dose: 1,
                    daily: 1,
                    times: ['저녁'],
                    totalDays: 2,
                    color: '#ff7f50'
                },
                    {
                        name: '펠루스정',
                        dose: 1,
                        daily: 3,
                        times: ['아침', '점심', '저녁'],
                        totalDays: 5,
                        color: '#4682b4'
                    },
                    {
                        name: '덱스부프로펜정 150mg',
                        dose: 1,
                        daily: 3,
                        times: ['아침', '점심', '저녁'],
                        totalDays: 5,
                        color: '#9370db'
                    }
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
                medications: medications.length > 0 ? medications : [{
                    name: '약물',
                    dose: 1,
                    daily: 3,
                    times: ['아침', '점심', '저녁'],
                    totalDays: 5,
                    color: '#4682b4'
                }]
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
                                type: 'medication',
                                dbRecord: false
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

        // 알림 체크 설정
        setupNotificationCheck: function() {
            if (Notification.permission === 'default') {
                Notification.requestPermission();
            }

            setInterval(() => {
                this.checkTodayEventTimes();
            }, 60000);
        },

        // 오늘 일정 시간 체크
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
                    const timeMatch = eventTime.match(/^(\d{2}):(\d{2})/);
                    if (timeMatch) {
                        const eventTimeStr = timeMatch[1] + ':' + timeMatch[2];

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
            // 빈 함수 (1일 전 알림 제거)
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

            // ⭐ 예약 일정인 경우 상세 모달 표시
            if (event.extendedProps.type === 'appointment' && event.extendedProps.dbRecord) {
                // DB 예약 데이터면 상세 모달 표시
                this.showAppointmentDetail(event.extendedProps.appointmentId);
                return;
            }

            message += '\n이 일정을 삭제하시겠습니까?';
            if (confirm(message)) {
                event.remove();
                showToast('일정이 삭제되었습니다', 'success');
                this.updateTodaySchedule();
            }
        },  // ⭐ 이 부분이 빠져있었습니다!
        toggleTodayPanel: function() { // 중복된 함수 선언을 하나로 합치고, 누락된 괄호 문제를 해결했습니다.
            const panel = document.getElementById('todaySchedulePanel');
            if (this.todayPanelOpen) {
                panel.classList.add('open');

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
            this.speechSynthesis.cancel();
        },

        // 오늘 일정 업데이트
        updateTodaySchedule: function() {
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const todayStr = today.toISOString().split('T')[0];

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
                events.sort((a, b) => {
                    const timeA = a.extendedProps.time || '99:99';
                    const timeB = b.extendedProps.time || '99:99';
                    return timeA.localeCompare(timeB);
                });

                let html = '';
                events.forEach((event, index) => {
                    let className = 'schedule-item';
                    if (event.extendedProps.type === 'medication') {
                        className += ' medication';
                    } else if (event.extendedProps.type === 'appointment') {
                        className += ' appointment';
                    }

                    html += '<div class="' + className + '" onclick="calendarManager.handleScheduleItemClick(' + index + ')">';
                    html += '<div class="schedule-item-header">';
                    html += '<span class="schedule-item-title">' + event.title;

                    // 예약 상태 표시
                    if (event.extendedProps.type === 'appointment') {
                        const statusClass = 'status-' + event.extendedProps.status;
                        html += '<span class="schedule-item-status ' + statusClass + '">' + event.extendedProps.statusKr + '</span>';
                    }

                    html += '</span>';
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

                const badge = document.getElementById('today-count');
                badge.textContent = events.length;
                badge.style.display = 'inline-block';
            }
        },

        // 일정 아이템 클릭 처리
        handleScheduleItemClick: function(index) {
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const todayStr = today.toISOString().split('T')[0];

            const events = this.calendar.getEvents().filter(e => {
                const eventDate = new Date(e.start);
                eventDate.setHours(0, 0, 0, 0);
                return eventDate.toISOString().split('T')[0] === todayStr;
            });

            // 시간순 정렬
            events.sort((a, b) => {
                const timeA = a.extendedProps.time || '99:99';
                const timeB = b.extendedProps.time || '99:99';
                return timeA.localeCompare(timeB);
            });

            const event = events[index];

            // 음성 안내
            let message = event.title;
            if (event.extendedProps.time) {
                message += ', ' + event.extendedProps.time;
            }
            if (event.extendedProps.desc) {
                message += ', ' + event.extendedProps.desc;
            }
            this.speak(message);

            // 예약 상세 보기
            if (event.extendedProps.type === 'appointment' && event.extendedProps.appointmentId) {
                this.showAppointmentDetail(event.extendedProps.appointmentId);
            }
        },

        // 예약 상세 보기
        showAppointmentDetail: function(appointmentId) {
            fetch('/appointment/' + appointmentId, {
                headers: {
                    'Accept': 'application/json'
                }
            })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('예약 정보를 불러올 수 없습니다');
                    }
                    return response.json();
                })
                .then(apt => {
                    const content = document.getElementById('appointment-detail-content');

                    let html = '<div style="line-height: 1.8;">';
                    html += '<p><strong>상담 유형:</strong> ' + (apt.appointmentTypeKr || '정보 없음') + '</p>';
                    html += '<p><strong>예약 일시:</strong> ' + (apt.formattedDateTimeWithDay || apt.formattedDateTime || '정보 없음') + '</p>';
                    html += '<p><strong>상태:</strong> <span class="schedule-item-status status-' + apt.status + '">' + (apt.statusKr || apt.status) + '</span></p>';
                    if (apt.notes) {
                        html += '<p><strong>메모:</strong><br>' + apt.notes.replace(/\n/g, '<br>') + '</p>';
                    }
                    html += '</div>';

                    content.innerHTML = html;

                    // 버튼 생성 - 닫기만 표시
                    const buttons = document.getElementById('appointment-detail-buttons');
                    let buttonHtml = '<button class="btn-secondary" onclick="calendarManager.closeAppointmentDetailModal()">닫기</button>';

                    // 취소 기능은 예약 관리 페이지에서만 가능하도록 제거
                    // 필요시 아래 주석 해제
                    /*
                    if (apt.status === 'pending' || apt.status === 'confirmed') {
                        buttonHtml += '<button class="btn-danger" onclick="calendarManager.cancelAppointment(' + appointmentId + ')">예약 취소</button>';
                    }
                    */

                    buttons.innerHTML = buttonHtml;
                    this.currentAppointmentId = appointmentId;
                    document.getElementById('appointmentDetailModal').style.display = 'block';
                })
                .catch(error => {
                    console.error('예약 상세 조회 실패:', error);
                    showToast('예약 정보를 불러올 수 없습니다', 'error');
                });
        },

        closeAppointmentDetailModal: function() {
            document.getElementById('appointmentDetailModal').style.display = 'none';
            this.currentAppointmentId = null;
        },

        // 예약 취소
        cancelAppointment: function(appointmentId) {
            const reason = prompt('취소 사유를 입력해주세요 (선택사항):');
            if (reason === null) return; // 취소

            $.ajax({
                url: '/appointment/cancel/' + appointmentId,
                type: 'POST',
                data: {
                    reason: reason || '환자 요청'
                },
                success: () => {
                    showToast('예약이 취소되었습니다', 'success');
                    this.closeAppointmentDetailModal();
                    this.calendar.removeAllEvents();
                    this.loadAppointments();
                    this.updateTodaySchedule();
                    this.speak('예약이 취소되었습니다');
                },
                error: (xhr, status, error) => {
                    console.error('예약 취소 실패:', error);
                    showToast('예약 취소 중 오류가 발생했습니다', 'error');
                }
            });
        },

        addEvents: function(eventsArray) {
            this.calendar.addEventSource(eventsArray);
            this.updateTodaySchedule();

            if (eventsArray.length > 0) {
                const firstEvent = eventsArray[0];
                this.speak(eventsArray.length + '개의 일정이 추가되었습니다. ' + firstEvent.title);
            }
        },

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