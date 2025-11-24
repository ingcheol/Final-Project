<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>병원 찾기 - AI 의료 매칭 시스템</title>

    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700&display=swap" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
            color: #333;
            background: #f5f7fa;
        }

        header {
            background: white;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
        }

        nav {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 40px;
        }

        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #5B6FB5;
            text-decoration: none;
        }

        .nav-menu {
            display: flex;
            gap: 40px;
            list-style: none;
        }

        .nav-menu a {
            text-decoration: none;
            color: #333;
            font-weight: 500;
            transition: color 0.3s;
        }

        .nav-menu a:hover {
            color: #5B6FB5;
        }

        .main-container {
            margin-top: 100px;
            padding: 25px 30px;
            max-width: 1400px;
            margin-left: auto;
            margin-right: auto;
        }

        .page-header {
            margin-bottom: 20px;
        }

        .page-header h1 {
            font-size: 28px;
            color: #2c3e50;
            margin-bottom: 8px;
            font-weight: 700;
        }

        .page-header p {
            font-size: 14px;
            color: #7f8c8d;
        }

        .control-panel {
            background: white;
            padding: 18px 20px;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
            margin-bottom: 20px;
        }

        .control-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .control-buttons .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(91, 111, 181, 0.3);
        }

        .btn-success {
            background: linear-gradient(135deg, #28a745 0%, #218838 100%);
            color: white;
        }

        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
        }

        .btn-danger {
            background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
            color: white;
        }

        .btn-danger:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
        }

        .btn-secondary {
            background: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
        }

        .map-chat-container {
            display: flex;
            gap: 20px;
            height: 600px;
        }

        #container {
            overflow: hidden;
            height: 100%;
            width: 70%;
            position: relative;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            background: white;
        }

        #mapWrapper {
            width: 100%;
            height: 100%;
            z-index: 1;
        }

        #map1 {
            width: 100%;
            height: 100%;
        }

        #hospitalInfo {
            position: absolute;
            top: 15px;
            left: 15px;
            background: white;
            padding: 0;
            border-radius: 10px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.15);
            z-index: 10;
            min-width: 340px;
            max-width: 380px;
            max-height: 550px;
            overflow: hidden;
            display: none;
        }

        #hospitalInfo.active {
            display: block;
        }

        #hospitalInfo h4 {
            margin: 0;
            padding: 16px 18px;
            font-size: 16px;
            color: white;
            background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%);
            border-radius: 10px 10px 0 0;
            font-weight: 700;
        }

        .info-content {
            padding: 16px;
            max-height: 500px;
            overflow-y: auto;
        }

        #hospitalInfo .hospital-detail {
            margin: 0 0 12px 0;
            padding: 14px;
            background: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #5B6FB5;
            cursor: pointer;
            transition: all 0.3s;
        }

        #hospitalInfo .hospital-detail:hover {
            background: #e9ecef;
            transform: translateX(4px);
        }

        #hospitalInfo .detail-title {
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 8px;
            font-size: 14px;
        }

        #hospitalInfo .detail-info {
            font-size: 12px;
            color: #6c757d;
            margin: 5px 0;
            line-height: 1.5;
        }

        .hospital-category {
            display: inline-block;
            padding: 4px 10px;
            background: linear-gradient(135deg, #28a745 0%, #218838 100%);
            color: white;
            border-radius: 12px;
            font-size: 10px;
            font-weight: 600;
            margin-right: 5px;
            margin-bottom: 5px;
        }

        .distance-info {
            display: inline-block;
            padding: 4px 10px;
            background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
            color: white;
            border-radius: 12px;
            font-size: 10px;
            font-weight: 600;
        }

        .chat-container {
            width: 30%;
            height: 100%;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .chat-header {
            padding: 20px;
            background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%);
            color: white;
            font-weight: 700;
            font-size: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background: #f8f9fa;
        }

        .chat-message {
            margin-bottom: 16px;
            display: flex;
            flex-direction: column;
            animation: fadeIn 0.3s;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .chat-message.user {
            align-items: flex-end;
        }

        .chat-message.ai {
            align-items: flex-start;
        }

        .message-bubble {
            max-width: 80%;
            padding: 12px 16px;
            border-radius: 12px;
            font-size: 14px;
            line-height: 1.5;
            word-wrap: break-word;
        }

        .chat-message.user .message-bubble {
            background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%);
            color: white;
            border-bottom-right-radius: 4px;
        }

        .chat-message.ai .message-bubble {
            background: white;
            color: #333;
            border: 1px solid #e0e0e0;
            border-bottom-left-radius: 4px;
        }

        .chat-input-area {
            padding: 16px;
            background: white;
            border-top: 1px solid #e0e0e0;
            display: flex;
            gap: 10px;
        }

        .chat-input {
            flex: 1;
            padding: 12px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            outline: none;
            transition: border-color 0.3s;
        }

        .chat-input:focus {
            border-color: #5B6FB5;
        }

        .chat-send-btn {
            padding: 12px 24px;
            background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .chat-send-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(91, 111, 181, 0.3);
        }

        .chat-send-btn:active {
            transform: translateY(0);
        }

        .info-content::-webkit-scrollbar,
        .chat-messages::-webkit-scrollbar {
            width: 6px;
        }

        .info-content::-webkit-scrollbar-track,
        .chat-messages::-webkit-scrollbar-track {
            background: #f1f1f1;
        }

        .info-content::-webkit-scrollbar-thumb,
        .chat-messages::-webkit-scrollbar-thumb {
            background: #5B6FB5;
            border-radius: 3px;
        }

        .info-content::-webkit-scrollbar-thumb:hover,
        .chat-messages::-webkit-scrollbar-thumb:hover {
            background: #4a5a9e;
        }

        @media (max-width: 768px) {
            .main-container {
                padding: 15px;
            }

            .page-header h1 {
                font-size: 22px;
            }

            .map-chat-container {
                flex-direction: column;
                height: auto;
            }

            #container {
                width: 100%;
                height: 400px;
            }

            .chat-container {
                width: 100%;
                height: 500px;
            }

            #hospitalInfo {
                min-width: 280px;
                max-width: 320px;
            }

            .nav-menu {
                display: none;
            }
        }

        /* Footer */
        footer {
            background: #2c3e50;
            color: white;
            padding: 60px 40px 30px;
        }

        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 60px;
            margin-bottom: 30px;
        }

        .footer-info h3 {
            font-size: 24px;
            margin-bottom: 20px;
        }

        .footer-info p {
            color: #bdc3c7;
            margin-bottom: 10px;
        }

        .footer-contact h3 {
            font-size: 20px;
            margin-bottom: 20px;
        }

        .contact-number {
            font-size: 32px;
            color: #5B6FB5;
            font-weight: bold;
            margin-bottom: 15px;
        }

        .footer-bottom {
            text-align: center;
            padding-top: 30px;
            border-top: 1px solid #34495e;
            color: #95a5a6;
        }

    </style>
