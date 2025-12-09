<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .appointment-container {
        max-width: 800px;
        margin: 40px auto;
        padding: 30px;
        background: white;
        border-radius: 12px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }

    .appointment-header {
        text-align: center;
        margin-bottom: 30px;
    }

    .appointment-header h2 {
        font-size: 28px;
        color: #333;
        margin-bottom: 10px;
    }

    .appointment-header p {
        color: #666;
        font-size: 14px;
    }

    .form-group {
        margin-bottom: 25px;
    }

    .form-label {
        display: block;
        font-weight: 600;
        color: #333;
        margin-bottom: 8px;
        font-size: 14px;
    }

    .form-control {
        width: 100%;
        padding: 12px 15px;
        border: 1px solid #ddd;
        border-radius: 8px;
        font-size: 14px;
        transition: border-color 0.3s;
    }

    .form-control:focus {
        outline: none;
        border-color: #5B6FB5;
        box-shadow: 0 0 0 3px rgba(91, 111, 181, 0.1);
    }

    textarea.form-control {
        min-height: 100px;
        resize: vertical;
    }

    .appointment-type-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 15px;
    }

    .type-card {
        padding: 20px;
        border: 2px solid #e0e0e0;
        border-radius: 8px;
        text-align: center;
        cursor: pointer;
        transition: all 0.3s;
    }

    .type-card:hover {
        border-color: #5B6FB5;
        background: #f8f9ff;
    }

    .type-card input[type="radio"] {
        display: none;
    }

    .type-card input[type="radio"]:checked + label {
        color: #5B6FB5;
    }

    .type-card.selected {
        border-color: #5B6FB5;
        background: #f8f9ff;
    }

    .type-icon {
        font-size: 32px;
        margin-bottom: 10px;
    }

    .type-label {
        font-weight: 600;
        font-size: 16px;
        display: block;
    }

    .btn-group {
        display: flex;
        gap: 10px;
        margin-top: 30px;
    }

    .btn {
        flex: 1;
        padding: 14px 20px;
        border: none;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
    }

    .btn-primary {
        background: #5B6FB5;
        color: white;
    }

    .btn-primary:hover {
        background: #4a5d9d;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(91, 111, 181, 0.3);
    }

    .btn-secondary {
        background: #f0f0f0;
        color: #333;
    }

    .btn-secondary:hover {
        background: #e0e0e0;
    }

    .alert {
        padding: 15px 20px;
        border-radius: 8px;
        margin-bottom: 20px;
        font-size: 14px;
    }

    .alert-success {
        background: #d4edda;
        border: 1px solid #c3e6cb;
        color: #155724;
    }

    .alert-error {
        background: #f8d7da;
        border: 1px solid #f5c6cb;
        color: #721c24;
    }

    @media (max-width: 768px) {
        .appointment-type-grid {
            grid-template-columns: 1fr;
        }

        .btn-group {
            flex-direction: column;
        }
    }
</style>

<div class="appointment-container">
    <div class="appointment-header">
        <h2>🗓️ 상담 예약 신청</h2>
        <p>원하시는 상담 유형과 시간을 선택해주세요</p>
    </div>

    <c:if test="${not empty message}">
        <div class="alert alert-success">${message}</div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-error">${error}</div>
    </c:if>

    <form method="post" action="<c:url value='/appointment/create'/>" id="appointmentForm">

        <!-- 상담 유형 선택 -->
        <div class="form-group">
            <label class="form-label">상담 유형 선택 *</label>
            <div class="appointment-type-grid">
                <div class="type-card" onclick="selectType(this, 'video')">
                    <div class="type-icon">📹</div>
                    <input type="radio" name="appointmentType" value="video" id="type-video" required>
                    <label for="type-video" class="type-label">화상 상담</label>
                </div>

                <div class="type-card" onclick="selectType(this, 'chat')">
                    <div class="type-icon">💬</div>
                    <input type="radio" name="appointmentType" value="chat" id="type-chat" required>
                    <label for="type-chat" class="type-label">채팅 상담</label>
                </div>

                <div class="type-card" onclick="selectType(this, 'phone')">
                    <div class="type-icon">📞</div>
                    <input type="radio" name="appointmentType" value="phone" id="type-phone" required>
                    <label for="type-phone" class="type-label">전화 상담</label>
                </div>
            </div>
        </div>

        <!-- 희망 일시 -->
        <div class="form-group">
            <label class="form-label" for="appointmentTime">희망 일시 *</label>
            <input type="datetime-local"
                   class="form-control"
                   id="appointmentTime"
                   name="appointmentTime"
                   required
                   min="${minDateTime}">
            <small style="color: #666; font-size: 12px; margin-top: 5px; display: block;">
                * 평일 09:00 ~ 18:00 사이에서 선택해주세요
            </small>
        </div>

        <!-- 메모 -->
        <div class="form-group">
            <label class="form-label" for="notes">상담 내용 (선택)</label>
            <textarea class="form-control"
                      id="notes"
                      name="notes"
                      placeholder="상담하고 싶은 내용이나 특별히 요청하실 사항이 있으시면 작성해주세요."></textarea>
        </div>

        <!-- 버튼 -->
        <div class="btn-group">
            <button type="button" class="btn btn-secondary" onclick="history.back()">취소</button>
            <button type="submit" class="btn btn-primary">예약 신청</button>
        </div>
    </form>
</div>

<script>
    // 현재 시간 + 1시간을 최소 시간으로 설정
    const now = new Date();
    now.setHours(now.getHours() + 1);
    const minDateTime = now.toISOString().slice(0, 16);
    document.getElementById('appointmentTime').setAttribute('min', minDateTime);

    // 상담 유형 선택
    function selectType(card, type) {
        // 모든 카드의 선택 해제
        document.querySelectorAll('.type-card').forEach(c => c.classList.remove('selected'));

        // 선택된 카드 활성화
        card.classList.add('selected');
        document.getElementById('type-' + type).checked = true;
    }

    // 폼 제출 전 검증
    document.getElementById('appointmentForm').addEventListener('submit', function(e) {
        const appointmentTime = new Date(document.getElementById('appointmentTime').value);
        const hour = appointmentTime.getHours();
        const day = appointmentTime.getDay();

        // 주말 체크
        if (day === 0 || day === 6) {
            e.preventDefault();
            alert('주말에는 예약이 불가능합니다. 평일을 선택해주세요.');
            return false;
        }

        // 시간 체크 (09:00 ~ 18:00)
        if (hour < 9 || hour >= 18) {
            e.preventDefault();
            alert('예약 가능 시간은 평일 09:00 ~ 18:00입니다.');
            return false;
        }
    });
</script>