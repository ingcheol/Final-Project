<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>병원 찾기 - AI 의료 매칭 시스템</title>
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

    <div class="control-panel">
        <div class="control-buttons">
            <button id="btn-my-location" class="btn btn-primary">📍 현재 위치</button>
            <button id="btn-find-nearby" class="btn btn-success">🏥 가까운 병원</button>
            <button id="btn-emergency" class="btn btn-danger">🚨 응급실</button>
            <button id="btn-refresh" class="btn btn-secondary">🔄 새로고침</button>
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
                🤖 AI 의료 상담
            </div>
            <div class="chat-messages" id="chatMessages">
                <div class="chat-message ai">
                    <div class="message-bubble">
                        안녕하세요! AI 의료 상담 챗봇입니다. 궁금하신 점을 물어보세요.
                    </div>
                </div>
            </div>
            <div class="chat-input-area">
                <input type="text" class="chat-input" id="chatInput" placeholder="메시지를 입력하세요...">
                <button class="chat-send-btn" id="chatSendBtn">전송</button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=f37b6c5eb063be1a82888e664e204d6d&libraries=services,drawing,clusterer"></script>
<script>
    let hospitalMap = {
        map: null,
        currentLocationMarker: null,
        hospitalMarkers: [],
        hospitalOverlays: [],
        activeOverlay: null,
        polylines: [],
        currentPosition: null,

        hospitals: [
            {
                name: '서울대학교병원',
                type: '종합병원',
                lat: 37.5796,
                lng: 126.9990,
                tel: '02-2072-2114',
                address: '서울특별시 종로구 대학로 103',
                departments: ['내과', '외과', '정형외과', '신경외과', '소아청소년과'],
                emergencyRoom: true,
                nightCare: true
            },
            {
                name: '삼성서울병원',
                type: '종합병원',
                lat: 37.4886,
                lng: 127.0857,
                tel: '02-3410-2114',
                address: '서울특별시 강남구 일원로 81',
                departments: ['내과', '외과', '정형외과', '안과', '이비인후과'],
                emergencyRoom: true,
                nightCare: true
            },
            {
                name: '세브란스병원',
                type: '종합병원',
                lat: 37.5626,
                lng: 126.9411,
                tel: '02-2228-5800',
                address: '서울특별시 서대문구 연세로 50-1',
                departments: ['내과', '외과', '산부인과', '소아청소년과', '정신건강의학과'],
                emergencyRoom: true,
                nightCare: true
            },
            {
                name: '서울아산병원',
                type: '종합병원',
                lat: 37.5265,
                lng: 127.1086,
                tel: '02-3010-3114',
                address: '서울특별시 송파구 올림픽로 43길 88',
                departments: ['내과', '외과', '정형외과', '신경과', '피부과'],
                emergencyRoom: true,
                nightCare: true
            },
            {
                name: '강남세브란스병원',
                type: '종합병원',
                lat: 37.5066,
                lng: 127.0627,
                tel: '02-2019-3000',
                address: '서울특별시 강남구 언주로 211',
                departments: ['내과', '외과', '신경외과', '정형외과', '안과'],
                emergencyRoom: true,
                nightCare: true
            },
            {
                name: '서울시립보라매병원',
                type: '종합병원',
                lat: 37.4920,
                lng: 126.9247,
                tel: '02-870-2114',
                address: '서울특별시 동작구 보라매로5길 20',
                departments: ['내과', '외과', '가정의학과', '재활의학과'],
                emergencyRoom: true,
                nightCare: true
            }
        ],

        init: function () {
            const currentMarkerImageSrc = 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_blue.png';
            const currentImageSize = new kakao.maps.Size(64, 69);
            const currentImageOption = {offset: new kakao.maps.Point(27, 69)};
            const currentMarkerImage = new kakao.maps.MarkerImage(currentMarkerImageSrc, currentImageSize, currentImageOption);
            this.currentLocationMarker = new kakao.maps.Marker({
                image: currentMarkerImage,
                title: '현재 위치'
            });

            this.makeMap();

            $('#btn-my-location').click(() => this.getCurrentLocation(true));
            $('#btn-find-nearby').click(() => this.findNearbyHospitals());
            $('#btn-emergency').click(() => this.findEmergencyHospitals());
            $('#btn-refresh').click(() => this.refreshMap());
        },

        makeMap: function () {
            const mapContainer = document.getElementById('map1');
            const mapOption = {
                center: new kakao.maps.LatLng(37.5665, 126.9780),
                level: 6
            };
            this.map = new kakao.maps.Map(mapContainer, mapOption);
            this.map.addControl(new kakao.maps.MapTypeControl(), kakao.maps.ControlPosition.TOPRIGHT);
            this.map.addControl(new kakao.maps.ZoomControl(), kakao.maps.ControlPosition.RIGHT);

            this.getCurrentLocation(true);
            this.displayAllHospitals();
        },

        getCurrentLocation: function(panTo = false) {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition((position) => {
                    const lat = position.coords.latitude;
                    const lng = position.coords.longitude;
                    this.currentPosition = new kakao.maps.LatLng(lat, lng);
                    this.currentLocationMarker.setPosition(this.currentPosition);
                    this.currentLocationMarker.setMap(this.map);

                    if(panTo) {
                        this.map.setLevel(5);
                        this.map.panTo(this.currentPosition);
                    }
                }, (error) => {
                    console.error('위치 정보 오류:', error);
                    this.currentPosition = new kakao.maps.LatLng(37.5665, 126.9780);
                    this.currentLocationMarker.setPosition(this.currentPosition);
                    this.currentLocationMarker.setMap(this.map);
                    if(panTo) this.map.panTo(this.currentPosition);
                });
            }
        },

        displayAllHospitals: function() {
            this.hospitals.forEach((hospital, index) => {
                this.createHospitalMarker(hospital, index);
            });
        },

        createHospitalMarker: function(hospital, index) {
            const markerImage = new kakao.maps.MarkerImage(
                'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png',
                new kakao.maps.Size(48, 52),
                {offset: new kakao.maps.Point(24, 52)}
            );

            const marker = new kakao.maps.Marker({
                position: new kakao.maps.LatLng(hospital.lat, hospital.lng),
                image: markerImage,
                title: hospital.name
            });

            const content = '<div style="position:absolute;left:-150px;bottom:50px;width:300px;">' +
                '<div style="border:2px solid #28a745;border-radius:8px;background:#fff;box-shadow:0 2px 8px rgba(0,0,0,0.2);">' +
                '<div style="height:36px;background:#28a745;padding:8px 12px;color:#fff;font-size:14px;font-weight:bold;display:flex;align-items:center;justify-content:space-between;border-radius:6px 6px 0 0;">' +
                '<span>🏥 ' + hospital.name + '</span>' +
                '<div onclick="hospitalMap.closeOverlay(' + index + ')" style="color:#fff;width:18px;height:18px;cursor:pointer;">✕</div>' +
                '</div>' +
                '<div style="padding:12px;">' +
                '<div style="margin-bottom:10px;"><span style="display:inline-block;padding:4px 10px;background:#28a745;color:white;border-radius:12px;font-size:10px;">' + hospital.type + '</span></div>' +
                '<div style="margin:8px 0;"><strong>📍 주소:</strong><br/>' + hospital.address + '</div>' +
                '<div style="margin:8px 0;"><strong>📞 전화:</strong> ' + hospital.tel + '</div>' +
                '<div style="text-align:center;margin-top:12px;">' +
                '<button onclick="hospitalMap.showHospitalDetail(' + index + ')" style="padding:8px 16px;background:#28a745;color:#fff;border:none;border-radius:4px;cursor:pointer;margin-right:5px;">상세보기</button>' +
                '<button onclick="hospitalMap.findRoute(' + hospital.lat + ',' + hospital.lng + ',\'' + hospital.name + '\')" style="padding:8px 16px;background:#007bff;color:#fff;border:none;border-radius:4px;cursor:pointer;">길찾기</button>' +
                '</div></div></div></div>';

            const customOverlay = new kakao.maps.CustomOverlay({
                content: content,
                position: marker.getPosition(),
                xAnchor: 0.5,
                yAnchor: 1.1,
                zIndex: 3
            });

            kakao.maps.event.addListener(marker, 'click', () => {
                this.closeAllOverlays();
                customOverlay.setMap(this.map);
                this.activeOverlay = customOverlay;
                this.map.panTo(marker.getPosition());
            });

            marker.setMap(this.map);
            this.hospitalMarkers.push(marker);
            this.hospitalOverlays.push(customOverlay);
        },

        showHospitalDetail: function(index) {
            const hospital = this.hospitals[index];
            let distance = '';

            if (this.currentPosition) {
                const hospitalPos = new kakao.maps.LatLng(hospital.lat, hospital.lng);
                const dist = this.getDistance(this.currentPosition, hospitalPos);
                distance = '<div class="detail-info"><span class="distance-info">약 ' + (dist/1000).toFixed(1) + 'km</span></div>';
            }

            const detailHTML = '<div class="hospital-detail">' +
                '<div class="detail-title">📋 ' + hospital.name + '</div>' +
                '<div class="detail-info"><strong>유형:</strong> ' + hospital.type + '</div>' +
                '<div class="detail-info"><strong>주소:</strong> ' + hospital.address + '</div>' +
                '<div class="detail-info"><strong>전화:</strong> ' + hospital.tel + '</div>' +
                distance +
                '<div class="detail-info"><strong>진료과:</strong> ' + hospital.departments.join(', ') + '</div>' +
                '</div>';

            document.querySelector('#hospitalInfo .info-content').innerHTML = detailHTML;
            document.getElementById('hospitalInfo').className = 'active';
            this.map.panTo(new kakao.maps.LatLng(hospital.lat, hospital.lng));
        },

        findNearbyHospitals: function() {
            if (!this.currentPosition) {
                alert('현재 위치를 먼저 확인해주세요.');
                return;
            }

            const hospitalsWithDistance = this.hospitals.map(hospital => {
                const hospitalPos = new kakao.maps.LatLng(hospital.lat, hospital.lng);
                const distance = this.getDistance(this.currentPosition, hospitalPos);
                return { ...hospital, distance: distance };
            }).sort((a, b) => a.distance - b.distance);

            let infoHTML = '';
            hospitalsWithDistance.slice(0, 5).forEach((hospital, idx) => {
                const originalIndex = this.hospitals.findIndex(h => h.name === hospital.name);
                infoHTML += '<div class="hospital-detail" onclick="hospitalMap.focusHospital(' + originalIndex + ')">' +
                    '<div class="detail-title">' + (idx + 1) + '. ' + hospital.name + '</div>' +
                    '<div class="detail-info">' + hospital.address + '</div>' +
                    '<div class="detail-info"><span class="distance-info">거리: ' + (hospital.distance/1000).toFixed(1) + 'km</span></div>' +
                    '</div>';
            });

            document.querySelector('#hospitalInfo .info-content').innerHTML = infoHTML;
            document.getElementById('hospitalInfo').className = 'active';
        },

        findEmergencyHospitals: function() {
            const emergencyHospitals = this.hospitals.filter(h => h.emergencyRoom);
            let infoHTML = '';

            emergencyHospitals.forEach((hospital, idx) => {
                const originalIndex = this.hospitals.indexOf(hospital);
                const distance = this.currentPosition ?
                    this.getDistance(this.currentPosition, new kakao.maps.LatLng(hospital.lat, hospital.lng)) : 0;

                infoHTML += '<div class="hospital-detail" onclick="hospitalMap.focusHospital(' + originalIndex + ')">' +
                    '<div class="detail-title">' + (idx + 1) + '. ' + hospital.name + '</div>' +
                    '<div class="detail-info">' + hospital.address + '</div>' +
                    '<div class="detail-info">📞 ' + hospital.tel + '</div>' +
                    (this.currentPosition ? '<div class="detail-info"><span class="distance-info">거리: ' + (distance/1000).toFixed(1) + 'km</span></div>' : '') +
                    '</div>';
            });

            document.querySelector('#hospitalInfo .info-content').innerHTML = infoHTML;
            document.getElementById('hospitalInfo').className = 'active';
        },

        focusHospital: function(index) {
            const hospital = this.hospitals[index];
            this.map.setLevel(4);
            this.map.panTo(new kakao.maps.LatLng(hospital.lat, hospital.lng));
            this.closeAllOverlays();
            this.hospitalOverlays[index].setMap(this.map);
            this.activeOverlay = this.hospitalOverlays[index];
        },

        findRoute: function(lat, lng, name) {
            if (!this.currentPosition) {
                alert('현재 위치가 설정되지 않았습니다.');
                return;
            }

            this.polylines.forEach(line => line.setMap(null));
            this.polylines = [];

            const destination = new kakao.maps.LatLng(lat, lng);
            const distance = this.getDistance(this.currentPosition, destination);

            const polyline = new kakao.maps.Polyline({
                path: [this.currentPosition, destination],
                strokeWeight: 5,
                strokeColor: '#FF0000',
                strokeOpacity: 0.7,
                strokeStyle: 'solid'
            });

            polyline.setMap(this.map);
            this.polylines.push(polyline);

            const bounds = new kakao.maps.LatLngBounds();
            bounds.extend(this.currentPosition);
            bounds.extend(destination);
            this.map.setBounds(bounds);

            const distanceKm = (distance / 1000).toFixed(1);
            const estimatedTime = Math.round(distance / 600);

            alert('🏥 ' + name + '까지\n📏 직선거리: ' + distanceKm + 'km\n⏱️ 예상 소요시간: 약 ' + estimatedTime + '분');
        },

        getDistance: function(pos1, pos2) {
            const R = 6371000;
            const lat1 = pos1.getLat() * Math.PI / 180;
            const lat2 = pos2.getLat() * Math.PI / 180;
            const deltaLat = (pos2.getLat() - pos1.getLat()) * Math.PI / 180;
            const deltaLng = (pos2.getLng() - pos1.getLng()) * Math.PI / 180;

            const a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) +
                Math.cos(lat1) * Math.cos(lat2) *
                Math.sin(deltaLng/2) * Math.sin(deltaLng/2);
            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
            return R * c;
        },

        closeAllOverlays: function() {
            this.hospitalOverlays.forEach(overlay => overlay.setMap(null));
            this.activeOverlay = null;
        },

        closeOverlay: function(index) {
            if (this.hospitalOverlays[index]) {
                this.hospitalOverlays[index].setMap(null);
            }
        },

        refreshMap: function() {
            this.closeAllOverlays();
            this.polylines.forEach(line => line.setMap(null));
            this.polylines = [];
            document.getElementById('hospitalInfo').className = '';
            if (this.currentPosition) {
                this.map.setLevel(5);
                this.map.panTo(this.currentPosition);
            }
        }
    };

    $(function () {
        hospitalMap.init();
    });
</script>
</body>
</html>