</head>
<body>
<header>
    <nav>
        <a href="<c:url value="/"/>" class="logo">🏥 AI 의료 매칭 시스템</a>
        <ul class="nav-menu">
            <li><a href="<c:url value="/"/>">홈</a></li>
            <li><a href="<c:url value="/#services"/>">서비스 소개</a></li>
            <li><a href="<c:url value="/#diagnosis"/>">자가진단</a></li>
            <li><a href="<c:url value="/map/map1"/>" style="color: #5B6FB5;">병원찾기</a></li>
            <li><a href="<c:url value="/#contact"/>">문의하기</a></li>
        </ul>
    </nav>
</header>

<div class="main-container">
    <div class="page-header">
        <h1>🏥 병원 찾기</h1>
        <p>현재 위치 주변의 병원을 찾아보세요. AI 기반 스마트 매칭으로 최적의 병원을 추천해드립니다.</p>
    </div>

    <div style="text-align: right; margin-bottom: 10px;">
        <button onclick="changeLanguage('ko')" class="btn btn-sm btn-outline-primary">🇰🇷 한국어</button>
        <button onclick="changeLanguage('en')" class="btn btn-sm btn-outline-primary">🇺🇸 English</button>
        <button onclick="changeLanguage('jp')" class="btn btn-sm btn-outline-primary">🇯🇵 日本語</button>
        <button onclick="changeLanguage('cn')" class="btn btn-sm btn-outline-primary">🇨🇳 中文</button>
    </div>

    <div class="control-panel">
        <div class="control-buttons">
            <button id="btn-my-location" class="btn btn-primary"> 현재 위치</button>
            <button id="btn-find-nearby" class="btn btn-success"> 가까운 병원</button>
            <button id="btn-emergency" class="btn btn-danger"> 응급실</button>
            <button id="btn-refresh" class="btn btn-secondary"> 새로고침</button>
        </div>
    </div>

    <div class="map-chat-container">
        <div id="container">
            <div id="hospitalInfo">
                <h4>병원 정보</h4>
                <div class="info-content"></div>
            </div>
            <div id="mapWrapper">
                <div id="map1"></div>
            </div>
        </div>

        <div class="chat-container">
            <div class="chat-header">
                AI 병원 상담
            </div>
            <div class="chat-messages" id="chatMessages">
                <div class="chat-message ai">
                    <div class="message-bubble">
                        안녕하세요! AI 의료 상담 챗봇입니다.<br>
                        궁금하신 점을 물어보세요.<br><br>
                        💡 <strong>"도움말"</strong>을 입력하면 전체 기능을 볼 수 있습니다.
                    </div>
                </div>
            </div>
            <div class="chat-input-area">
                <input type="text" class="chat-input" id="chatInput" placeholder="메시지를 입력하세요..." autocomplete="off">
                <button class="chat-send-btn" id="chatSendBtn">전송</button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=f37b6c5eb063be1a82888e664e204d6d&libraries=services,drawing,clusterer"></script>
