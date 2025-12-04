<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* --- 기존 스타일 유지 --- */
    .chatbot-button {
        position: fixed;
        bottom: 30px;
        right: 30px;
        width: 70px;
        height: 70px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 50%;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
        z-index: 9999;
        border: none;
    }

    .chatbot-button:hover {
        transform: scale(1.1);
        box-shadow: 0 6px 20px rgba(0, 0, 0, 0.4);
    }

    .chatbot-button svg {
        width: 35px;
        height: 35px;
        fill: white;
    }

    .chatbot-modal {
        display: none;
        position: fixed;
        bottom: 20px;
        right: 20px;
        width: 400px;
        max-width: calc(100vw - 40px);
        height: 600px;
        max-height: calc(100vh - 100px);
        background: white;
        border-radius: 20px;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
        z-index: 9998;
        flex-direction: column;
        overflow: hidden;
    }

    .chatbot-modal.active {
        display: flex;
        animation: slideUp 0.3s ease-out;
    }

    @keyframes slideUp {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .chatbot-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 15px 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-shrink: 0;
        position: relative;
    }

    .chatbot-header h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
    }

    .chatbot-header-controls {
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .lang-dropdown-container {
        position: relative;
        display: inline-block;
    }

    .lang-dropdown-btn {
        background: rgba(255, 255, 255, 0.2);
        color: white;
        padding: 6px 12px;
        border-radius: 15px;
        border: 1px solid rgba(255, 255, 255, 0.3);
        cursor: pointer;
        font-size: 13px;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 5px;
        transition: all 0.2s;
    }

    .lang-dropdown-btn:hover {
        background: rgba(255, 255, 255, 0.3);
    }

    .lang-dropdown-content {
        display: none;
        position: absolute;
        right: 0;
        top: 100%;
        margin-top: 5px;
        background-color: white;
        min-width: 100px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        border-radius: 10px;
        overflow: hidden;
        z-index: 10000;
    }

    .lang-dropdown-content.show {
        display: block;
        animation: fadeIn 0.2s;
    }

    .lang-dropdown-content button {
        color: #333;
        padding: 10px 16px;
        text-decoration: none;
        display: block;
        width: 100%;
        text-align: left;
        border: none;
        background: none;
        cursor: pointer;
        font-size: 13px;
    }

    .lang-dropdown-content button:hover {
        background-color: #f5f7fa;
        color: #667eea;
    }

    .lang-dropdown-content button.active {
        background-color: #f0f0f0;
        font-weight: bold;
        color: #667eea;
    }

    .chatbot-close {
        background: none;
        border: none;
        color: white;
        font-size: 28px;
        cursor: pointer;
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: transform 0.2s;
        line-height: 1;
        margin-left: 8px;
    }

    .chatbot-close:hover {
        transform: rotate(90deg);
    }

    .chatbot-body {
        flex: 1;
        padding: 20px;
        overflow-y: auto;
        background: #f5f7fa;
        display: flex;
        flex-direction: column;
        gap: 15px;
    }

    /* --- [수정됨] 퀵 버튼 스타일 --- */
    .quick-replies-container {
        padding: 10px 20px 0 20px;
        background: #f5f7fa;
        display: flex;
        gap: 8px;

        /* 기본은 가로 정렬 */
        flex-wrap: nowrap;
        overflow-x: hidden; /* 스크롤바 숨김 (더보기 버튼으로 제어) */

        transition: all 0.3s ease;
    }

    /* 확장되었을 때 스타일 */
    .quick-replies-container.expanded {
        flex-wrap: wrap; /* 줄바꿈 허용 */
        overflow-y: auto;
        max-height: 150px; /* 너무 길어지면 내부 스크롤 */
    }

    .quick-reply-btn {
        background: white;
        border: 1px solid #667eea;
        color: #667eea;
        padding: 6px 12px;
        border-radius: 15px;
        font-size: 12px;
        cursor: pointer;
        transition: all 0.2s;
        flex-shrink: 0;
        box-shadow: 0 2px 4px rgba(102, 126, 234, 0.1);
        white-space: nowrap;
    }

    .quick-reply-btn:hover {
        background: #667eea;
        color: white;
        transform: translateY(-2px);
    }

    /* 더보기(...) 버튼 스타일 */
    .quick-reply-more {
        background: #e8eaf6;
        border: 1px solid #c5cae9;
        color: #5c6bc0;
        font-weight: bold;
    }
    .quick-reply-more:hover {
        background: #c5cae9;
    }
    /* --- 퀵 버튼 스타일 끝 --- */

    .chat-message {
        display: flex;
        align-items: flex-start;
        gap: 10px;
        animation: fadeInUp 0.3s ease-out;
        width: 100%;
    }

    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .chat-message.bot { justify-content: flex-start; }

    .chat-message.bot .message-bubble {
        background: white;
        color: #333;
        border-radius: 0 18px 18px 18px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    }

    .chat-message.bot .chat-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .chat-message.bot .chat-avatar svg { width: 22px; height: 22px; fill: white; }

    .chat-message.user { justify-content: flex-end; }

    .chat-message.user .message-bubble {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border-radius: 18px 0 18px 18px;
        box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
    }

    .chat-message.user .chat-avatar {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: #e8eaf6;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }

    .chat-message.user .chat-avatar svg { width: 22px; height: 22px; fill: #5c6bc0; }

    .message-bubble {
        padding: 12px 16px;
        word-wrap: break-word;
        word-break: break-word;
        line-height: 1.6;
        font-size: 14px;
        max-width: 70%;
    }

    .page-nav-btn {
        margin-top: 10px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        padding: 8px 16px;
        border-radius: 15px;
        cursor: pointer;
        font-size: 13px;
        font-weight: 500;
        transition: all 0.2s;
        display: block;
        width: 100%;
        text-align: center;
    }

    .page-nav-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
    }

    .typing-indicator {
        display: none;
        padding: 12px 16px;
        background: white;
        border-radius: 18px;
        width: fit-content;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        margin-left: 50px;
    }

    .typing-indicator.active { display: flex; gap: 4px; }

    .typing-dot {
        width: 8px; height: 8px; background: #667eea; border-radius: 50%;
        animation: typing 1.4s infinite;
    }
    .typing-dot:nth-child(2) { animation-delay: 0.2s; }
    .typing-dot:nth-child(3) { animation-delay: 0.4s; }

    @keyframes typing {
        0%, 60%, 100% { transform: translateY(0); opacity: 0.4; }
        30% { transform: translateY(-10px); opacity: 1; }
    }

    .chatbot-footer {
        padding: 15px 20px;
        background: white;
        border-top: 1px solid #e0e0e0;
        display: flex;
        gap: 10px;
        flex-shrink: 0;
    }

    .chatbot-input {
        flex: 1;
        padding: 12px 16px;
        border: 2px solid #e0e0e0;
        border-radius: 25px;
        outline: none;
        font-size: 14px;
        transition: border-color 0.3s;
    }
    .chatbot-input:focus { border-color: #667eea; }

    .chatbot-send, .voice-btn {
        width: 45px; height: 45px; border-radius: 50%; border: none; cursor: pointer;
        display: flex; align-items: center; justify-content: center;
        transition: transform 0.2s; flex-shrink: 0;
    }

    .chatbot-send { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
    .chatbot-send:hover:not(:disabled) { transform: scale(1.1); }
    .chatbot-send:disabled { opacity: 0.5; cursor: not-allowed; }
    .chatbot-send svg { width: 20px; height: 20px; fill: white; }

    .voice-btn { background: #f0f0f0; }
    .voice-btn.listening { background: #ff4444; animation: pulse 1s infinite; }
    .voice-btn svg { width: 20px; height: 20px; fill: #667eea; }
    .voice-btn.listening svg { fill: white; }

    @keyframes pulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.1); }
    }

    .chatbot-body::-webkit-scrollbar { width: 6px; }
    .chatbot-body::-webkit-scrollbar-track { background: #f1f1f1; }
    .chatbot-body::-webkit-scrollbar-thumb { background: #667eea; border-radius: 3px; }

    @media (max-width: 768px) {
        .chatbot-modal { width: calc(100vw - 20px); height: calc(100vh - 100px); right: 10px; bottom: 10px; }
        .chatbot-button { width: 60px; height: 60px; bottom: 20px; right: 20px; }
        .message-bubble { max-width: 80%; }
    }
</style>

<button class="chatbot-button" onclick="toggleChatbot()">
    <svg viewBox="0 0 24 24">
        <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-3 12H7c-.55 0-1-.45-1-1s.45-1 1-1h10c.55 0 1 .45 1 1s-.45 1-1 1zm0-3H7c-.55 0-1-.45-1-1s.45-1 1-1h10c.55 0 1 .45 1 1s-.45 1-1 1zm0-3H7c-.55 0-1-.45-1-1s.45-1 1-1h10c.55 0 1 .45 1 1s-.45 1-1 1z"/>
    </svg>
</button>

<div class="chatbot-modal" id="chatbotModal">
    <div class="chatbot-header">
        <h3 id="chatTitle">🏥 AI 의료 안내</h3>
        <div class="chatbot-header-controls">
            <div class="lang-dropdown-container">
                <button onclick="toggleLangDropdown()" class="lang-dropdown-btn" id="currentLangBtn">
                    한국어 ▼
                </button>
                <div id="langDropdown" class="lang-dropdown-content">
                    <button class="lang-opt active" data-lang="ko" onclick="changeLang('ko')">한국어</button>
                    <button class="lang-opt" data-lang="en" onclick="changeLang('en')">English</button>
                    <button class="lang-opt" data-lang="zh" onclick="changeLang('zh')">中文</button>
                    <button class="lang-opt" data-lang="ja" onclick="changeLang('ja')">日本語</button>
                </div>
            </div>

            <button class="chatbot-close" onclick="toggleChatbot()">×</button>
        </div>
    </div>

    <div class="chatbot-body" id="chatBody">
        <div class="chat-message bot">
            <div class="chat-avatar">
                <svg viewBox="0 0 24 24">
                    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z"/>
                </svg>
            </div>
            <div class="message-bubble" id="welcomeMessage">
                안녕하세요! 😊<br>
                원하시는 페이지를 말씀해주세요.
            </div>
        </div>

        <div class="typing-indicator" id="typingIndicator">
            <div class="typing-dot"></div>
            <div class="typing-dot"></div>
            <div class="typing-dot"></div>
        </div>
    </div>

    <div class="quick-replies-container" id="quickReplies">
    </div>

    <div class="chatbot-footer">
        <button class="voice-btn" id="voiceBtn" onclick="toggleVoiceInput()">
            <svg viewBox="0 0 24 24">
                <path d="M12 14c1.66 0 3-1.34 3-3V5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3z"/>
                <path d="M17 11c0 2.76-2.24 5-5 5s-5-2.24-5-5H5c0 3.53 2.61 6.43 6 6.92V21h2v-3.08c3.39-.49 6-3.39 6-6.92h-2z"/>
            </svg>
        </button>
        <input type="text" class="chatbot-input" id="chatInput" placeholder="메시지를 입력하세요..." onkeypress="handleChatKeyPress(event)">
        <button class="chatbot-send" onclick="sendChatMessage()" id="sendBtn">
            <svg viewBox="0 0 24 24">
                <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
            </svg>
        </button>
    </div>
</div>

<script>
    let recognition = null;
    let isListening = false;
    let currentLanguage = 'ko';
    let lastRecommendedPage = null;

    // [추가됨] 퀵 메뉴 확장 여부 상태 변수
    let isQuickMenuExpanded = false;

    const translations = {
        ko: {
            title: '🏥 AI 의료 안내',
            placeholder: '병원, 진단, 상담 등을 물어보세요...',
            welcome: '안녕하세요! 😊<br>원하시는 페이지를 말씀해주세요.',
            navButton: '📍 해당 페이지로 이동',
            error: '죄송합니다. 오류가 발생했습니다.',
            serverError: '서버 연결에 실패했습니다.',
            autoNavigating: '페이지로 이동합니다...',
            langName: '한국어'
        },
        en: {
            title: '🏥 AI Medical Guide',
            placeholder: 'Ask about hospitals, diagnosis, consultation...',
            welcome: 'Hello! 😊<br>Please tell me which page you need.',
            navButton: '📍 Go to Page',
            error: 'Sorry, an error occurred.',
            serverError: 'Failed to connect to server.',
            autoNavigating: 'Navigating to page...',
            langName: 'English'
        },
        zh: {
            title: '🏥 AI医疗指南',
            placeholder: '询问医院、诊断、咨询等...',
            welcome: '您好！😊<br>请告诉我您需要哪个页面。',
            navButton: '📍 前往页面',
            error: '抱歉，发生了错误。',
            serverError: '服务器连接失败。',
            autoNavigating: '正在前往页面...',
            langName: '中文'
        },
        ja: {
            title: '🏥 AI医療ガイド',
            placeholder: '病院、診断、相談などをお尋ねください...',
            welcome: 'こんにちは！😊<br>ご希望のページをお伝えください。',
            navButton: '📍 ページへ移動',
            error: '申し訳ございません。エラーが発生しました。',
            serverError: 'サーバーへの接続に失敗しました。',
            autoNavigating: 'ページに移動中...',
            langName: '日本語'
        }
    };

    const quickQuestions = {
        ko: ['병원 찾고 싶어', '자가진단 하고 싶어', '통계 보고싶어', '로그인 하고 싶어', '상담하고 싶어', '문의하고 싶어'],
        en: ['Find Hospital', 'Self Diagnosis', 'View Statistics', 'Login', 'Consultation', 'General Inquiry'],
        zh: ['寻找医院', '自我诊断', '查看统计', '登录', '医疗咨询', '一般咨询'],
        ja: ['病院を探したい', 'セルフ診断', '統計を見たい', 'ログイン', '医療相談', 'お問い合わせ']
    };

    const langCodes = {
        ko: 'ko-KR',
        en: 'en-US',
        zh: 'zh-CN',
        ja: 'ja-JP'
    };

    const navigationKeywords = {
        ko: ['이동', '가자', '가줘', '갈게', '보여줘', '가고 싶어', '페이지로', '해당 페이지'],
        en: ['go', 'take me', 'navigate', 'show me', 'go to', 'move to'],
        zh: ['前往', '去', '移动', '显示', '进入'],
        ja: ['移動', '行く', '見せて', 'ページへ', '行きたい']
    };

    // [추가됨] 음성 중단 공통 함수
    function stopSpeech() {
        if ('speechSynthesis' in window && window.speechSynthesis.speaking) {
            window.speechSynthesis.cancel();
        }
    }

    function toggleLangDropdown() {
        stopSpeech(); // 드롭다운 열 때 음성 중단
        document.getElementById("langDropdown").classList.toggle("show");
    }

    window.onclick = function(event) {
        if (!event.target.matches('.lang-dropdown-btn')) {
            var dropdowns = document.getElementsByClassName("lang-dropdown-content");
            for (var i = 0; i < dropdowns.length; i++) {
                var openDropdown = dropdowns[i];
                if (openDropdown.classList.contains('show')) {
                    openDropdown.classList.remove('show');
                }
            }
        }
    }

    function changeLang(lang) {
        stopSpeech(); // 언어 변경 시 음성 중단
        currentLanguage = lang;

        document.getElementById('currentLangBtn').innerText = translations[lang].langName + ' ▼';

        document.querySelectorAll('.lang-opt').forEach(btn => {
            if(btn.dataset.lang === lang) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });

        document.getElementById('chatTitle').textContent = translations[lang].title;
        document.getElementById('chatInput').placeholder = translations[lang].placeholder;

        const welcomeMsg = document.getElementById('welcomeMessage');
        if(welcomeMsg) {
            welcomeMsg.innerHTML = translations[lang].welcome;
        }

        // 언어 변경 시 퀵 메뉴도 다시 렌더링
        renderQuickReplies();

        if (recognition) {
            recognition.lang = langCodes[lang];
        }

        document.getElementById("langDropdown").classList.remove("show");
    }

    // [수정됨] 퀵 버튼 렌더링 로직 (더보기 기능 추가)
    function renderQuickReplies() {
        const container = document.getElementById('quickReplies');
        container.innerHTML = '';

        const questions = quickQuestions[currentLanguage] || quickQuestions['ko'];

        // 처음 보여줄 개수 (예: 3개)
        const visibleCount = 3;

        // 확장 상태가 아니면 3개만, 확장이면 전체 다 보여줌
        const itemsToShow = isQuickMenuExpanded ? questions : questions.slice(0, visibleCount);

        // 1. 질문 버튼들 생성
        itemsToShow.forEach(q => {
            const btn = document.createElement('button');
            btn.className = 'quick-reply-btn';
            btn.textContent = q;
            btn.onclick = function() {
                stopSpeech(); // 퀵 버튼 클릭 시 음성 중단
                document.getElementById('chatInput').value = q;
                sendChatMessage();
            };
            container.appendChild(btn);
        });

        // 2. 항목이 visibleCount보다 많을 경우 '더보기' 혹은 '접기' 버튼 추가
        if (questions.length > visibleCount) {
            const toggleBtn = document.createElement('button');
            toggleBtn.className = 'quick-reply-btn quick-reply-more';

            // 확장 상태에 따라 아이콘/텍스트 변경
            toggleBtn.textContent = isQuickMenuExpanded ? '▲ 접기' : '...';

            toggleBtn.onclick = function() {
                stopSpeech(); // 더보기/접기 버튼 클릭 시 음성 중단
                isQuickMenuExpanded = !isQuickMenuExpanded; // 상태 토글

                // 컨테이너 클래스 토글 (CSS 줄바꿈 적용)
                if(isQuickMenuExpanded) {
                    container.classList.add('expanded');
                } else {
                    container.classList.remove('expanded');
                    container.scrollTop = 0; // 접을 때 스크롤 위로
                }

                renderQuickReplies(); // 버튼 다시 그리기
            };
            container.appendChild(toggleBtn);
        }
    }

    function initSpeechRecognition() {
        if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
            const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
            recognition = new SpeechRecognition();
            recognition.lang = langCodes[currentLanguage];
            recognition.continuous = false;
            recognition.interimResults = false;

            recognition.onstart = function() {
                isListening = true;
                document.getElementById('voiceBtn').classList.add('listening');
            };

            recognition.onresult = function(event) {
                // 음성 인식 결과가 나오면 이전 TTS 중단
                stopSpeech();
                
                const transcript = event.results[0][0].transcript;
                document.getElementById('chatInput').value = transcript;
                setTimeout(() => sendChatMessage(), 500);
            };

            recognition.onerror = function(event) {
                console.error('음성 인식 오류:', event.error);
                isListening = false;
                document.getElementById('voiceBtn').classList.remove('listening');
            };

            recognition.onend = function() {
                isListening = false;
                document.getElementById('voiceBtn').classList.remove('listening');
            };
        }
    }

    function toggleVoiceInput() {
        if (!recognition) {
            alert('음성 인식을 지원하지 않는 브라우저입니다.');
            return;
        }
        
        // 음성 입력 시작할 때 이전 TTS 중단
        if (!isListening) {
            stopSpeech();
        }
        
        if (isListening) {
            recognition.stop();
        } else {
            recognition.start();
        }
    }

    function speakText(text) {
        if ('speechSynthesis' in window) {
            // 이전 음성이 재생 중이면 중단
            stopSpeech();
            
            const utterance = new SpeechSynthesisUtterance(text);
            utterance.lang = langCodes[currentLanguage];
            utterance.rate = 1.0;
            window.speechSynthesis.speak(utterance);
        }
    }

    function toggleChatbot() {
        stopSpeech(); // 챗봇 열기/닫기 시 음성 중단
        const modal = document.getElementById('chatbotModal');
        modal.classList.toggle('active');
        if(modal.classList.contains('active')) {
            setTimeout(() => document.getElementById('chatInput').focus(), 300);
            renderQuickReplies();
        }
    }

    function handleChatKeyPress(event) {
        if(event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            sendChatMessage();
        }
    }

    function isNavigationRequest(question) {
        const keywords = navigationKeywords[currentLanguage] || navigationKeywords['ko'];
        const lowerQuestion = question.toLowerCase();
        return keywords.some(keyword => lowerQuestion.includes(keyword.toLowerCase()));
    }

    async function sendChatMessage() {
        const input = document.getElementById('chatInput');
        const sendBtn = document.getElementById('sendBtn');
        const question = input.value.trim();

        if(!question) return;

        // 새로운 질문이 들어오면 이전 음성 즉시 중단
        stopSpeech();

        if (isNavigationRequest(question) && lastRecommendedPage) {
            addChatBubble(question, 'user');
            input.value = '';
            addChatBubble(translations[currentLanguage].autoNavigating, 'bot');
            speakText(translations[currentLanguage].autoNavigating);
            setTimeout(() => window.location.href = lastRecommendedPage, 1000);
            return;
        }

        addChatBubble(question, 'user');
        input.value = '';
        sendBtn.disabled = true;
        showChatTyping();

        try {
            const response = await fetch('/api/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    question: question,
                    language: currentLanguage
                })
            });

            const data = await response.json();
            hideChatTyping();

            if(data.status === 'success') {
                if(data.page && data.page !== '' && data.page.toUpperCase() !== 'NONE') {
                    lastRecommendedPage = data.page;
                }
                addChatBubble(data.answer, 'bot', data.page);
                speakText(data.answer);
            } else {
                addChatBubble(translations[currentLanguage].error, 'bot');
            }
        } catch(error) {
            console.error('Error:', error);
            hideChatTyping();
            addChatBubble(translations[currentLanguage].serverError, 'bot');
        } finally {
            sendBtn.disabled = false;
            input.focus();
        }
    }

    function addChatBubble(text, type, page = null) {
        const chatBody = document.getElementById('chatBody');
        const typingIndicator = document.getElementById('typingIndicator');

        const messageDiv = document.createElement('div');
        messageDiv.className = 'chat-message ' + type;

        const avatarDiv = document.createElement('div');
        avatarDiv.className = 'chat-avatar';

        if(type === 'bot') {
            avatarDiv.innerHTML = '<svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z"/></svg>';
        } else {
            avatarDiv.innerHTML = '<svg viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>';
        }

        const bubbleDiv = document.createElement('div');
        bubbleDiv.className = 'message-bubble';
        bubbleDiv.innerHTML = text.split('\n').map(line => line.trim()).filter(line => line).join('<br>');

        if(page && page !== '' && page.toUpperCase() !== 'NONE') {
            const navBtn = document.createElement('button');
            navBtn.className = 'page-nav-btn';
            navBtn.textContent = translations[currentLanguage].navButton;
            navBtn.onclick = function() { 
                stopSpeech(); // 페이지 이동 버튼 클릭 시 음성 중단
                window.location.href = page; 
            };
            bubbleDiv.appendChild(navBtn);
        }

        messageDiv.appendChild(avatarDiv);
        messageDiv.appendChild(bubbleDiv);
        chatBody.insertBefore(messageDiv, typingIndicator);

        setTimeout(() => chatBody.scrollTop = chatBody.scrollHeight, 100);
    }

    function showChatTyping() {
        const indicator = document.getElementById('typingIndicator');
        indicator.classList.add('active');
        setTimeout(() => document.getElementById('chatBody').scrollTop = document.getElementById('chatBody').scrollHeight, 100);
    }

    function hideChatTyping() {
        document.getElementById('typingIndicator').classList.remove('active');
    }

    document.addEventListener('DOMContentLoaded', () => {
        initSpeechRecognition();
        renderQuickReplies();
    });
</script>