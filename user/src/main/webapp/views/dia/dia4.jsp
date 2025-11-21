<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>진단 결과 - AI 의료 매칭 시스템</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700&display=swap" rel="stylesheet">

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
            color: #333;
            background: linear-gradient(135deg, #f5f7fa 0%, #e8f0fe 100%);
            min-height: 100vh;
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

        .main-container {
            margin-top: 100px;
            padding: 40px 30px;
            max-width: 1200px;
            margin-left: auto;
            margin-right: auto;
        }

        .progress-bar {
            display: flex;
            justify-content: space-between;
            margin-bottom: 50px;
            position: relative;
        }

        .progress-bar::before {
            content: '';
            position: absolute;
            top: 20px;
            left: 0;
            right: 0;
            height: 3px;
            background: #28a745;
            z-index: 0;
        }

        .progress-step {
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
            z-index: 1;
            flex: 1;
        }

        .progress-step .circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #28a745;
            color: white;
            border: 3px solid #28a745;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .progress-step span {
            font-size: 13px;
            color: #28a745;
            font-weight: 600;
        }

        .success-badge {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            padding: 15px 30px;
            border-radius: 50px;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(40, 167, 69, 0.3);
        }

        .result-card {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 4px 30px rgba(0,0,0,0.1);
            margin-bottom: 25px;
        }

        .card-header {
            border-bottom: 3px solid #f0f0f0;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }

        .card-header h2 {
            font-size: 28px;
            color: #2c3e50;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .card-header p {
            color: #7f8c8d;
            font-size: 15px;
        }

        .analysis-section {
            margin-bottom: 30px;
        }

        .analysis-title {
            font-size: 20px;
            color: #5B6FB5;
            font-weight: 600;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .analysis-content {
            background: #f8f9ff;
            padding: 30px;
            border-radius: 12px;
            border-left: 4px solid #5B6FB5;
            line-height: 1.8;
            color: #333;
            font-size: 16px;
            white-space: pre-line;
        }

        .recommendation-box {
            background: linear-gradient(135deg, #FFF3E0 0%, #FFE0B2 100%);
            border: 2px solid #FFB74D;
            border-radius: 15px;
            padding: 30px;
            margin: 30px 0;
        }

        .recommendation-box h3 {
            color: #E65100;
            font-size: 20px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .recommendation-item {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .recommendation-item:last-child {
            margin-bottom: 0;
        }

        .rec-icon {
            font-size: 32px;
            min-width: 50px;
            text-align: center;
        }

        .rec-content {
            flex: 1;
        }

        .rec-title {
            font-weight: 600;
            color: #333;
            font-size: 16px;
            margin-bottom: 5px;
        }

        .rec-desc {
            color: #666;
            font-size: 14px;
        }

        .hospital-section {
            margin-top: 30px;
        }

        .hospital-card {
            background: white;
            border: 2px solid #e0e0e0;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 15px;
            transition: all 0.3s;
            cursor: pointer;
        }

        .hospital-card:hover {
            border-color: #5B6FB5;
            box-shadow: 0 4px 15px rgba(91, 111, 181, 0.2);
            transform: translateY(-2px);
        }

        .hospital-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .hospital-name {
            font-size: 20px;
            font-weight: 600;
            color: #2c3e50;
        }

        .hospital-badge {
            background: #5B6FB5;
            color: white;
            padding: 6px 15px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }

        .hospital-info {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
            margin-top: 15px;
        }

        .info-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            color: #666;
        }

        .warning-box {
            background: #FFF3CD;
            border: 2px solid #FFC107;
            border-radius: 12px;
            padding: 20px;
            margin: 30px 0;
        }

        .warning-box h4 {
            color: #856404;
            font-size: 16px;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .warning-box p {
            color: #856404;
            font-size: 14px;
            line-height: 1.6;
        }

        .action-buttons {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-top: 40px;
        }

        .btn {
            padding: 16px 24px;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            text-align: center;
        }

        .btn-primary {
            background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(91, 111, 181, 0.4);
        }

        .btn-secondary {
            background: white;
            color: #666;
            border: 2px solid #e0e0e0;
        }

        .btn-secondary:hover {
            border-color: #5B6FB5;
            color: #5B6FB5;
        }

        .btn-success {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
        }

        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(40, 167, 69, 0.4);
        }

        @media (max-width: 768px) {
            .main-container {
                padding: 20px 15px;
            }

            .result-card {
                padding: 25px 20px;
            }

            .action-buttons {
                grid-template-columns: 1fr;
            }

            .hospital-info {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<header>
    <nav>
        <a href="<c:url value="/"/>" class="logo">🏥 AI 의료 매칭 시스템</a>
    </nav>
</header>

<div class="main-container">
    <!-- Progress Bar -->
    <div class="progress-bar">
        <div class="progress-step">
            <div class="circle">✓</div>
            <span>증상 입력</span>
        </div>
        <div class="progress-step">
            <div class="circle">✓</div>
            <span>설문조사</span>
        </div>
        <div class="progress-step">
            <div class="circle">✓</div>
            <span>AI 분석</span>
        </div>
        <div class="progress-step">
            <div class="circle">✓</div>
            <span>결과 확인</span>
        </div>
    </div>

    <!-- Success Badge -->
    <div style="text-align: center;">
        <div class="success-badge">
            ✅ 분석이 완료되었습니다!
        </div>
    </div>

    <!-- AI 분석 결과 -->
    <div class="result-card">
        <div class="card-header">
            <h2>🔬 AI 분석 결과</h2>
            <p>입력하신 증상을 바탕으로 분석한 결과입니다</p>
        </div>

        <div class="analysis-section">
            <div class="analysis-title">
                📋 입력하신 증상
            </div>
            <div class="analysis-content">
                ${symptomText}
            </div>
        </div>

        <div class="analysis-section">
            <div class="analysis-title">
                🧠 AI 진단 분석
            </div>
            <div class="analysis-content">
                ${aiDiagnosis}
            </div>
        </div>
    </div>

    <!-- 추천 사항 -->
    <div class="recommendation-box">
        <h3>💡 추천 사항</h3>

        <div class="recommendation-item">
            <div class="rec-icon">🏥</div>
            <div class="rec-content">
                <div class="rec-title">추천 진료과: ${recommendedDepartment}</div>
                <div class="rec-desc">증상에 적합한 진료과를 안내해드립니다</div>
            </div>
        </div>

        <div class="recommendation-item">
            <div class="rec-icon">⏰</div>
            <div class="rec-content">
                <div class="rec-title">진료 시급성: ${urgency}</div>
                <div class="rec-desc">증상의 심각도에 따른 권장 방문 시기입니다</div>
            </div>
        </div>

        <div class="recommendation-item">
            <div class="rec-icon">💊</div>
            <div class="rec-content">
                <div class="rec-title">자가 관리</div>
                <div class="rec-desc">충분한 휴식, 수분 섭취, 해열제 복용을 권장합니다</div>
            </div>
        </div>
    </div>

    <!-- 근처 병원 추천 -->
    <div class="result-card">
        <div class="card-header">
            <h2>🏥 추천 병원</h2>
            <p>증상에 맞는 근처 병원을 추천해드립니다</p>
        </div>

        <!-- 병원 등급 안내 -->
        <div style="background: #f8f9ff; padding: 20px; border-radius: 12px; margin-bottom: 30px; border: 2px solid #e3f2fd;">
            <h3 style="font-size: 18px; color: #5B6FB5; margin-bottom: 15px; text-align: center;">💡 병원 등급 안내</h3>
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px;">
                <div style="text-align: center; padding: 15px; background: white; border-radius: 8px; border: 1px solid #e0e0e0;">
                    <div style="font-size: 24px; margin-bottom: 5px;">🏥</div>
                    <div style="font-weight: 600; color: #2c3e50; margin-bottom: 5px;">1차 의료기관</div>
                    <div style="font-size: 12px; color: #666; line-height: 1.5;">의원, 보건소<br>감기 등 경증 질환</div>
                </div>
                <div style="text-align: center; padding: 15px; background: white; border-radius: 8px; border: 1px solid #e0e0e0;">
                    <div style="font-size: 24px; margin-bottom: 5px;">🏥</div>
                    <div style="font-weight: 600; color: #2c3e50; margin-bottom: 5px;">2차 의료기관</div>
                    <div style="font-size: 12px; color: #666; line-height: 1.5;">병원, 종합병원<br>입원, 수술 필요시</div>
                </div>
                <div style="text-align: center; padding: 15px; background: white; border-radius: 8px; border: 1px solid #e0e0e0;">
                    <div style="font-size: 24px; margin-bottom: 5px;">🏥</div>
                    <div style="font-weight: 600; color: #2c3e50; margin-bottom: 5px;">3차 의료기관</div>
                    <div style="font-size: 12px; color: #666; line-height: 1.5;">대학병원<br>중증, 희귀 질환</div>
                </div>
            </div>
        </div>

        <div class="hospital-section">
            <!-- 1차 병원: 의원 -->
            <h3 id="hospitals1st-title" style="font-size: 20px; color: #2c3e50; margin-bottom: 15px; display: none; align-items: center; gap: 10px; margin-top: 30px;">
                <span style="background: #E3F2FD; color: #1976D2; padding: 5px 15px; border-radius: 20px; font-size: 14px; font-weight: 600;">1차 병원</span>
                가까운 의원 · 클리닉
            </h3>
            <div id="hospitals1st-list"></div>

            <!-- 2차 병원: 종합병원 -->
            <h3 id="hospitals2nd-title" style="font-size: 20px; color: #2c3e50; margin-bottom: 15px; display: none; align-items: center; gap: 10px; margin-top: 30px;">
                <span style="background: #FFF3E0; color: #F57C00; padding: 5px 15px; border-radius: 20px; font-size: 14px; font-weight: 600;">2차 병원</span>
                종합병원
            </h3>
            <div id="hospitals2nd-list"></div>

            <!-- 3차 병원: 대학병원 -->
            <h3 id="hospitals3rd-title" style="font-size: 20px; color: #2c3e50; margin-bottom: 15px; display: none; align-items: center; gap: 10px; margin-top: 30px;">
                <span style="background: #FFEBEE; color: #D32F2F; padding: 5px 15px; border-radius: 20px; font-size: 14px; font-weight: 600;">3차 병원</span>
                상급종합병원 · 대학병원
            </h3>
            <div id="hospitals3rd-list"></div>

            <!-- 로딩 중 표시 -->
            <div id="loading-hospitals" style="text-align: center; padding: 40px; color: #999;">
                <div style="font-size: 40px; margin-bottom: 15px;">⏳</div>
                <p style="font-size: 16px;">근처 병원을 검색하고 있습니다...</p>
            </div>

            <!-- 병원 정보가 없을 때 -->
            <div id="no-hospitals" style="text-align: center; padding: 60px 20px; color: #999; display: none;">
                <p style="font-size: 16px; margin-bottom: 10px;">📍 위치 정보를 찾을 수 없습니다</p>
                <p style="font-size: 14px;">브라우저에서 위치 권한을 허용하면 근처 병원을 찾아드립니다</p>
            </div>

            <!-- 더 많은 병원 찾기 버튼 -->
            <div style="text-align: center; margin-top: 30px;">
                <a href="<c:url value='/map/map1'/>" class="btn btn-primary" style="display: inline-block; padding: 16px 32px; text-decoration: none;">
                    🗺️ 지도에서 더 많은 병원 찾기
                </a>
            </div>
        </div>
    </div>

    <!-- 경고 메시지 -->
    <div class="warning-box">
        <h4>⚠️ 중요 안내</h4>
        <p>
            본 서비스는 AI 기반 참고 정보 제공 서비스로, <strong>의학적 진단이나 치료를 대체할 수 없습니다.</strong>
            정확한 진단과 치료를 위해서는 반드시 의료 전문가의 진료를 받으시기 바랍니다.
            응급 상황이거나 증상이 급격히 악화되는 경우 즉시 119에 연락하거나 응급실을 방문하세요.
        </p>
    </div>

    <!-- 액션 버튼 -->
    <div class="action-buttons">
        <button onclick="downloadPDF()" class="btn btn-primary">
             PDF 다운로드
        </button>
        <a href="<c:url value='/map/map1'/>" class="btn btn-primary">
             병원 지도 보기
        </a>
        <a href="<c:url value='/dia/reset'/>" class="btn btn-secondary">
             새로 진단하기
        </a>
        <a href="<c:url value='/'/>" class="btn btn-success">
             홈으로 돌아가기
        </a>
    </div>
</div>

<!-- 카카오 맵 SDK -->
<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=f37b6c5eb063be1a82888e664e204d6d&libraries=services"></script>

<!-- html2canvas와 jsPDF 라이브러리 -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

<script>
    // 위도/경도 정보 (서버에서 전달)
    var userLat = ${userLatitude != null ? userLatitude : 37.5665};
    var userLng = ${userLongitude != null ? userLongitude : 126.9780};
    var recommendedDept = "${recommendedDepartment}";

    console.log("🗺️ 사용자 위치:", userLat, userLng);
    console.log("🏥 추천 진료과:", recommendedDept);

    // 카카오 맵 API 로드 후 실행
    window.addEventListener('load', function() {
        if (typeof kakao === 'undefined') {
            console.error("❌ 카카오 맵 SDK 로드 실패");
            document.getElementById('loading-hospitals').style.display = 'none';
            document.getElementById('no-hospitals').style.display = 'block';
            return;
        }

        kakao.maps.load(function() {
            var ps = new kakao.maps.services.Places();
            var currentPosition = new kakao.maps.LatLng(userLat, userLng);

            // 1차 병원 검색 (의원)
            searchHospitals(ps, currentPosition, recommendedDept + " 의원", "1차", "hospitals1st");

            // 2차 병원 검색 (종합병원)
            searchHospitals(ps, currentPosition, "종합병원", "2차", "hospitals2nd");

            // 3차 병원 검색 (대학병원)
            searchHospitals(ps, currentPosition, "대학병원", "3차", "hospitals3rd");
        });
    });

    var hospitalSearchCount = 0;
    var hospitalSearchTotal = 3;

    function searchHospitals(ps, currentPosition, keyword, type, containerId) {
        var options = {
            location: currentPosition,
            radius: 5000,
            sort: kakao.maps.services.SortBy.DISTANCE,
            size: 5
        };

        ps.keywordSearch(keyword, function(data, status) {
            hospitalSearchCount++;

            if (status === kakao.maps.services.Status.OK && data.length > 0) {
                console.log("✅ " + type + " 병원 검색 성공:", data.length + "개");
                displayHospitals(data, type, containerId);
            } else {
                console.log("⚠️ " + type + " 병원 검색 결과 없음");
            }

            // 모든 검색 완료
            if (hospitalSearchCount >= hospitalSearchTotal) {
                document.getElementById('loading-hospitals').style.display = 'none';

                // 검색 결과가 하나도 없으면 안내 표시
                var has1st = document.getElementById('hospitals1st-list').innerHTML !== '';
                var has2nd = document.getElementById('hospitals2nd-list').innerHTML !== '';
                var has3rd = document.getElementById('hospitals3rd-list').innerHTML !== '';

                if (!has1st && !has2nd && !has3rd) {
                    document.getElementById('no-hospitals').style.display = 'block';
                }
            }
        }, options);
    }

    function displayHospitals(places, type, containerId) {
        var titleElement = document.getElementById(containerId + '-title');
        var listElement = document.getElementById(containerId + '-list');

        if (!listElement) return;

        // 제목 표시
        if (titleElement) {
            titleElement.style.display = 'flex';
        }

        var badgeColor = type === "1차" ? "#1976D2" : (type === "2차" ? "#F57C00" : "#D32F2F");
        var html = '';

        for (var i = 0; i < Math.min(places.length, 3); i++) {
            var place = places[i];
            var distance = place.distance;
            var distanceText = distance < 1000 ? distance + 'm' : (distance / 1000).toFixed(1) + 'km';

            html += '<div class="hospital-card">' +
                '<div class="hospital-header">' +
                '<div class="hospital-name">' + place.place_name + '</div>' +
                '<div class="hospital-badge" style="background: ' + badgeColor + ';">' + recommendedDept + '</div>' +
                '</div>' +
                '<div class="hospital-info">' +
                '<div class="info-item">📍 ' + (place.road_address_name || place.address_name) + '</div>';

            if (place.phone) {
                html += '<div class="info-item">📞 ' + place.phone + '</div>';
            }

            html += '<div class="info-item">📏 현재 위치에서 ' + distanceText + '</div>' +
                '<div class="info-item">' +
                '<a href="' + place.place_url + '" target="_blank" style="color: #5B6FB5; text-decoration: underline;">🗺️ 카카오맵에서 보기</a>' +
                '</div>' +
                '</div></div>';
        }

        listElement.innerHTML = html;
    }

    // PDF 다운로드 함수
    function downloadPDF() {
        // PDF로 변환할 임시 엘리먼트 생성
        const element = document.createElement('div');
        element.style.cssText = `
            width: 800px;
            padding: 60px;
            background: white;
            font-family: 'Noto Sans KR', sans-serif;
            color: #333;
            line-height: 1.8;
        `;

        element.innerHTML = `
            <div style="text-align: center; margin-bottom: 40px;">
                <h1 style="color: #5B6FB5; font-size: 28px; margin-bottom: 10px;">AI 진단 분석 결과</h1>
                <p style="color: #7f8c8d; font-size: 14px;">AI 기반 증상 분석 리포트</p>
            </div>

            <div style="margin-bottom: 30px;">
                <h2 style="color: #2c3e50; font-size: 18px; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 3px solid #5B6FB5;">
                    📋 입력하신 증상
                </h2>
                <div style="background: #f8f9ff; padding: 20px; border-radius: 8px; border-left: 4px solid #5B6FB5;">
                    ${symptomText}
                </div>
            </div>

            <div style="margin-bottom: 30px;">
                <h2 style="color: #2c3e50; font-size: 18px; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 3px solid #5B6FB5;">
                    🧠 AI 진단 분석
                </h2>
                <div style="background: #f8f9ff; padding: 20px; border-radius: 8px; border-left: 4px solid #5B6FB5; white-space: pre-line;">
                    ${aiDiagnosis}
                </div>
            </div>

            <div style="margin-bottom: 30px;">
                <h2 style="color: #2c3e50; font-size: 18px; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 3px solid #5B6FB5;">
                    💡 추천 정보
                </h2>
                <div style="background: #f8f9ff; padding: 20px; border-radius: 8px; border-left: 4px solid #5B6FB5;">
                    <p style="margin-bottom: 10px;"><strong>추천 진료과:</strong> ${recommendedDepartment}</p>
                    <p><strong>진료 시급성:</strong> ${urgency}</p>
                </div>
            </div>

            <div style="background: #FFF3CD; border: 2px solid #FFC107; border-radius: 8px; padding: 20px; margin-top: 30px;">
                <p style="color: #856404; font-size: 12px; line-height: 1.6; margin: 0;">
                    <strong>⚠️ 중요 안내:</strong> 본 서비스는 AI 기반 참고 정보 제공 서비스로, 의학적 진단이나 치료를 대체할 수 없습니다.
                    정확한 진단과 치료를 위해서는 반드시 의료 전문가의 진료를 받으시기 바랍니다.
                </p>
            </div>
        `;

        // 임시로 body에 추가 (화면에 보이지 않게)
        element.style.position = 'fixed';
        element.style.left = '-9999px';
        document.body.appendChild(element);

        // html2canvas로 이미지 생성
        html2canvas(element, {
            scale: 2,
            useCORS: true,
            logging: false,
            backgroundColor: '#ffffff'
        }).then(function(canvas) {
            // 임시 엘리먼트 제거
            document.body.removeChild(element);

            // jsPDF 생성
            const imgData = canvas.toDataURL('image/png');
            const imgWidth = 210; // A4 width in mm
            const pageHeight = 297; // A4 height in mm
            const imgHeight = (canvas.height * imgWidth) / canvas.width;
            let heightLeft = imgHeight;

            const { jsPDF } = window.jspdf;
            const pdf = new jsPDF('p', 'mm', 'a4');
            let position = 0;

            // 첫 페이지
            pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
            heightLeft -= pageHeight;

            // 여러 페이지 처리
            while (heightLeft > 0) {
                position = heightLeft - imgHeight;
                pdf.addPage();
                pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
                heightLeft -= pageHeight;
            }

            // PDF 다운로드
            pdf.save('AI진단결과.pdf');
            console.log('✅ PDF 다운로드 완료');
        }).catch(function(error) {
            console.error('❌ PDF 생성 실패:', error);
            alert('PDF 생성 중 오류가 발생했습니다.');
        });
    }
</script>
</body>
</html>