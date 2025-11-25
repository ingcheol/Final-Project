<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    java.util.List<String> images = (java.util.List<String>) session.getAttribute("symptomImages");
    System.out.println("===== JSP에서 세션 확인 =====");
    System.out.println("이미지 개수: " + (images != null ? images.size() : "null"));
    if (images != null && images.size() > 0) {
        System.out.println("첫 번째 이미지: " + images.get(0).substring(0, 50) + "...");
    }
%>
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

        .result-card {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 4px 30px rgba(0,0,0,0.1);
            margin-bottom: 25px;
        }

        .card-header h2 {
            font-size: 28px;
            color: #2c3e50;
            margin-bottom: 10px;
        }

        .analysis-section {
            margin-bottom: 30px;
        }

        .analysis-title {
            font-size: 20px;
            color: #5B6FB5;
            font-weight: 600;
            margin-bottom: 15px;
        }

        .analysis-content {
            background: #f8f9ff;
            padding: 30px;
            border-radius: 12px;
            border-left: 4px solid #5B6FB5;
            line-height: 1.8;
            white-space: pre-line;
        }

        /* 이미지 섹션 스타일 */
        .uploaded-images {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }

        .uploaded-image-item {
            position: relative;
            border-radius: 12px;
            overflow: hidden;
            border: 2px solid #e0e0e0;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .uploaded-image-item img {
            width: 100%;
            height: 200px;
            object-fit: cover;
            cursor: pointer;
            transition: transform 0.3s;
        }

        .uploaded-image-item img:hover {
            transform: scale(1.05);
        }

        .image-label {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background: rgba(0,0,0,0.6);
            color: white;
            padding: 8px;
            text-align: center;
            font-size: 12px;
            font-weight: 600;
        }

        /* 병원 리스트 - 검색 결과 없을 때 */
        .no-hospital-message {
            text-align: center;
            padding: 40px 20px;
            background: #f8f9fa;
            border-radius: 12px;
            border: 2px dashed #dee2e6;
            color: #6c757d;
            margin-top: 15px;
        }

        .no-hospital-message .icon {
            font-size: 48px;
            margin-bottom: 15px;
        }

        .no-hospital-message h4 {
            font-size: 18px;
            color: #495057;
            margin-bottom: 10px;
        }

        .no-hospital-message p {
            font-size: 14px;
            line-height: 1.6;
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

        @media (max-width: 768px) {
            .uploaded-images {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        /* 언어 선택 버튼 */
        .language-selector {
            display: flex;
            gap: 8px;
            background: #f0f0f0;
            padding: 5px;
            border-radius: 20px;
        }

        .lang-btn {
            padding: 6px 12px;
            border: none;
            background: transparent;
            border-radius: 15px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            color: #666;
            transition: all 0.3s;
        }

        .lang-btn:hover {
            background: rgba(91, 111, 181, 0.1);
            color: #5B6FB5;
        }

        .lang-btn.active {
            background: #5B6FB5;
            color: white;
        }
    </style>
</head>
<body>
<header>
    <nav>
        <a href="<c:url value="/"/>" class="logo" data-i18n="logo">🏥 AI 의료 매칭 시스템</a>

        <div class="language-selector">
            <button class="lang-btn active" data-lang="ko">한국어</button>
            <button class="lang-btn" data-lang="en">English</button>
            <button class="lang-btn" data-lang="ja">日本語</button>
            <button class="lang-btn" data-lang="zh">中文</button>
        </div>
    </nav>
</header>

<div class="main-container">
    <span data-i18n="analysisComplete">✅ 분석이 완료되었습니다!</span>

    <!-- AI 분석 결과 -->
    <div class="result-card">
        <div class="card-header" style="border-bottom: 3px solid #f0f0f0; padding-bottom: 20px; margin-bottom: 30px;">
            <h2 data-i18n="aiResultTitle">🔬 AI 분석 결과</h2>
            <p style="color: #7f8c8d; font-size: 15px;" data-i18n="aiResultSubtitle">입력하신 증상을 바탕으로 분석한 결과입니다</p>
        </div>

        <div class="analysis-section">
            <div class="analysis-title" data-i18n="inputSymptomTitle">📋 입력하신 증상</div>
            <div class="analysis-content">${symptomText}</div>
        </div>

        <!-- 업로드된 이미지 표시 -->
        <c:if test="${not empty symptomImages}">
            <div class="analysis-section">
                <div class="analysis-title">
                    <span data-i18n="uploadedImagesTitle">📸 업로드하신 증상 사진</span> (${symptomImages.size()}장)
                </div>
                <div class="uploaded-images">
                    <c:forEach items="${symptomImages}" var="imageData" varStatus="status">
                        <div class="uploaded-image-item">
                            <img src="${imageData}" alt="증상 사진 ${status.index + 1}" onclick="openImageModal('${imageData}')">
                            <div class="image-label">사진 ${status.index + 1}</div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <div class="analysis-section">
            <div class="analysis-title" data-i18n="aiDiagnosisTitle">🧠 AI 종합 진단</div>
            <div class="analysis-content">${aiDiagnosis}</div>
        </div>
    </div>

    <!-- 추천 사항 -->
    <div style="background: linear-gradient(135deg, #FFF3E0 0%, #FFE0B2 100%); border: 2px solid #FFB74D; border-radius: 15px; padding: 30px; margin: 30px 0;">
        <h3 style="color: #E65100; font-size: 20px; margin-bottom: 15px;" data-i18n="recommendationTitle">💡 추천 사항</h3>

        <div style="background: white; padding: 20px; border-radius: 10px; margin-bottom: 15px; display: flex; align-items: center; gap: 15px;">
            <div style="font-size: 32px; min-width: 50px; text-align: center;">🏥</div>
            <div>
                <div style="font-weight: 600; color: #333; font-size: 16px; margin-bottom: 5px;">
                    <span data-i18n="recommendedDept">추천 진료과:</span> ${recommendedDepartment}
                </div>
                <div style="color: #666; font-size: 14px;">증상에 적합한 진료과를 안내해드립니다</div>
            </div>
        </div>

        <div style="background: white; padding: 20px; border-radius: 10px; margin-bottom: 15px; display: flex; align-items: center; gap: 15px;">
            <div style="font-size: 32px; min-width: 50px; text-align: center;">⏰</div>
            <div>
                <div style="font-weight: 600; color: #333; font-size: 16px; margin-bottom: 5px;">
                    <span data-i18n="urgencyLevel">진료 시급성:</span> ${urgency}
                </div>
                <div style="color: #666; font-size: 14px;">증상의 심각도에 따른 권장 방문 시기입니다</div>
            </div>
        </div>
    </div>

    <!-- 근처 병원 추천 -->
    <div class="result-card">
        <div class="card-header" style="border-bottom: 3px solid #f0f0f0; padding-bottom: 20px; margin-bottom: 30px;">
            <h2 data-i18n="hospitalTitle">🏥 추천 병원</h2>
            <p style="color: #7f8c8d; font-size: 15px;" data-i18n="hospitalSubtitle">증상에 맞는 근처 병원을 추천해드립니다</p>
        </div>

        <div>
            <!-- 1차 병원 -->
            <h3 id="hospitals1st-title" style="font-size: 20px; color: #2c3e50; margin-bottom: 15px; display: none; align-items: center; gap: 10px; margin-top: 30px;">
                <span style="background: #E3F2FD; color: #1976D2; padding: 5px 15px; border-radius: 20px; font-size: 14px; font-weight: 600;">1차 병원</span>
                <span data-i18n="hospital1st">가까운 의원 · 클리닉</span>
            </h3>
            <div id="hospitals1st-list"></div>
            <div id="no-hospitals1st" class="no-hospital-message" style="display: none;">
                <div class="icon">🏥</div>
                <h4>주변에 의원/클리닉이 없습니다</h4>
                <p>검색 범위를 넓혀보시거나 지도에서 직접 찾아보세요</p>
            </div>

            <!-- 2차 병원 -->
            <h3 id="hospitals2nd-title" style="font-size: 20px; color: #2c3e50; margin-bottom: 15px; display: none; align-items: center; gap: 10px; margin-top: 30px;">
                <span style="background: #FFF3E0; color: #F57C00; padding: 5px 15px; border-radius: 20px; font-size: 14px; font-weight: 600;">2차 병원</span>
                <span data-i18n="hospital2nd">종합병원</span>
            </h3>
            <div id="hospitals2nd-list"></div>
            <div id="no-hospitals2nd" class="no-hospital-message" style="display: none;">
                <div class="icon">🏥</div>
                <h4>주변에 종합병원이 없습니다</h4>
                <p>검색 범위를 넓혀보시거나 지도에서 직접 찾아보세요</p>
            </div>

            <!-- 3차 병원 -->
            <h3 id="hospitals3rd-title" style="font-size: 20px; color: #2c3e50; margin-bottom: 15px; display: none; align-items: center; gap: 10px; margin-top: 30px;">
                <span style="background: #FFEBEE; color: #D32F2F; padding: 5px 15px; border-radius: 20px; font-size: 14px; font-weight: 600;">3차 병원</span>
                <span data-i18n="hospital3rd">상급종합병원 · 대학병원</span>
            </h3>
            <div id="hospitals3rd-list"></div>
            <div id="no-hospitals3rd" class="no-hospital-message" style="display: none;">
                <div class="icon">🏥</div>
                <h4>주변에 대학병원이 없습니다</h4>
                <p>검색 범위를 넓혀보시거나 지도에서 직접 찾아보세요</p>
            </div>

            <!-- 로딩 중 -->
            <div id="loading-hospitals" style="text-align: center; padding: 40px; color: #999;">
                <div style="font-size: 40px; margin-bottom: 15px;">⏳</div>
                <p style="font-size: 16px;" data-i18n="searching">근처 병원을 검색하고 있습니다...</p>
            </div>
        </div>
    </div>

    <!-- 경고 메시지 -->
    <div style="background: #FFF3CD; border: 2px solid #FFC107; border-radius: 12px; padding: 20px; margin: 30px 0;">
        <h4 style="color: #856404; font-size: 16px; margin-bottom: 10px;" data-i18n="warningTitle">⚠️ 중요 안내</h4>
        <p style="color: #856404; font-size: 14px; line-height: 1.6;" data-i18n="warningMessage">
            본 서비스는 AI 기반 참고 정보 제공 서비스로, <strong>의학적 진단이나 치료를 대체할 수 없습니다.</strong>
            정확한 진단과 치료를 위해서는 반드시 의료 전문가의 진료를 받으시기 바랍니다.
            응급 상황이거나 증상이 급격히 악화되는 경우 즉시 119에 연락하거나 응급실을 방문하세요.
        </p>
    </div>

    <!-- 액션 버튼 -->
    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin-top: 40px;">
        <button onclick="downloadPDF()" style="flex: 1; padding: 16px 24px; border: none; border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer; background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%); color: white; transition: all 0.3s;">
            <span data-i18n="btnDownloadPDF"> PDF 다운로드</span>
        </button>
        <a href="<c:url value='/map/map1'/>" style="flex: 1; padding: 16px 24px; border: none; border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer; background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%); color: white; text-decoration: none; text-align: center; display: flex; align-items: center; justify-content: center; transition: all 0.3s;">
            <span data-i18n="btnViewMap"> 병원 지도 보기</span>
        </a>
        <a href="<c:url value='/dia/reset'/>" style="flex: 1; padding: 16px 24px; border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer; background: white; color: #666; border: 2px solid #e0e0e0; text-decoration: none; text-align: center; display: flex; align-items: center; justify-content: center; transition: all 0.3s;">
            <span data-i18n="btnNewDiagnosis"> 새로 진단하기</span>
        </a>
        <a href="<c:url value='/'/>" style="flex: 1; padding: 16px 24px; border: none; border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; text-decoration: none; text-align: center; display: flex; align-items: center; justify-content: center; transition: all 0.3s;">
            <span data-i18n="btnHome"> 홈으로 돌아가기</span>
        </a>
    </div>
</div>

<!-- 이미지 확대 모달 -->
<div id="imageModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.9); z-index: 9999; justify-content: center; align-items: center; cursor: pointer;" onclick="this.style.display='none'">
    <span style="position: absolute; top: 30px; right: 50px; color: white; font-size: 50px; font-weight: bold; cursor: pointer;">&times;</span>
    <img id="modalImage" style="max-width: 90%; max-height: 90%; object-fit: contain; border-radius: 12px; box-shadow: 0 0 30px rgba(0,0,0,0.5);">
</div>

<!-- 카카오 맵 SDK -->
<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=f37b6c5eb063be1a82888e664e204d6d&libraries=services"></script>

<!-- html2canvas와 jsPDF 라이브러리 -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>

<script>
    // 디버깅: 이미지 데이터 확인
    console.log("=== dia4 페이지 로드 ===");

    <c:if test="${not empty symptomImages}">
    console.log("✅ 이미지 데이터 있음");
    console.log("📸 이미지 개수: ${symptomImages.size()}");

    // 각 이미지 데이터 확인
    <c:forEach items="${symptomImages}" var="img" varStatus="status">
    console.log("이미지 ${status.index + 1}:", "${img}".substring(0, 50) + "...");
    </c:forEach>
    </c:if>

    <c:if test="${empty symptomImages}">
    console.log("❌ 이미지 데이터 없음");
    </c:if>

    var userLat = ${userLatitude != null ? userLatitude : 37.5665};
    var userLng = ${userLongitude != null ? userLongitude : 126.9780};
    var recommendedDept = "${recommendedDepartment}";

    window.addEventListener('load', function() {
        if (typeof kakao === 'undefined') {
            console.error("❌ 카카오 맵 SDK 로드 실패");
            document.getElementById('loading-hospitals').style.display = 'none';
            return;
        }

        kakao.maps.load(function() {
            var ps = new kakao.maps.services.Places();
            var currentPosition = new kakao.maps.LatLng(userLat, userLng);

            searchHospitals(ps, currentPosition, recommendedDept + " 의원", "1차", "hospitals1st");
            searchHospitals(ps, currentPosition, "종합병원", "2차", "hospitals2nd");
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
                // 검색 결과 없을 때 메시지 표시
                document.getElementById('no-' + containerId).style.display = 'block';
            }

            if (hospitalSearchCount >= hospitalSearchTotal) {
                document.getElementById('loading-hospitals').style.display = 'none';
            }
        }, options);
    }

    function displayHospitals(places, type, containerId) {
        var titleElement = document.getElementById(containerId + '-title');
        var listElement = document.getElementById(containerId + '-list');

        if (!listElement) return;

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
                '<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">' +
                '<div style="font-size: 20px; font-weight: 600; color: #2c3e50;">' + place.place_name + '</div>' +
                '<div style="background: ' + badgeColor + '; color: white; padding: 6px 15px; border-radius: 20px; font-size: 13px; font-weight: 600;">' + recommendedDept + '</div>' +
                '</div>' +
                '<div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px;">' +
                '<div style="font-size: 14px; color: #666;">📍 ' + (place.road_address_name || place.address_name) + '</div>';

            if (place.phone) {
                html += '<div style="font-size: 14px; color: #666;">📞 ' + place.phone + '</div>';
            }

            html += '<div style="font-size: 14px; color: #666;">📏 ' + distanceText + '</div>' +
                '<div style="font-size: 14px;"><a href="' + place.place_url + '" target="_blank" style="color: #5B6FB5; text-decoration: underline;">🗺️ 카카오맵</a></div>' +
                '</div></div>';
        }

        listElement.innerHTML = html;
    }

    // 이미지 확대 모달
    function openImageModal(imgSrc) {
        var modal = document.getElementById('imageModal');
        var modalImg = document.getElementById('modalImage');
        modal.style.display = 'flex';
        modalImg.src = imgSrc;
    }

    // PDF 다운로드 함수
    function downloadPDF() {
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

        element.style.position = 'fixed';
        element.style.left = '-9999px';
        document.body.appendChild(element);

        html2canvas(element, {
            scale: 2,
            useCORS: true,
            logging: false,
            backgroundColor: '#ffffff'
        }).then(function(canvas) {
            document.body.removeChild(element);

            const imgData = canvas.toDataURL('image/png');
            const imgWidth = 210;
            const pageHeight = 297;
            const imgHeight = (canvas.height * imgWidth) / canvas.width;
            let heightLeft = imgHeight;

            const { jsPDF } = window.jspdf;
            const pdf = new jsPDF('p', 'mm', 'a4');
            let position = 0;

            pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
            heightLeft -= pageHeight;

            while (heightLeft > 0) {
                position = heightLeft - imgHeight;
                pdf.addPage();
                pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
                heightLeft -= pageHeight;
            }

            pdf.save('AI진단결과.pdf');
            console.log('✅ PDF 다운로드 완료');
        }).catch(function(error) {
            console.error('❌ PDF 생성 실패:', error);
            alert('PDF 생성 중 오류가 발생했습니다.');
        });
    }
</script>
<!-- multilang.js 추가 -->
<script src="<c:url value='/js/multilang.js'/>"></script>

<!-- 카카오 맵 SDK -->
<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=..."></script>
</body>
</html>