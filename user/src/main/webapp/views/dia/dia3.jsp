<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI 분석 중</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
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
            max-width: 900px;
            width: 100%;
            padding: 50px;
            text-align: center;
        }

        h1 {
            color: #667eea;
            font-size: 32px;
            margin-bottom: 20px;
        }

        .loading {
            font-size: 20px;
            color: #333;
            margin: 30px 0;
        }

        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            width: 60px;
            height: 60px;
            animation: spin 1s linear infinite;
            margin: 30px auto;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .step {
            background: #f8f9ff;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
<div class="container">
    <h1> AI 분석 진행 중</h1>
    <p class="loading">증상을 분석하고 있습니다...</p>

    <div class="spinner"></div>

    <div class="step">
        <h3>입력하신 증상:</h3>
        <p>${symptomText}</p>
    </div>

    <form id="analysisForm" action="${pageContext.request.contextPath}/dia/dia4" method="post" style="display:none;">
    </form>
</div>

<script>
    console.log("dia3.jsp 로드됨");

    // 페이지 로드 시 위치 정보 가져오기
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            function(position) {
                console.log("✅ 위치 정보 획득:", position.coords.latitude, position.coords.longitude);

                // 위치 정보를 hidden input에 추가
                const form = document.getElementById('analysisForm');

                const latInput = document.createElement('input');
                latInput.type = 'hidden';
                latInput.name = 'latitude';
                latInput.value = position.coords.latitude;

                const lonInput = document.createElement('input');
                lonInput.type = 'hidden';
                lonInput.name = 'longitude';
                lonInput.value = position.coords.longitude;

                form.appendChild(latInput);
                form.appendChild(lonInput);
            },
            function(error) {
                console.warn("⚠️ 위치 정보 가져오기 실패:", error.message);
                // 위치 정보 없이도 진행
            }
        );
    }

    // 5초 후 dia4로 이동
    setTimeout(function() {
        console.log("dia4로 이동 시작");
        document.getElementById('analysisForm').submit();
    }, 5000);
</script>
</body>
</html>