<script>
    // 1. 현재 선택된 언어 (기본값: 한국어)
    var currentLang = 'ko';

    // 2. 번역 사전 (UI 텍스트)
    var translations = {
        'ko': {
            'title': '🏥 병원 찾기',
            'desc': '현재 위치 주변의 병원을 찾아보세요.',
            'btn_loc': '현재 위치',
            'btn_near': '가까운 병원',
            'btn_emer': '응급실',
            'btn_refresh': '새로고침',
            'chat_welcome': '안녕하세요! AI 의료 상담 챗봇입니다.<br>궁금하신 점을 물어보세요.',
            'placeholder': '메시지를 입력하세요...',
            'send': '전송',
            'searching': '검색 중입니다...',
            'error': '오류가 발생했습니다.',
            'loc_denied': '위치 정보 권한이 필요합니다.'
        },
        'en': {
            'title': '🏥 Hospital Finder',
            'desc': 'Find hospitals near your current location.',
            'btn_loc': 'My Location',
            'btn_near': 'Nearby Hospitals',
            'btn_emer': 'Emergency',
            'btn_refresh': 'Refresh',
            'chat_welcome': 'Hello! I am your AI Medical Assistant.<br>How can I help you?',
            'placeholder': 'Type a message...',
            'send': 'Send',
            'searching': 'Searching...',
            'error': 'An error occurred.',
            'loc_denied': 'Location permission is required.'
        },
        'jp': {
            'title': '🏥 病院検索',
            'desc': '現在地周辺の病院を検索します。',
            'btn_loc': '現在地',
            'btn_near': '近くの病院',
            'btn_emer': '救急救命室',
            'btn_refresh': '更新',
            'chat_welcome': 'こんにちは！AI医療相談チャットボットです。<br>何かお手伝いしましょうか？',
            'placeholder': 'メッセージを入力...',
            'send': '送信',
            'searching': '検索中...',
            'error': 'エラーが発生しました。',
            'loc_denied': '位置情報の権限が必要です。'
        },
        'cn': {
            'title': '🏥 寻找医院',
            'desc': '查找当前位置附近的医院。',
            'btn_loc': '当前位置',
            'btn_near': '附近的医院',
            'btn_emer': '急诊室',
            'btn_refresh': '刷新',
            'chat_welcome': '你好！我是AI医疗咨询助手。<br>请问有什么可以帮您？',
            'placeholder': '输入消息...',
            'send': '发送',
            'searching': '搜索中...',
            'error': '发生错误。',
            'loc_denied': '需要位置权限。'
        }
    };

    // 3. 언어 변경 함수
    function changeLanguage(lang) {
        currentLang = lang;
        var t = translations[lang];

        // UI 텍스트 변경
        $('.page-header h1').text(t.title);
        $('.page-header p').text(t.desc);
        $('#btn-my-location').text(t.btn_loc);
        $('#btn-find-nearby').text(t.btn_near);
        $('#btn-emergency').text(t.btn_emer);
        $('#btn-refresh').text(t.btn_refresh);
        $('#chatInput').attr('placeholder', t.placeholder);
        $('#chatSendBtn').text(t.send);

        // 채팅창 초기화 메시지도 변경
        $('#chatMessages').html('<div class="chat-message ai"><div class="message-bubble">' + t.chat_welcome + '</div></div>');
    }

    var hospitalMap = {
        map: null,
        currentLocationMarker: null,
        hospitalMarkers: [],
        hospitalOverlays: [],
        activeOverlay: null,
        polylines: [],
        currentPosition: null,
        places: null,
        searchedHospitals: [],

        init: function() {
            console.log('hospitalMap init 시작');

            this.currentLocationMarker = new kakao.maps.Marker({
                title: '현재 위치',
                zIndex: 100
            });

            this.makeMap();
            this.setupEventListeners();
        },

        makeMap: function() {
            var mapContainer = document.getElementById('map1');
            var mapOption = {
                center: new kakao.maps.LatLng(37.5665, 126.9780),
                level: 6
            };
            this.map = new kakao.maps.Map(mapContainer, mapOption);
            this.map.addControl(new kakao.maps.MapTypeControl(), kakao.maps.ControlPosition.TOPRIGHT);
            this.map.addControl(new kakao.maps.ZoomControl(), kakao.maps.ControlPosition.RIGHT);

            this.places = new kakao.maps.services.Places();

            this.getCurrentLocation(true);
        },

        setupEventListeners: function() {
            var self = this;
            document.getElementById('btn-my-location').addEventListener('click', function() {
                self.getCurrentLocation(true);
            });
            document.getElementById('btn-find-nearby').addEventListener('click', function() {
                self.searchNearbyHospitals();
            });
            document.getElementById('btn-emergency').addEventListener('click', function() {
                self.searchEmergencyHospitals();
            });
            document.getElementById('btn-refresh').addEventListener('click', function() {
                self.refreshMap();
            });
        },

        getCurrentLocation: function(panTo) {
            var self = this;
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function(position) {
                    var lat = position.coords.latitude;
                    var lng = position.coords.longitude;
                    self.currentPosition = new kakao.maps.LatLng(lat, lng);
                    self.currentLocationMarker.setPosition(self.currentPosition);
                    self.currentLocationMarker.setMap(self.map);

                    if(panTo) {
                        self.map.setLevel(5);
                        self.map.panTo(self.currentPosition);
                    }
                }, function(error) {
                    console.error('위치 정보 오류:', error);
                    self.currentPosition = new kakao.maps.LatLng(37.5665, 126.9780);
                    self.currentLocationMarker.setPosition(self.currentPosition);
                    self.currentLocationMarker.setMap(self.map);
                    if(panTo) self.map.panTo(self.currentPosition);
                });
            }
        },

        searchNearbyHospitals: function() {
            if (!this.currentPosition) {
                alert('현재 위치를 먼저 확인해주세요.');
                return;
            }

            var self = this;
            this.clearHospitalMarkers();

            var options = {
                location: this.currentPosition,
                radius: 15000,
                sort: kakao.maps.services.SortBy.DISTANCE
            };

            this.places.categorySearch('HP8', function(result, status) {
                if (status === kakao.maps.services.Status.OK) {
                    self.searchedHospitals = result;
                    self.displaySearchResults(result, '주변 병원');

                    for(var i = 0; i < result.length; i++) {
                        self.createPlaceMarker(result[i], i);
                    }
                } else {
                    alert('주변 병원 검색에 실패했습니다.');
                }
            }, options);
        },

        searchEmergencyHospitals: function() {
            if (!this.currentPosition) {
                alert('현재 위치를 먼저 확인해주세요.');
                return;
            }

            var self = this;
            this.clearHospitalMarkers();

            // 응급실 검색 범위를 15km로 확대
            var options = {
                location: this.currentPosition,
                radius: 15000,
                sort: kakao.maps.services.SortBy.DISTANCE
            };

            // 먼저 '응급실' 키워드로 검색
            this.places.keywordSearch('응급실', function(result, status) {
                if (status === kakao.maps.services.Status.OK && result.length > 0) {
                    self.searchedHospitals = result;
                    self.displaySearchResults(result, '응급실 운영 병원');

                    for(var i = 0; i < result.length; i++) {
                        self.createPlaceMarker(result[i], i);
                    }
                } else {
                    // 응급실 검색 결과가 없으면 종합병원 검색
                    self.places.keywordSearch('종합병원', function(result2, status2) {
                        if (status2 === kakao.maps.services.Status.OK && result2.length > 0) {
                            self.searchedHospitals = result2;
                            self.displaySearchResults(result2, '가까운 종합병원 (응급실 확인 필요)');

                            for(var i = 0; i < result2.length; i++) {
                                self.createPlaceMarker(result2[i], i);
                            }
                        } else {
                            alert('주변에 응급실 또는 종합병원을 찾을 수 없습니다.\n검색 범위를 넓혀서 다시 시도해보세요.');
                        }
                    }, options);
                }
            }, options);
        },

        searchByKeyword: function(keyword) {
            var self = this;
            this.clearHospitalMarkers();

            // chatHandler의 detectRegion 함수를 사용하여 지역명 포함 여부 확인
            var region = chatHandler.detectRegion(keyword.toLowerCase());

            // '가까운' 키워드가 명시적으로 포함되어 있는지 확인
            var isNearbyRequest = keyword.includes('가까운') || keyword.includes('근처') || keyword.includes('주변');

            var options = {};

            // 1. 반경 제한을 두는 조건: '가까운' 요청이 명시적으로 있을 때
            if (isNearbyRequest && !region) {
                options.location = this.currentPosition || new kakao.maps.LatLng(37.5665, 126.9780);
                options.radius = 15000;
                options.sort = kakao.maps.services.SortBy.DISTANCE;
                console.log('-> 가까운 곳 15km 검색');
            }
            // 2. 반경 제한을 해제하는 조건: 특정 지역명이 있거나, 전국구 병원 검색일 때
            else {
                options.location = null;
                options.radius = null;
                console.log('-> 전국/지역 전체 검색');
            }

            // [수정된 로직 시작]
            // 1. '가까운', '근처' 등의 위치 한정 키워드를 검색어에서 제거
            var cleanedKeyword = keyword.replace(/가까운|근처|주변|가까이/g, '').trim();

            // 2. 검색어에 '병원'이나 '의원'이 없으면 '의원'을 기본으로 추가하여 검색
            var finalSearchKeyword = cleanedKeyword;
            if (!cleanedKeyword.includes('병원') && !cleanedKeyword.includes('의원') && !cleanedKeyword.includes('클리닉')) {
                // 예를 들어, '내과'만 남은 경우, '내과 의원'으로 검색
                finalSearchKeyword = cleanedKeyword + ' 의원';
            }
            // [수정된 로직 종료]

            this.places.keywordSearch(finalSearchKeyword, function(result, status) {
                if (status === kakao.maps.services.Status.OK) {
                    self.searchedHospitals = result;

                    if (result.length > 0) {
                        self.displaySearchResults(result, keyword + ' 검색 결과');

                        for(var i = 0; i < result.length; i++) {
                            self.createPlaceMarker(result[i], i);
                        }

                        var firstPlace = result[0];
                        var position = new kakao.maps.LatLng(firstPlace.y, firstPlace.x);

                        // 검색 결과에 따라 지도의 줌 레벨 조정
                        if (options.radius === 15000) {
                            self.map.setLevel(6); // 15km 검색 시 레벨 6
                        } else if (options.radius === 5000) {
                            self.map.setLevel(4); // 5km 검색 시 레벨 4
                        } else {
                            self.map.setLevel(7); // 지역 전체 검색 시 레벨 7
                        }
                        self.map.panTo(position);
                    }
                    else {
                        chatHandler.addMessage('죄송합니다. ' + keyword + ' 병원을 찾을 수 없습니다.', 'ai');
                    }
                    return result;
                } else {
                    return [];
                }
            }, options);
        },

        createPlaceMarker: function(place, index) {
            var self = this;
            var markerImage = new kakao.maps.MarkerImage(
                'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png',
                new kakao.maps.Size(48, 52),
                {offset: new kakao.maps.Point(24, 52)}
            );

            var marker = new kakao.maps.Marker({
                position: new kakao.maps.LatLng(place.y, place.x),
                image: markerImage,
                title: place.place_name
            });

            var distance = this.currentPosition ?
                Math.round(this.getDistance(this.currentPosition, new kakao.maps.LatLng(place.y, place.x))) : 0;

            // 작은따옴표 이스케이프 처리
            var escapedName = place.place_name.replace(/'/g, "\\'");

            var content = '<div style="position:absolute;left:-150px;bottom:50px;width:300px;">' +
                '<div style="border:2px solid #28a745;border-radius:8px;background:#fff;box-shadow:0 2px 8px rgba(0,0,0,0.2);">' +
                '<div style="height:36px;background:#28a745;padding:8px 12px;color:#fff;font-size:14px;font-weight:bold;display:flex;align-items:center;justify-content:space-between;border-radius:6px 6px 0 0;">' +
                '<span> ' + place.place_name + '</span>' +
                '<div onclick="hospitalMap.closeOverlay(' + index + ')" style="color:#fff;width:18px;height:18px;cursor:pointer;">✕</div>' +
                '</div>' +
                '<div style="padding:12px;">' +
                '<div style="margin-bottom:10px;"><span style="display:inline-block;padding:4px 10px;background:#28a745;color:white;border-radius:12px;font-size:10px;">' + place.category_name.split('>').pop().trim() + '</span></div>' +
                '<div style="margin:8px 0;"><strong> 주소:</strong><br/>' + (place.road_address_name || place.address_name) + '</div>' +
                (place.phone ? '<div style="margin:8px 0;"><strong> 전화:</strong> ' + place.phone + '</div>' : '') +
                (distance > 0 ? '<div style="margin:8px 0;"><strong> 거리:</strong> ' + (distance/1000).toFixed(1) + 'km</div>' : '') +
                '<div style="text-align:center;margin-top:12px;">' +
                '<button onclick="window.open(\'' + place.place_url + '\')" style="padding:8px 16px;background:#28a745;color:#fff;border:none;border-radius:4px;cursor:pointer;margin-right:5px;font-size:12px;">상세정보</button>' +
                '<button onclick="hospitalMap.findRoute(' + place.y + ',' + place.x + ',\'' + escapedName + '\')" style="padding:8px 16px;background:#007bff;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:12px;">길찾기</button>' +
                '</div></div></div></div>';

            var customOverlay = new kakao.maps.CustomOverlay({
                content: content,
                position: marker.getPosition(),
                xAnchor: 0.5,
                yAnchor: 1.1,
                zIndex: 3
            });

            kakao.maps.event.addListener(marker, 'click', function() {
                self.closeAllOverlays();
                customOverlay.setMap(self.map);
                self.activeOverlay = customOverlay;
                self.map.panTo(marker.getPosition());
            });

            marker.setMap(this.map);
            this.hospitalMarkers.push(marker);
            this.hospitalOverlays.push(customOverlay);
        },

        displaySearchResults: function(places, title) {
            var infoHTML = '<div style="padding:10px;"><h5>' + title + ' (' + places.length + '개)</h5></div>';

            var displayCount = Math.min(10, places.length);
            for(var i = 0; i < displayCount; i++) {
                var place = places[i];
                var distance = '';

                if (this.currentPosition) {
                    var dist = this.getDistance(
                        this.currentPosition,
                        new kakao.maps.LatLng(place.y, place.x)
                    );
                    distance = '<div class="detail-info"><span class="distance-info">거리: ' +
                        (dist/1000).toFixed(1) + 'km</span></div>';
                }

                infoHTML += '<div class="hospital-detail" onclick="hospitalMap.focusPlace(' + i + ')">' +
                    '<div class="detail-title">' + (i + 1) + '. ' + place.place_name + '</div>' +
                    '<div class="detail-info">' + (place.road_address_name || place.address_name) + '</div>' +
                    (place.phone ? '<div class="detail-info"> ' + place.phone + '</div>' : '') +
                    distance +
                    '</div>';
            }

            document.querySelector('#hospitalInfo .info-content').innerHTML = infoHTML;
            document.getElementById('hospitalInfo').className = 'active';
        },

        focusPlace: function(index) {
            if (index < this.searchedHospitals.length) {
                var place = this.searchedHospitals[index];
                var position = new kakao.maps.LatLng(place.y, place.x);
                this.map.setLevel(4);
                this.map.panTo(position);

                if (index < this.hospitalOverlays.length) {
                    this.closeAllOverlays();
                    this.hospitalOverlays[index].setMap(this.map);
                    this.activeOverlay = this.hospitalOverlays[index];
                }
            }
        },

        findRoute: function(lat, lng, name) {
            if (!this.currentPosition) {
                alert('현재 위치가 설정되지 않았습니다.');
                return;
            }

            // 기존 경로 제거
            for(var i = 0; i < this.polylines.length; i++) {
                this.polylines[i].setMap(null);
            }
            this.polylines = [];

            var destination = new kakao.maps.LatLng(lat, lng);
            var distance = this.getDistance(this.currentPosition, destination);

            // 점선 스타일로 경로 표시
            var polyline = new kakao.maps.Polyline({
                path: [this.currentPosition, destination],
                strokeWeight: 4,
                strokeColor: '#4A90E2',
                strokeOpacity: 0.7,
                strokeStyle: 'shortdashdot'
            });

            polyline.setMap(this.map);
            this.polylines.push(polyline);

            // 지도 범위 조정
            var bounds = new kakao.maps.LatLngBounds();
            bounds.extend(this.currentPosition);
            bounds.extend(destination);
            this.map.setBounds(bounds);

            var distanceKm = (distance / 1000).toFixed(1);

            // 이동수단별 예상 시간 계산
            var walkTime = Math.ceil(distance / 67);     // 도보: 시속 4km
            var carTime = Math.ceil(distance / 500);      // 자동차: 시속 30km
            var transitTime = Math.ceil(distance / 333);  // 대중교통: 시속 20km

            // 카카오맵 길찾기 URL 생성
            var originLat = this.currentPosition.getLat();
            var originLng = this.currentPosition.getLng();
            var kakaoMapUrl = 'https://map.kakao.com/link/to/' +
                encodeURIComponent(name) + ',' + lat + ',' + lng +
                '/from/현재위치,' + originLat + ',' + originLng;

            var message = ' ' + name + '까지\n\n' +
                ' 직선거리: ' + distanceKm + 'km\n\n' +
                '⏱ 예상 소요시간:\n' +
                ' 도보: 약 ' + walkTime + '분\n' +
                ' 자동차: 약 ' + carTime + '분\n' +
                ' 대중교통: 약 ' + transitTime + '분\n\n' +
                '※ 직선거리 기준 예상시간입니다.\n' +
                '정확한 경로는 "확인"을 클릭하세요.';

            if(confirm(message + '\n\n카카오맵에서 상세 길찾기를 확인하시겠습니까?')) {
                window.open(kakaoMapUrl, '_blank');
            }
        },

        getDistance: function(pos1, pos2) {
            var R = 6371000;
            var lat1 = pos1.getLat() * Math.PI / 180;
            var lat2 = pos2.getLat() * Math.PI / 180;
            var deltaLat = (pos2.getLat() - pos1.getLat()) * Math.PI / 180;
            var deltaLng = (pos2.getLng() - pos1.getLng()) * Math.PI / 180;

            var a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) +
                Math.cos(lat1) * Math.cos(lat2) *
                Math.sin(deltaLng/2) * Math.sin(deltaLng/2);
            var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
            return R * c;
        },

        clearHospitalMarkers: function() {
            for(var i = 0; i < this.hospitalMarkers.length; i++) {
                this.hospitalMarkers[i].setMap(null);
            }
            this.hospitalMarkers = [];
            this.closeAllOverlays();
            this.hospitalOverlays = [];
        },

        closeAllOverlays: function() {
            for(var i = 0; i < this.hospitalOverlays.length; i++) {
                this.hospitalOverlays[i].setMap(null);
            }
            this.activeOverlay = null;
        },

        closeOverlay: function(index) {
            if (this.hospitalOverlays[index]) {
                this.hospitalOverlays[index].setMap(null);
            }
        },

        refreshMap: function() {
            this.clearHospitalMarkers();
            for(var i = 0; i < this.polylines.length; i++) {
                this.polylines[i].setMap(null);
            }
            this.polylines = [];
            this.searchedHospitals = [];
            document.getElementById('hospitalInfo').className = '';
            if (this.currentPosition) {
                this.map.setLevel(5);
                this.map.panTo(this.currentPosition);
            }
        }
    };

    var chatHandler = {
        // 🧠 기억 저장소
        lastMedicalKeyword: null,

        init: function() {
            console.log('AI 채팅 핸들러 초기화');
            var sendBtn = document.getElementById('chatSendBtn');
            var input = document.getElementById('chatInput');
            if (!sendBtn || !input) return;

            var self = this;
            sendBtn.addEventListener('click', function() { self.sendMessage(); });
            input.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') self.sendMessage();
            });
        },

        sendMessage: function() {
            var input = document.getElementById('chatInput');
            var message = input.value.trim();
            if (!message) return;

            this.addMessage(message, 'user');
            input.value = '';
            this.processMessage(message);
        },

        processMessage: function(message) {
            var self = this;

            $.ajax({
                url: '/map/chat',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({
                    message: message,
                    language: currentLang
                }),
                success: function(response) {
                    console.log("🤖 AI 응답:", response);

                    if (response.answer) {
                        self.addMessage(response.answer, 'ai');
                    }

                    var keyword = response.keyword;
                    if (!keyword) {
                        keyword = self.extractKeywordFromMessage(message);
                    }

                    var userRegion = self.detectRegion(message);
                    var aiAction = response.action;

                    // ============================================================
                    // 🔥 [최종 수정] 4개 국어 '가까운' 감지 & 문맥 연결
                    // ============================================================

                    // 1. 진료과 기억 저장
                    if (self.isMedicalTerm(keyword)) {
                        self.lastMedicalKeyword = keyword;
                        console.log("💾 새로운 기억 저장:", self.lastMedicalKeyword);
                    }

                    // 2. 거리(가까운) 의도 감지 (4개 국어 완벽 지원) ✅ 작성하신 부분 적용!
                    var wantsNearby = false;
                    var lowerMsg = message.toLowerCase();

                    if (currentLang === 'en') {
                        wantsNearby = lowerMsg.match(/near|nearby|close|here|around/);
                    } else if (currentLang === 'jp') {
                        wantsNearby = message.match(/近く|近所|周辺|ここ|付近/);
                    } else if (currentLang === 'cn') {
                        wantsNearby = message.match(/附近|在这|周围|身边/);
                    } else {
                        wantsNearby = message.match(/가까운|근처|주변|내위치|현재위치/);
                    }

                    // 3. 문맥 연결 (기억력 발동!)
                    // 지역만 말했거나, '가까운'이라고만 했을 때 -> 아까 말한 진료과 소환
                    if ((userRegion || wantsNearby) && !self.isMedicalTerm(keyword) && self.lastMedicalKeyword) {
                        console.log("💡 문맥 복원: (기억)" + self.lastMedicalKeyword);
                        keyword = self.lastMedicalKeyword;
                        aiAction = 'SEARCH';
                    }
                    // ============================================================

                    if (aiAction === 'SEARCH' || keyword) {
                        if (!keyword) keyword = self.lastMedicalKeyword;

                        if (keyword) {
                            // A. 지역명 결합
                            if (userRegion) {
                                if (!keyword.includes(userRegion)) {
                                    keyword = userRegion + " " + keyword;
                                }
                                console.log("📍 지역 검색:", keyword);
                            }
                            // B. 지역명 없으면 -> 내 주변 ('가까운' 붙이기)
                            else {
                                // 지도 API 검색어 보정 (한글 '가까운'이 제일 정확함)
                                if (!keyword.match(/가까운|근처|주변/)) {
                                    keyword = "가까운 " + keyword;
                                }
                                console.log("📍 내 주변 검색:", keyword);
                            }

                            if (typeof hospitalMap !== 'undefined') {
                                hospitalMap.searchByKeyword(keyword);
                            }
                        }
                    }
                    else if (aiAction === 'EMERGENCY') {
                        hospitalMap.searchEmergencyHospitals();
                    }
                },
                error: function(err) {
                    console.error("❌ 통신 오류:", err);
                    // 에러 시 백업 로직
                    var keyword = self.extractKeywordFromMessage(message);

                    if (self.isMedicalTerm(keyword)) self.lastMedicalKeyword = keyword;
                    if (!keyword && self.lastMedicalKeyword) keyword = self.lastMedicalKeyword;

                    if (keyword) {
                        // 에러 났을 때도 지역 없으면 '가까운' 붙여서 검색
                        var userRegion = self.detectRegion(message);
                        if (userRegion) keyword = userRegion + " " + keyword;
                        else keyword = "가까운 " + keyword;

                        self.addMessage((currentLang==='en'?"Auto search: ":"자동 검색: ") + keyword, 'ai');
                        hospitalMap.searchByKeyword(keyword);
                    } else {
                        self.addMessage((currentLang==='en'?"Error occurred.":"오류가 발생했습니다."), 'ai');
                    }
                }
            });
        },

        isMedicalTerm: function(keyword) {
            if (!keyword) return false;
            // '병원', '의원' 등은 너무 흔해서 제외하거나 포함할지 결정. 여기선 포함.
            return keyword.match(/내과|외과|정형외과|신경과|안과|이비인후과|피부과|치과|한의원|응급실|산부인과|비뇨기과|소아과|병원|의원/);
        },

        detectRegion: function(msg) {
            var regions = ['서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종', '경기', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주', '수원', '용인', '고양', '성남', '부천', '안산', '안양', '평택', '시흥', '화성', '남양주', '김포', '파주', '의정부', '광명', '하남', '오산', '이천', '천안', '청주', '포항', '창원', '전주', '목포', '순천', '원주', '춘천', '강남', '강북', '종로', '중구', '용산', '성동', '광진', '동대문', '성북', '도봉', '노원', '은평', '서대문', '마포', '양천', '강서', '구로', '영등포', '동작', '관악', '서초', '송파', '강동', '아산', '탕정', '잠실'];
            for (var i = 0; i < regions.length; i++) {
                if (msg.includes(regions[i])) return regions[i];
            }
            return null;
        },

        extractKeywordFromMessage: function(msg) {
            var lowerMsg = msg.toLowerCase();
            if (lowerMsg.match(/응급|급해|위급|emergency|urgent/)) return '응급실';
            if (lowerMsg.match(/머리|두통|head|headache|편두통|감기|cold|flu|배|복통|stomach|pain|내과/)) return '내과';
            if (lowerMsg.match(/허리|back|요통|디스크|무릎|knee|관절|joint|뼈|bone|정형외과/)) return '정형외과';
            if (lowerMsg.match(/치아|tooth|teeth|dental|이빨|치과/)) return '치과';
            if (lowerMsg.match(/피부|skin|rash|dermatology/)) return '피부과';
            if (lowerMsg.match(/눈|eye|vision|안과/)) return '안과';
            if (lowerMsg.match(/귀|ear|코|nose|목|throat|이비인후과/)) return '이비인후과';
            if (msg.includes('병원') || msg.includes('hospital') || msg.includes('clinic')) return msg;
            return null;
        },

        addMessage: function(text, sender) {
            var messagesDiv = document.getElementById('chatMessages');
            var messageDiv = document.createElement('div');
            messageDiv.className = 'chat-message ' + sender;
            var bubbleDiv = document.createElement('div');
            bubbleDiv.className = 'message-bubble';
            bubbleDiv.innerHTML = text.replace(/\n/g, '<br>');
            messageDiv.appendChild(bubbleDiv);
            messagesDiv.appendChild(messageDiv);
            messagesDiv.scrollTop = messagesDiv.scrollHeight;
        }
    };

    document.addEventListener('DOMContentLoaded', function() {
        kakao.maps.load(function() {
            console.log('초기화 시작: DOM 및 카카오 맵 로드 완료');

            try {
                hospitalMap.init();
            } catch (e) {
                console.error('⚠️ 지도 초기화 중 오류 발생:', e);
            }

            chatHandler.init();
            console.log('채팅 핸들러 초기화 함수 호출 완료');
        });
    });

</script>

<!-- Footer -->
<footer id="contact">
    <div class="footer-content">
        <div class="footer-info">
            <h3>AI 기반 의료 매칭 시스템</h3>
            <p>주소: 서울특별시 강남구, 대한민국 우편번호 06234</p>
            <p>이메일: contact@medical-ai.kr</p>
            <p>대표자: 홍길동</p>
        </div>
        <div class="footer-contact">
            <h3>전문 의료상담</h3>
            <div class="contact-number">1234-5678</div>
            <p>평일: AM 9:00 - PM 6:00</p>
            <p>토요일: AM 9:00 - PM 1:00</p>
            <p>일요일: PM 1:00 - PM 6:00</p>
        </div>
    </div>
    <div class="footer-bottom">
        <p>Copyright © 2025 AI 의료 매칭 시스템. All Rights Reserved.</p>
    </div>
</footer>

</body>
</html>