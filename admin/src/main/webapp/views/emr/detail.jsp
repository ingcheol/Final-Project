<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  .detail-container {
    max-width: 1000px;
    margin: 40px auto;
    padding: 0 30px;
  }

  .back-link {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: #667eea;
    text-decoration: none;
    font-weight: 600;
    margin-bottom: 24px;
    font-size: 14px;
    transition: all 0.2s;
  }

  .back-link:hover {
    color: #5568d3;
    gap: 12px;
  }

  .page-header {
    margin-bottom: 32px;
  }

  .page-title {
    font-size: 28px;
    font-weight: 700;
    color: #333;
    margin-bottom: 8px;
  }

  .page-subtitle {
    font-size: 15px;
    color: #666;
  }

  .detail-card {
    background: white;
    border-radius: 12px;
    padding: 28px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    margin-bottom: 20px;
  }

  .card-header-section {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-bottom: 20px;
    border-bottom: 2px solid #e9ecef;
    margin-bottom: 24px;
  }

  .emr-id-title {
    font-size: 22px;
    font-weight: 700;
    color: #333;
  }

  .emr-id-number {
    color: #667eea;
  }

  .section-title {
    font-size: 18px;
    font-weight: 600;
    color: #333;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .info-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;
  }

  .info-box {
    background: #f8f9fa;
    padding: 18px;
    border-radius: 10px;
    border-left: 4px solid #667eea;
  }

  .info-label {
    font-size: 12px;
    font-weight: 600;
    color: #666;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 8px;
  }

  .info-value {
    font-size: 18px;
    font-weight: 700;
    color: #333;
  }

  .content-card {
    background: white;
    border-radius: 12px;
    padding: 28px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    margin-bottom: 20px;
  }

  .content-card.success-border {
    border-left: 5px solid #28a745;
  }

  .content-card.info-border {
    border-left: 5px solid #17a2b8;
  }

  .content-card.warning-border {
    border-left: 5px solid #ffc107;
  }

  .content-card.danger-border {
    border-left: 5px solid #dc3545;
  }

  .section-title.success {
    color: #28a745;
  }

  .section-title.info {
    color: #17a2b8;
  }

  .section-title.warning {
    color: #ffc107;
  }

  .section-title.danger {
    color: #dc3545;
  }

  .content-box {
    background: #f8f9fa;
    padding: 20px;
    border-radius: 8px;
    min-height: 100px;
    white-space: pre-wrap;
    line-height: 1.8;
    font-size: 14px;
    color: #495057;
  }

  .content-box.mono {
    font-family: 'Courier New', monospace;
    font-size: 13px;
  }

  .split-section {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;
  }

  .collapse-section {
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    overflow: hidden;
    margin-bottom: 20px;
  }

  .collapse-header {
    background: #f8f9fa;
    padding: 18px 24px;
    cursor: pointer;
    display: flex;
    justify-content: space-between;
    align-items: center;
    transition: all 0.3s;
  }

  .collapse-header:hover {
    background: #e9ecef;
  }

  .collapse-title {
    font-size: 16px;
    font-weight: 600;
    color: #495057;
    margin: 0;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .collapse-icon {
    transition: transform 0.3s;
  }

  .collapse-icon.rotated {
    transform: rotate(180deg);
  }

  .collapse-content {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s ease;
  }

  .collapse-content.show {
    max-height: 600px;
    overflow-y: auto;
  }

  .collapse-body {
    background: #1e1e1e;
    padding: 24px;
  }

  .code-block {
    color: #d4d4d4;
    font-family: 'Courier New', monospace;
    font-size: 13px;
    line-height: 1.6;
    white-space: pre-wrap;
    margin: 0;
  }

  @media (max-width: 768px) {
    .detail-container {
      padding: 0 15px;
    }

    .info-grid,
    .split-section {
      grid-template-columns: 1fr;
    }

    .card-header-section {
      flex-direction: column;
      align-items: flex-start;
      gap: 12px;
    }
  }
</style>

<div class="detail-container">
  <a href="/admin/emr" class="back-link">
    ← 목록으로 돌아가기
  </a>

  <div class="page-header">
    <h1 class="page-title">📋 EMR 상세 정보</h1>
    <p class="page-subtitle">전자의무기록 상세 조회</p>
  </div>

  <!-- 기본 정보 -->
  <div class="detail-card">
    <div class="card-header-section">
      <div class="emr-id-title">
        EMR <span class="emr-id-number">#${emr.emrId}</span>
      </div>
    </div>

    <div class="info-grid">
      <div class="info-box">
        <div class="info-label">👤 환자 ID</div>
        <div class="info-value">#${emr.patientId}</div>
      </div>

      <div class="info-box">
        <div class="info-label">🩺 상담 ID</div>
        <div class="info-value">#${emr.consultationId}</div>
      </div>
    </div>
  </div>

  <!-- 환자 진술 -->
  <div class="content-card success-border">
    <h3 class="section-title success">🎤 환자 진술 (STT)</h3>
    <div class="content-box">
      ${emr.patientStatement}
    </div>
  </div>

  <!-- 검사 결과 & 처방 내역 -->
  <div class="split-section">
    <div class="content-card info-border">
      <h3 class="section-title info">🧪 검사 결과</h3>
      <div class="content-box">
        ${emr.testResults}
      </div>
    </div>

    <div class="content-card warning-border">
      <h3 class="section-title warning">💊 처방 내역</h3>
      <div class="content-box">
        ${emr.prescriptionDetails}
      </div>
    </div>
  </div>

  <!-- SOAP 최종 기록 -->
  <div class="content-card danger-border">
    <h3 class="section-title danger">📝 최종 기록 (SOAP)</h3>
    <div class="content-box mono" style="min-height: 300px; max-height: 500px; overflow-y: auto;">
      ${emr.finalRecord}
    </div>
  </div>

  <!-- AI 초안 (접기/펼치기) -->
  <div class="collapse-section">
    <div class="collapse-header" onclick="toggleCollapse()">
      <h3 class="collapse-title">
        🤖 AI 생성 초안 (JSON)
      </h3>
      <span class="collapse-icon" id="collapseIcon">▼</span>
    </div>
    <div class="collapse-content" id="collapseContent">
      <div class="collapse-body">
        <pre class="code-block">${emr.aiGeneratedDraft}</pre>
      </div>
    </div>
  </div>
</div>

<script>
  function toggleCollapse() {
    const content = document.getElementById('collapseContent');
    const icon = document.getElementById('collapseIcon');

    content.classList.toggle('show');
    icon.classList.toggle('rotated');
  }
</script>