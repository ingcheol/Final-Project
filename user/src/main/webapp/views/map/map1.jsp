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
        /* 기존 스타일 유지 */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif; color: #333; background: #f5f7fa; }
        header { background: white; box-shadow: 0 2px 5px rgba(0,0,0,0.1); position: fixed; width: 100%; top: 0; z-index: 1000; }
        nav { max-width: 1400px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; padding: 20px 40px; }
        .logo { font-size: 24px; font-weight: bold; color: #5B6FB5; text-decoration: none; }
        .nav-menu { display: flex; gap: 40px; list-style: none; }
        .nav-menu a { text-decoration: none; color: #333; font-weight: 500; transition: color 0.3s; }
        .nav-menu a:hover { color: #5B6FB5; }
        .main-container { margin-top: 100px; padding: 25px 30px; max-width: 1400px; margin-left: auto; margin-right: auto; }
        .page-header { margin-bottom: 20px; }
        .page-header h1 { font-size: 28px; color: #2c3e50; margin-bottom: 8px; font-weight: 700; }
        .page-header p { font-size: 14px; color: #7f8c8d; }

        /* 컨트롤 패널 스타일 강화 */
        .control-panel { background: white; padding: 18px 20px; border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); margin-bottom: 20px; }
        .control-row { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; }
        .control-buttons { display: flex; gap: 10px; flex-wrap: wrap; }
        .btn { padding: 10px 20px; border: none; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.3s; display: inline-flex; align-items: center; gap: 6px; }
        .btn-primary { background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%); color: white; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(91, 111, 181, 0.3); }
        .btn-success { background: linear-gradient(135deg, #28a745 0%, #218838 100%); color: white; }
        .btn-success:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3); }
        .btn-danger { background: linear-gradient(135deg, #dc3545 0%, #c82333 100%); color: white; }
        .btn-danger:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3); }
        .btn-secondary { background: #6c757d; color: white; }
        .btn-secondary:hover { background: #5a6268; transform: translateY(-2px); }

        /* 🆕 응급실 실시간 조회 영역 스타일 */
        .er-search-area {
            background-color: #fff5f5;
            border: 1px solid #ffc9c9;
            border-radius: 8px;
            padding: 15px;
            margin-top: 15px;
            display: none; /* 기본 숨김 */
        }
        .er-search-area.active { display: block; animation: fadeIn 0.3s; }
        .er-controls { display: flex; gap: 10px; align-items: center; margin-bottom: 10px; }
        .er-select { padding: 8px; border: 1px solid #ddd; border-radius: 6px; font-size: 13px; min-width: 120px; }
        .er-result-list {
            max-height: 200px; overflow-y: auto; background: white; border: 1px solid #eee; border-radius: 6px;
        }
        .er-item {
            padding: 10px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; cursor: pointer;
        }
        .er-item:hover { background-color: #f8f9fa; }
        .er-name { font-weight: bold; font-size: 14px; }
        .er-status { font-size: 12px; }
        .er-badge {
            display: inline-block; padding: 2px 6px; border-radius: 4px; color: white; font-size: 11px; font-weight: bold; margin-left: 5px;
        }
        .bg-green { background-color: #28a745; }
        .bg-red { background-color: #dc3545; }
        .bg-yellow { background-color: #ffc107; color: #333; }


        /* 지도 및 채팅 레이아웃 */
        .map-chat-container { display: flex; gap: 20px; height: 600px; }
        #container { overflow: hidden; height: 100%; width: 70%; position: relative; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); background: white; }
        #mapWrapper { width: 100%; height: 100%; z-index: 1; }
        #map1 { width: 100%; height: 100%; }

        /* 병원 정보 오버레이 */
        #hospitalInfo { position: absolute; top: 15px; left: 15px; background: white; padding: 0; border-radius: 10px; box-shadow: 0 4px 16px rgba(0,0,0,0.15); z-index: 10; min-width: 340px; max-width: 380px; max-height: 550px; overflow: hidden; display: none; }
        #hospitalInfo.active { display: block; }
        #hospitalInfo h4 { margin: 0; padding: 16px 18px; font-size: 16px; color: white; background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%); border-radius: 10px 10px 0 0; font-weight: 700; }
        .info-content { padding: 16px; max-height: 500px; overflow-y: auto; }
        #hospitalInfo .hospital-detail { margin: 0 0 12px 0; padding: 14px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #5B6FB5; cursor: pointer; transition: all 0.3s; }
        #hospitalInfo .hospital-detail:hover { background: #e9ecef; transform: translateX(4px); }
        #hospitalInfo .detail-title { font-weight: 700; color: #2c3e50; margin-bottom: 8px; font-size: 14px; }
        #hospitalInfo .detail-info { font-size: 12px; color: #6c757d; margin: 5px 0; line-height: 1.5; }
        .distance-info { display: inline-block; padding: 4px 10px; background: linear-gradient(135deg, #007bff 0%, #0056b3 100%); color: white; border-radius: 12px; font-size: 10px; font-weight: 600; }

        /* 채팅창 */
        .chat-container { width: 30%; height: 100%; background: white; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); display: flex; flex-direction: column; overflow: hidden; }
        .chat-header { padding: 20px; background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%); color: white; font-weight: 700; font-size: 16px; display: flex; align-items: center; gap: 8px; }
        .chat-messages { flex: 1; padding: 20px; overflow-y: auto; background: #f8f9fa; }
        .chat-message { margin-bottom: 16px; display: flex; flex-direction: column; animation: fadeIn 0.3s; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .chat-message.user { align-items: flex-end; }
        .chat-message.ai { align-items: flex-start; }
        .message-bubble { max-width: 80%; padding: 12px 16px; border-radius: 12px; font-size: 14px; line-height: 1.5; word-wrap: break-word; }
        .chat-message.user .message-bubble { background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%); color: white; border-bottom-right-radius: 4px; }
        .chat-message.ai .message-bubble { background: white; color: #333; border: 1px solid #e0e0e0; border-bottom-left-radius: 4px; }
        .chat-input-area { padding: 16px; background: white; border-top: 1px solid #e0e0e0; display: flex; gap: 10px; }
        .chat-input { flex: 1; padding: 12px 16px; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 14px; outline: none; transition: border-color 0.3s; }
        .chat-input:focus { border-color: #5B6FB5; }
        .chat-send-btn { padding: 12px 24px; background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%); color: white; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.3s; }
        .chat-send-btn:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(91, 111, 181, 0.3); }

        /* 스크롤바 커스텀 */
        .info-content::-webkit-scrollbar, .chat-messages::-webkit-scrollbar, .er-result-list::-webkit-scrollbar { width: 6px; }
        .info-content::-webkit-scrollbar-track, .chat-messages::-webkit-scrollbar-track, .er-result-list::-webkit-scrollbar-track { background: #f1f1f1; }
        .info-content::-webkit-scrollbar-thumb, .chat-messages::-webkit-scrollbar-thumb, .er-result-list::-webkit-scrollbar-thumb { background: #5B6FB5; border-radius: 3px; }

        @media (max-width: 768px) {
            .main-container { padding: 15px; }
            .map-chat-container { flex-direction: column; height: auto; }
            #container { width: 100%; height: 400px; }
            .chat-container { width: 100%; height: 500px; }
            #hospitalInfo { min-width: 280px; max-width: 320px; }
            .nav-menu { display: none; }
        }

        /* Footer */
        footer { background: #2c3e50; color: white; padding: 60px 40px 30px; }
        .footer-content { max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: 2fr 1fr; gap: 60px; margin-bottom: 30px; }
        .footer-bottom { text-align: center; padding-top: 30px; border-top: 1px solid #34495e; color: #95a5a6; }
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
        <p>현재 위치 주변의 병원을 찾거나, 실시간 응급실 병상을 조회해보세요.</p>
    </div>

    <div style="text-align: right; margin-bottom: 10px;">
        <button onclick="changeLanguage('ko')" class="btn btn-sm btn-outline-primary">🇰🇷 한국어</button>
        <button onclick="changeLanguage('en')" class="btn btn-sm btn-outline-primary">🇺🇸 English</button>
        <button onclick="changeLanguage('jp')" class="btn btn-sm btn-outline-primary">🇯🇵 日本語</button>
        <button onclick="changeLanguage('cn')" class="btn btn-sm btn-outline-primary">🇨🇳 中文</button>
    </div>

    <div class="control-panel">
        <div class="control-row">
            <div class="control-buttons">
                <button id="btn-my-location" class="btn btn-primary">📍 현재 위치</button>
                <button id="btn-find-nearby" class="btn btn-success">🏥 가까운 병원</button>
                <button id="btn-emergency" class="btn btn-danger">🚑 응급실 찾기 (지도)</button>
                <button id="btn-toggle-er" class="btn btn-danger" style="background: linear-gradient(135deg, #ff6b6b 0%, #ee5253 100%);">📊 실시간 응급병상 조회</button>
                <button id="btn-refresh" class="btn btn-secondary">🔄 새로고침</button>
            </div>
        </div>

        <div id="erPanel" class="er-search-area">
            <div class="er-controls">
                <span style="font-weight: bold; font-size: 14px;">지역 선택:</span>
                <select id="stage1" class="er-select">
                    <option value="">시/도 선택</option>
                </select>
                <select id="stage2" class="er-select">
                    <option value="">시/구/군 선택</option>
                </select>
                <button id="btn-search-realtime" class="btn btn-sm btn-primary">조회하기</button>
            </div>
            <div id="erLoading" style="display:none; text-align:center; padding:10px; font-size:13px;">
                데이터를 불러오는 중입니다... ⏳
            </div>
            <div id="erResultList" class="er-result-list">
                <div style="padding:20px; text-align:center; color:#999; font-size:13px;">
                    지역을 선택하고 조회 버튼을 눌러주세요.<br>
                    (실제 국립중앙의료원 데이터를 실시간으로 가져옵니다)
                </div>
            </div>
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
            <div class="chat-header">AI 병원 상담</div>
            <div class="chat-messages" id="chatMessages">
                <div class="chat-message ai">
                    <div class="message-bubble">
                        안녕하세요!<br>
                        AI 의료 상담 챗봇입니다.<br>
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
    // 1. 현재 선택된 언어
    var currentLang = 'ko';

    // 2. 번역 사전
    var translations = {
        'ko': {
            'title': '🏥 병원 찾기',
            'desc': '현재 위치 주변의 병원을 찾거나, 실시간 응급실 병상을 조회해보세요.',
            'btn_loc': '📍 현재 위치',
            'btn_near': '🏥 가까운 병원',
            'btn_emer': '🚑 응급실 찾기',
            'btn_er_real': '📊 실시간 응급병상',
            'btn_refresh': '🔄 새로고침',
            'chat_welcome': '안녕하세요! AI 의료 상담 챗봇입니다.<br>궁금하신 점을 물어보세요.',
            'placeholder': '메시지를 입력하세요...'
        },
        'en': {
            'title': '🏥 Hospital Finder',
            'desc': 'Find nearby hospitals or check real-time ER beds.',
            'btn_loc': '📍 My Location',
            'btn_near': '🏥 Nearby',
            'btn_emer': '🚑 Emergency Map',
            'btn_er_real': '📊 Real-time ER',
            'btn_refresh': '🔄 Refresh',
            'chat_welcome': 'Hello! I am your AI Medical Assistant.',
            'placeholder': 'Type a message...'
        },
        'jp': {
            'title': '🏥 病院検索',
            'desc': '近くの病院やリアルタイムの救急病床を検索します。',
            'btn_loc': '📍 現在地',
            'btn_near': '🏥 近くの病院',
            'btn_emer': '🚑 救急室(地図)',
            'btn_er_real': '📊 救急病床状況',
            'btn_refresh': '🔄 更新',
            'chat_welcome': 'こんにちは！AI医療相談チャットボットです。',
            'placeholder': 'メッセージを入力...'
        },
        'cn': {
            'title': '🏥 寻找医院',
            'desc': '查找附近的医院或实时急诊床位。',
            'btn_loc': '📍 当前位置',
            'btn_near': '🏥 附近的医院',
            'btn_emer': '🚑 急诊室(地图)',
            'btn_er_real': '📊 实时急诊床位',
            'btn_refresh': '🔄 刷新',
            'chat_welcome': '你好！我是AI医疗咨询助手。',
            'placeholder': '输入消息...'
        }
    };

    function changeLanguage(lang) {
        currentLang = lang;
        var t = translations[lang];
        $('.page-header h1').text(t.title);
        $('.page-header p').text(t.desc);
        $('#btn-my-location').text(t.btn_loc);
        $('#btn-find-nearby').text(t.btn_near);
        $('#btn-emergency').text(t.btn_emer);
        $('#btn-toggle-er').text(t.btn_er_real);
        $('#btn-refresh').text(t.btn_refresh);
        $('#chatInput').attr('placeholder', t.placeholder);

        // 채팅 초기화는 사용자가 대화중일 수 있으므로 생략하거나 필요시 추가
    }

    // ==========================================
    // 🆕 [추가] 실시간 응급실 정보 핸들러
    // ==========================================

    // map1.jsp 내부의 script 태그 안 erHandler 부분 수정

    var erHandler = {
        regionData: null,

        init: function() {
            var self = this;

            // 1. 지역 데이터 가져오기 (Controller API 호출)
            $.ajax({
                url: '/map/api/regions',
                type: 'GET',
                success: function(data) {
                    self.regionData = data;
                    self.renderStage1(data.stage1);
                },
                error: function(e) {
                    console.error("지역 데이터 로드 실패", e);
                }
            });

            // 2. 이벤트 리스너 설정
            $('#stage1').change(function() {
                var selectedSiDo = $(this).val();
                self.renderStage2(selectedSiDo);
            });

            $('#btn-toggle-er').click(function() {
                $('#erPanel').toggleClass('active');
            });

            $('#btn-search-realtime').click(function() {
                self.searchRealtimeER();
            });
        },

        renderStage1: function(stage1List) {
            var html = '<option value="">시/도 선택</option>';
            stage1List.forEach(function(item) {
                html += '<option value="' + item + '">' + item + '</option>';
            });
            $('#stage1').html(html);
        },

        renderStage2: function(sido) {
            var html = '<option value="">시/구/군 선택</option>';
            if (sido && this.regionData.stage2[sido]) {
                var list = this.regionData.stage2[sido];
                list.forEach(function(item) {
                    html += '<option value="' + item + '">' + item + '</option>';
                });
            }
            $('#stage2').html(html);
        },

        // 🔥 [수정됨] JSON 파싱 로직 적용
        // map1.jsp 내 script

        // ... 기존 코드 ...

        // 🔥 [수정됨] 시/군/구 선택 없이도 조회 가능하도록 변경
        searchRealtimeER: function() {
            var s1 = $('#stage1').val();
            var s2 = $('#stage2').val();

            // s1(시/도)만 필수 체크
            if (!s1) {
                alert("시/도를 선택해주세요.");
                return;
            }

            $('#erLoading').show();
            $('#erResultList').empty();

            // s2가 없으면 빈 문자열이나 null로 처리되지만,
            // Controller에서 required=false로 처리하므로 data 객체에 그대로 넘겨도 무방합니다.
            var requestData = { stage1: s1 };
            if (s2) {
                requestData.stage2 = s2;
            }

            $.ajax({
                url: '/map/api/er-realtime-info',
                data: requestData, // 👈 수정된 데이터 객체 전송
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    $('#erLoading').hide();

                    var items = [];
                    if (data.response && data.response.body && data.response.body.items) {
                        items = data.response.body.items.item;
                    }

                    if (!items || items.length === 0) {
                        $('#erResultList').html('<div style="padding:10px; text-align:center;">검색 결과가 없습니다.</div>');
                        return;
                    }

                    if (!Array.isArray(items)) {
                        items = [items];
                    }

                    var listHtml = '';
                    items.forEach(function(item) {
                        var dutyName = item.dutyName;
                        var hvec = parseInt(item.hvec);
                        var dutyTel3 = item.dutyTel3 || '전화번호 없음';

                        var badgeClass = 'bg-green';
                        var statusText = '여유';

                        if (hvec <= 0) {
                            badgeClass = 'bg-red';
                            statusText = '만실';
                        } else if (hvec < 3) {
                            badgeClass = 'bg-yellow';
                            statusText = '혼잡';
                        }

                        var safeName = dutyName.replace(/'/g, "\\'");

                        listHtml += '<div class="er-item" onclick="hospitalMap.searchByKeyword(\'' + safeName + '\')">';
                        listHtml += '  <div>';
                        listHtml += '    <div class="er-name">' + dutyName + '</div>';
                        listHtml += '    <div style="font-size:12px; color:#666;">📞 ' + dutyTel3 + '</div>';
                        listHtml += '  </div>';
                        listHtml += '  <div style="text-align:right;">';
                        listHtml += '    <div class="er-status">응급병상: <strong>' + hvec + '</strong></div>';
                        listHtml += '    <span class="er-badge ' + badgeClass + '">' + statusText + '</span>';
                        listHtml += '  </div>';
                        listHtml += '</div>';
                    });

                    $('#erResultList').html(listHtml);
                },
                error: function(e) {
                    $('#erLoading').hide();
                    console.error('API Error:', e);
                    alert("실시간 정보를 불러오는데 실패했습니다.");
                }
            });
        }


    };






    // ==========================================
    // 기존 지도 및 채팅 로직 (유지 및 미세 조정)
    // ==========================================
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
            this.currentLocationMarker = new kakao.maps.Marker({ title: '현재 위치', zIndex: 100 });
            this.makeMap();
            this.setupEventListeners();
        },

        makeMap: function() {
            var mapContainer = document.getElementById('map1');
            var mapOption = { center: new kakao.maps.LatLng(37.5665, 126.9780), level: 6 };
            this.map = new kakao.maps.Map(mapContainer, mapOption);
            this.map.addControl(new kakao.maps.MapTypeControl(), kakao.maps.ControlPosition.TOPRIGHT);
            this.map.addControl(new kakao.maps.ZoomControl(), kakao.maps.ControlPosition.RIGHT);
            this.places = new kakao.maps.services.Places();
            this.getCurrentLocation(true);
        },

        setupEventListeners: function() {
            var self = this;
            document.getElementById('btn-my-location').addEventListener('click', function() { self.getCurrentLocation(true); });
            document.getElementById('btn-find-nearby').addEventListener('click', function() { self.searchNearbyHospitals(); });
            document.getElementById('btn-emergency').addEventListener('click', function() { self.searchEmergencyHospitals(); });
            document.getElementById('btn-refresh').addEventListener('click', function() { self.refreshMap(); });
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
                    if(panTo) { self.map.setLevel(5); self.map.panTo(self.currentPosition); }
                }, function(error) {
                    console.error('위치 정보 오류:', error);
                    // 기본값: 서울시청
                    self.currentPosition = new kakao.maps.LatLng(37.5665, 126.9780);
                    self.currentLocationMarker.setPosition(self.currentPosition);
                    self.currentLocationMarker.setMap(self.map);
                    if(panTo) self.map.panTo(self.currentPosition);
                });
            }
        },

        searchNearbyHospitals: function() {
            if (!this.currentPosition) { alert('현재 위치를 확인 중입니다.'); return; }
            var self = this;
            this.clearHospitalMarkers();
            var options = { location: this.currentPosition, radius: 5000, sort: kakao.maps.services.SortBy.DISTANCE };
            this.places.categorySearch('HP8', function(result, status) {
                if (status === kakao.maps.services.Status.OK) {
                    self.searchedHospitals = result;
                    self.displaySearchResults(result, '주변 병원');
                    for(var i = 0; i < result.length; i++) self.createPlaceMarker(result[i], i);
                } else { alert('주변 병원 검색 결과가 없습니다.'); }
            }, options);
        },

        searchEmergencyHospitals: function() {
            if (!this.currentPosition) return;
            var self = this;
            this.clearHospitalMarkers();
            var options = { location: this.currentPosition, radius: 10000, sort: kakao.maps.services.SortBy.DISTANCE };
            this.places.keywordSearch('응급실', function(result, status) {
                if (status === kakao.maps.services.Status.OK && result.length > 0) {
                    self.searchedHospitals = result;
                    self.displaySearchResults(result, '응급실 운영 병원');
                    for(var i = 0; i < result.length; i++) self.createPlaceMarker(result[i], i);
                } else {
                    self.places.keywordSearch('종합병원', function(result2, status2) {
                        if (status2 === kakao.maps.services.Status.OK && result2.length > 0) {
                            self.searchedHospitals = result2;
                            self.displaySearchResults(result2, '종합병원 (응급실 확인 필요)');
                            for(var i = 0; i < result2.length; i++) self.createPlaceMarker(result2[i], i);
                        } else { alert('주변 응급실을 찾을 수 없습니다.'); }
                    }, options);
                }
            }, options);
        },

        searchByKeyword: function(keyword) {
            var self = this;
            this.clearHospitalMarkers();

            // 1. 응급실 실시간 리스트에서 클릭해서 들어온 경우 -> 전국 검색을 위해 location 해제 고려
            var options = {};
            if (keyword.includes('가까운') || keyword.includes('근처')) {
                options.location = this.currentPosition;
                options.radius = 10000;
                options.sort = kakao.maps.services.SortBy.DISTANCE;
            }
            // 실시간 조회에서 병원명만 넘어온 경우, 특정 위치 기반이 아닐 수 있음

            var cleanKeyword = keyword.replace(/가까운|근처|주변/g, '').trim();

            this.places.keywordSearch(cleanKeyword, function(result, status) {
                if (status === kakao.maps.services.Status.OK) {
                    self.searchedHospitals = result;
                    if (result.length > 0) {
                        self.displaySearchResults(result, cleanKeyword + ' 검색 결과');
                        for(var i = 0; i < result.length; i++) self.createPlaceMarker(result[i], i);

                        // 첫 번째 결과로 이동
                        var first = result[0];
                        self.map.panTo(new kakao.maps.LatLng(first.y, first.x));

                        // 하나만 딱 검색된 경우 오버레이 바로 표시
                        if (result.length === 1 || keyword.length > 5) {
                            self.focusPlace(0);
                        }
                    } else {
                        chatHandler.addMessage('죄송합니다. ' + cleanKeyword + ' 병원을 찾을 수 없습니다.', 'ai');
                    }
                }
            }, options);
        },

        createPlaceMarker: function(place, index) {
            var self = this;
            var markerImage = new kakao.maps.MarkerImage(
                'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png',
                new kakao.maps.Size(48, 52), {offset: new kakao.maps.Point(24, 52)}
            );
            var marker = new kakao.maps.Marker({
                position: new kakao.maps.LatLng(place.y, place.x),
                image: markerImage,
                title: place.place_name
            });

            var distance = this.currentPosition ? Math.round(this.getDistance(this.currentPosition, new kakao.maps.LatLng(place.y, place.x))) : 0;
            var escapedName = place.place_name.replace(/'/g, "\\'");

            var content = '<div style="position:absolute;left:-150px;bottom:50px;width:300px;">' +
                '<div style="border:2px solid #28a745;border-radius:8px;background:#fff;box-shadow:0 2px 8px rgba(0,0,0,0.2);">' +
                '<div style="height:36px;background:#28a745;padding:8px 12px;color:#fff;font-size:14px;font-weight:bold;display:flex;align-items:center;justify-content:space-between;border-radius:6px 6px 0 0;">' +
                '<span> ' + place.place_name + '</span>' +
                '<div onclick="hospitalMap.closeOverlay(' + index + ')" style="color:#fff;width:18px;height:18px;cursor:pointer;">✕</div>' +
                '</div>' +
                '<div style="padding:12px;">' +
                '<div style="margin-bottom:10px;"><span style="display:inline-block;padding:4px 10px;background:#28a745;color:white;border-radius:12px;font-size:10px;">' + (place.category_name.split('>').pop().trim()) + '</span></div>' +
                '<div style="margin:8px 0;"><strong> 주소:</strong><br/>' + (place.road_address_name || place.address_name) + '</div>' +
                (place.phone ? '<div style="margin:8px 0;"><strong> 전화:</strong> ' + place.phone + '</div>' : '') +
                (distance > 0 ? '<div style="margin:8px 0;"><strong> 거리:</strong> ' + (distance/1000).toFixed(1) + 'km</div>' : '') +
                '<div style="text-align:center;margin-top:12px;">' +
                '<button onclick="window.open(\'' + place.place_url + '\')" style="padding:8px 16px;background:#28a745;color:#fff;border:none;border-radius:4px;cursor:pointer;margin-right:5px;font-size:12px;">상세정보</button>' +
                '<button onclick="hospitalMap.findRoute(' + place.y + ',' + place.x + ',\'' + escapedName + '\')" style="padding:8px 16px;background:#007bff;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:12px;">길찾기</button>' +
                '</div></div></div></div>';

            var customOverlay = new kakao.maps.CustomOverlay({
                content: content, position: marker.getPosition(), xAnchor: 0.5, yAnchor: 1.1, zIndex: 3
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
                var distanceStr = '';
                if (this.currentPosition) {
                    var dist = this.getDistance(this.currentPosition, new kakao.maps.LatLng(place.y, place.x));
                    distanceStr = '<div class="detail-info"><span class="distance-info">거리: ' + (dist/1000).toFixed(1) + 'km</span></div>';
                }
                infoHTML += '<div class="hospital-detail" onclick="hospitalMap.focusPlace(' + i + ')">' +
                    '<div class="detail-title">' + (i + 1) + '. ' + place.place_name + '</div>' +
                    '<div class="detail-info">' + (place.road_address_name || place.address_name) + '</div>' +
                    (place.phone ? '<div class="detail-info"> ' + place.phone + '</div>' : '') +
                    distanceStr + '</div>';
            }
            document.querySelector('#hospitalInfo .info-content').innerHTML = infoHTML;
            document.getElementById('hospitalInfo').className = 'active';
        },

        focusPlace: function(index) {
            if (index < this.searchedHospitals.length) {
                var place = this.searchedHospitals[index];
                var position = new kakao.maps.LatLng(place.y, place.x);
                this.map.panTo(position);
                if (index < this.hospitalOverlays.length) {
                    this.closeAllOverlays();
                    this.hospitalOverlays[index].setMap(this.map);
                    this.activeOverlay = this.hospitalOverlays[index];
                }
            }
        },

        findRoute: function(lat, lng, name) {
            if (!this.currentPosition) { alert('현재 위치 정보가 없습니다.'); return; }
            var destination = new kakao.maps.LatLng(lat, lng);
            var kakaoMapUrl = 'https://map.kakao.com/link/to/' + encodeURIComponent(name) + ',' + lat + ',' + lng +
                '/from/현재위치,' + this.currentPosition.getLat() + ',' + this.currentPosition.getLng();
            window.open(kakaoMapUrl, '_blank');
        },

        getDistance: function(pos1, pos2) {
            var R = 6371000;
            var dLat = (pos2.getLat() - pos1.getLat()) * Math.PI / 180;
            var dLng = (pos2.getLng() - pos1.getLng()) * Math.PI / 180;
            var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.cos(pos1.getLat() * Math.PI / 180) * Math.cos(pos2.getLat() * Math.PI / 180) * Math.sin(dLng/2) * Math.sin(dLng/2);
            var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
            return R * c;
        },

        clearHospitalMarkers: function() {
            for(var i = 0; i < this.hospitalMarkers.length; i++) this.hospitalMarkers[i].setMap(null);
            this.hospitalMarkers = [];
            this.closeAllOverlays();
            this.hospitalOverlays = [];
        },

        closeAllOverlays: function() {
            for(var i = 0; i < this.hospitalOverlays.length; i++) this.hospitalOverlays[i].setMap(null);
            this.activeOverlay = null;
        },

        closeOverlay: function(index) {
            if (this.hospitalOverlays[index]) this.hospitalOverlays[index].setMap(null);
        },

        refreshMap: function() {
            this.clearHospitalMarkers();
            this.searchedHospitals = [];
            document.getElementById('hospitalInfo').className = '';
            if (this.currentPosition) {
                this.map.setLevel(5);
                this.map.panTo(this.currentPosition);
            }
        }
    };

    var chatHandler = {
        lastMedicalKeyword: null,

        init: function() {
            var self = this;
            $('#chatSendBtn').click(function() { self.sendMessage(); });
            $('#chatInput').keypress(function(e) { if (e.key === 'Enter') self.sendMessage(); });
        },

        sendMessage: function() {
            var input = $('#chatInput');
            var message = input.val().trim();
            if (!message) return;
            this.addMessage(message, 'user');
            input.val('');
            this.processMessage(message);
        },

        processMessage: function(message) {
            var self = this;
            $.ajax({
                url: '/map/chat',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ message: message, language: currentLang }),
                success: function(response) {
                    if (response.answer) self.addMessage(response.answer, 'ai');

                    var keyword = response.keyword;
                    var action = response.action;

                    // 응급실 액션이면 실시간 맵 검색
                    if (action === 'EMERGENCY') {
                        hospitalMap.searchEmergencyHospitals();
                        return;
                    }

                    // 일반 검색
                    if (keyword) {
                        // 지역명 결합 로직 등 기존 로직 유지
                        var userRegion = self.detectRegion(message);
                        if (userRegion && !keyword.includes(userRegion)) keyword = userRegion + " " + keyword;
                        else if (!keyword.match(/가까운|근처|주변/)) keyword = "가까운 " + keyword;

                        hospitalMap.searchByKeyword(keyword);
                    }
                },
                error: function() {
                    self.addMessage("오류가 발생했습니다.", 'ai');
                }
            });
        },

        detectRegion: function(msg) {
            var regions = ['서울', '부산', '대구', '인천', '광주', '대전', '울산', '경기', '강원', '강남', '서초', '송파', '분당', '수원'];
            for (var i = 0; i < regions.length; i++) {
                if (msg.includes(regions[i])) return regions[i];
            }
            return null;
        },

        addMessage: function(text, sender) {
            var html = '<div class="chat-message ' + sender + '"><div class="message-bubble">' + text.replace(/\n/g, '<br>') + '</div></div>';
            $('#chatMessages').append(html);
            $('#chatMessages').scrollTop($('#chatMessages')[0].scrollHeight);
        }
    };

    document.addEventListener('DOMContentLoaded', function() {
        kakao.maps.load(function() {
            hospitalMap.init();
            chatHandler.init();
            // 🆕 실시간 응급실 핸들러 초기화
            erHandler.init();
        });
    });
</script>

<footer id="contact">
    <div class="footer-content">
        <div class="footer-info">
            <h3>AI 기반 의료 매칭 시스템</h3>
            <p>이메일: contact@medical-ai.kr</p>
        </div>
        <div class="footer-contact">
            <h3>전문 의료상담</h3>
            <div class="contact-number">1234-5678</div>
        </div>
    </div>
    <div class="footer-bottom">
        <p>Copyright © 2025 AI 의료 매칭 시스템. All Rights Reserved.</p>
    </div>
</footer>
</body>
</html>