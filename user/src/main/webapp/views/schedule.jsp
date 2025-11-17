<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<section class="calendar-section">
    <link href='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.css' rel='stylesheet' />
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.10/index.global.min.js'></script>

    <style>
        .calendar-section {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 15px;
        }

        .calendar-header {
            border-bottom: 2px solid #333;
            padding-bottom: 15px;
            margin-bottom: 30px;
        }

        .calendar-header h2 {
            font-size: 28px;
            font-weight: bold;
            margin: 0 0 10px 0;
        }

        .calendar-header p {
            color: #666;
            margin: 0;
        }

        #calendar {
            border: 1px solid #ddd;
            padding: 15px;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .calendar-controls {
            margin-bottom: 20px;
            padding: 15px;
            background: #f5f5f5;
            border: 1px solid #ddd;
            border-radius: 8px;
        }

        .calendar-controls button {
            padding: 10px 20px;
            margin-right: 10px;
            border: 1px solid #333;
            background: #fff;
            cursor: pointer;
            border-radius: 4px;
            font-size: 14px;
        }

        .calendar-controls button:hover {
            background: #333;
            color: #fff;
        }
    </style>

    <div class="calendar-header">
        <h2>📅 진료 일정</h2>
        <p>의료진 일정 및 예약 가능 시간을 확인하세요</p>
    </div>

    <div class="calendar-controls">
        <button onclick="calendarManager.goToToday()">오늘</button>
        <button onclick="calendarManager.addSampleEvent()">샘플 일정 추가</button>
        <button onclick="calendarManager.clearEvents()">일정 초기화</button>
    </div>

    <div id="calendar"></div>

    <script>
        const calendarManager = {
            calendar: null,

            init: function() {
                this.calendar = new FullCalendar.Calendar(document.getElementById('calendar'), {
                    initialView: 'dayGridMonth',
                    locale: 'ko',
                    height: 'auto',

                    headerToolbar: {
                        left: 'prev,next today',
                        center: 'title',
                        right: 'dayGridMonth,dayGridWeek'
                    },

                    eventClick: function(info) {
                        const event = info.event;
                        let message = event.title + '\n\n';

                        if (event.extendedProps.time) {
                            message += '시간: ' + event.extendedProps.time + '\n';
                        }
                        if (event.extendedProps.desc) {
                            message += '\n' + event.extendedProps.desc;
                        }
                        if (event.extendedProps.tip) {
                            message += '\n\nTIP: ' + event.extendedProps.tip;
                        }
                        if (event.extendedProps.url) {
                            message += '\n\n홈페이지: ' + event.extendedProps.url;
                            alert(message);
                            window.open(event.extendedProps.url, '_blank');
                        } else {
                            alert(message);
                        }
                    },

                    dateClick: function(info) {
                        console.log('클릭한 날짜:', info.dateStr);
                    }
                });

                this.calendar.render();
            },

            addEvent: function(eventData) {
                this.calendar.addEvent(eventData);
            },

            addEvents: function(eventsArray) {
                this.calendar.addEventSource(eventsArray);
            },

            clearEvents: function() {
                this.calendar.removeAllEvents();
            },

            goToToday: function() {
                this.calendar.today();
            },

            goToDate: function(date) {
                this.calendar.gotoDate(date);
            },

            addSampleEvent: function() {
                const today = new Date();
                const tomorrow = new Date(today);
                tomorrow.setDate(tomorrow.getDate() + 1);

                this.addEvents([
                    {
                        title: '내과 진료',
                        start: today,
                        backgroundColor: '#5b9bd5',
                        extendedProps: {
                            time: '09:00 - 12:00',
                            desc: '정기 검진 및 상담',
                            tip: '예약 필수'
                        }
                    },
                    {
                        title: '외과 진료',
                        start: today,
                        backgroundColor: '#70ad47',
                        extendedProps: {
                            time: '14:00 - 17:00',
                            desc: '수술 상담',
                            tip: '주차 가능'
                        }
                    },
                    {
                        title: '정형외과',
                        start: tomorrow,
                        backgroundColor: '#ffc000',
                        extendedProps: {
                            time: '10:00 - 13:00',
                            desc: '물리치료 및 재활',
                            tip: '편한 복장 착용'
                        }
                    }
                ]);
            }
        };

        document.addEventListener('DOMContentLoaded', function() {
            calendarManager.init();
        });
    </script>
</section>