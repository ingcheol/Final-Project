/**
 * 다국어 지원을 위한 JavaScript
 * 포함된 기능:
 * 1. 언어 사전 (한국어, 영어, 일본어, 중국어)
 * 2. 페이지 로드 시 언어 적용
 * 3. 언어 버튼 클릭 이벤트 처리
 * 4. LocalStorage를 이용한 언어 설정 유지
 */

// 1. 번역 데이터 사전
const translations = {
    ko: {
        // 공통/네비게이션
        logo: "🏥 AI 의료 매칭 시스템",
        navHome: "홈",
        navServices: "서비스 소개",
        navDiagnosis: "자가진단",
        navHospital: "병원찾기",
        navContact: "문의하기",

        // 단계 표시 (dia1.jsp)
        step1: "증상 입력",
        step2: "설문조사",
        step3: "AI 분석",
        step4: "결과 확인",

        // 페이지 1: 증상 입력 (dia1.jsp)
        pageTitle: "증상을 입력해주세요",
        pageSubtitle: "현재 불편하신 증상을 자세히 설명해주시면 AI가 분석해드립니다",

        // AI 작동 방식 설명
        howItWorks: "AI 진단 시스템이 이렇게 작동합니다",
        step1DetailTitle: "증상 입력 및 수집",
        step1DetailDesc: "텍스트, 음성, 이미지 등 다양한 방법으로 증상을 입력하시면 AI가 모든 정보를 수집합니다. \"3일 전부터 두통과 발열\" 같은 자연스러운 문장으로 작성하셔도 됩니다.",
        step2DetailTitle: "맞춤형 설문 생성",
        step2DetailDesc: "입력하신 증상을 기반으로 AI가 추가로 필요한 정보를 파악하여 맞춤형 설문을 자동 생성합니다. 예: 두통이라면 \"통증 부위\", \"지속 시간\", \"강도\" 등을 물어봅니다.",
        step3DetailTitle: "키워드 추출 및 RAG 검색",
        step3DetailDesc: "AI가 증상에서 핵심 키워드(\"두통\", \"발열\", \"구토\" 등)를 추출하고, 이를 바탕으로 RAG(Retrieval-Augmented Generation)를 통해 방대한 의료 PDF 문서와 데이터베이스를 실시간 검색하여 관련 질병, 증상 패턴, 치료법 정보를 수집합니다.",
        step4DetailTitle: "AI 종합 분석 및 병원 추천",
        step4DetailDesc: "수집된 의료 정보와 설문 답변을 종합하여 AI가 증상을 분석하고, 가장 적합한 진료과를 추천합니다. 동시에 위치 정보를 활용하여 근처의 적절한 병원(1차/2차/3차)을 찾아드립니다.",
        processTip: "증상을 자세히 입력할수록 AI가 더 정확하게 분석할 수 있습니다. 언제부터, 어떻게, 얼마나 자주 등을 포함해주세요!",

        symptomLabel: "증상 설명 *",
        symptomPlaceholder: "예: 3일 전부터 머리가 지끈지끈 아프고 열이 38도 정도 나요. 목도 따끔거리고 기침도 조금 나옵니다.",
        voiceBtn: "🎤 음성으로 입력",
        voiceStopBtn: "⏹ 녹음 중지",
        cameraBtn: "📷 사진 추가 (선택)",
        infoTitle: "💡 입력 팁",
        infoTip1: "증상이 시작된 시기를 알려주세요 (예: 3일 전부터)",
        infoTip2: "통증의 정도나 빈도를 구체적으로 설명해주세요",
        infoTip3: "동반되는 다른 증상도 함께 말씀해주세요",
        infoTip4: "사진은 최대 5장까지 업로드 가능합니다",
        infoTip5: "약 복용 중이라면 함께 알려주세요",
        btnPrev: "← 이전으로",
        btnNext: "다음 단계 (설문조사) →",

        // 경고/알림 메시지 (Script)
        alertVoiceNotSupported: "이 브라우저는 음성 인식을 지원하지 않습니다.",
        alertMaxImages: "이미지는 최대 5장까지만 업로드할 수 있습니다.",
        alertImageLoadError: "이미지 로드 중 오류 발생: ",
        alertNoSymptom: "증상을 입력해주세요.",
        alertShortSymptom: "정확한 분석을 위해 증상을 10자 이상 입력해주세요.",
        processing: "처리 중...",

        // 페이지 2: 설문조사 (dia2.jsp)
        surveyTitle: "🩺 추가 질문",
        surveySubtitle: "증상에 대한 추가 질문에 답변해주세요",
        surveySubmit: "다음 단계 →",
        alertAnswerAll: "모든 질문에 답변해주세요.",

        // 페이지 3: 분석 중 (dia3.jsp)
        analyzingTitle: "🧠 AI 분석 진행 중",
        analyzingMessage: "증상을 분석하고 있습니다...",
        inputSymptom: "입력하신 증상:",

        // 페이지 4: 결과 (dia4.jsp)
        analysisComplete: "✅ 분석이 완료되었습니다!",
        aiResultTitle: "🔬 AI 분석 결과",
        aiResultSubtitle: "입력하신 증상을 바탕으로 분석한 결과입니다",
        inputSymptomTitle: "📋 입력하신 증상",
        uploadedImagesTitle: "📸 업로드하신 증상 사진",
        aiDiagnosisTitle: "🧠 AI 종합 진단",
        recommendationTitle: "💡 추천 사항",
        recommendedDept: "추천 진료과:",
        urgencyLevel: "진료 시급성:",
        hospitalTitle: "🏥 추천 병원",
        hospitalSubtitle: "증상에 맞는 근처 병원을 추천해드립니다",
        hospital1st: "가까운 의원 · 클리닉",
        hospital2nd: "종합병원",
        hospital3rd: "상급종합병원 · 대학병원",
        searching: "근처 병원을 검색하고 있습니다...",
        warningTitle: "⚠️ 중요 안내",
        warningMessage: "본 서비스는 AI 기반 참고 정보 제공 서비스로, 의학적 진단이나 치료를 대체할 수 없습니다. 정확한 진단과 치료를 위해서는 반드시 의료 전문가의 진료를 받으시기 바랍니다. 응급 상황이거나 증상이 급격히 악화되는 경우 즉시 119에 연락하거나 응급실을 방문하세요.",
        btnDownloadPDF: "📄 PDF 다운로드",
        btnViewMap: "🗺️ 병원 지도 보기",
        btnNewDiagnosis: "🔄 새로 진단하기",
        btnHome: "🏠 홈으로 돌아가기"
    },
    en: {
        logo: "🏥 AI Medical Matching",
        navHome: "Home",
        navServices: "Services",
        navDiagnosis: "Self-Check",
        navHospital: "Hospitals",
        navContact: "Contact",
        step1: "Symptoms",
        step2: "Survey",
        step3: "AI Analysis",
        step4: "Results",
        pageTitle: "Describe Your Symptoms",
        pageSubtitle: "Please describe your symptoms in detail for AI analysis.",

        howItWorks: "How AI Diagnosis System Works",
        step1DetailTitle: "Symptom Input & Collection",
        step1DetailDesc: "Enter your symptoms via text, voice, or images and AI will collect all information. You can write naturally like \"headache and fever since 3 days ago\".",
        step2DetailTitle: "Custom Survey Generation",
        step2DetailDesc: "Based on your symptoms, AI identifies additional needed information and automatically generates a customized survey. Example: For headaches, it asks about \"pain location\", \"duration\", \"intensity\", etc.",
        step3DetailTitle: "Keyword Extraction & RAG Search",
        step3DetailDesc: "AI extracts key keywords (\"headache\", \"fever\", \"nausea\", etc.) from your symptoms and searches vast medical PDF documents and databases in real-time through RAG (Retrieval-Augmented Generation) to collect related disease, symptom pattern, and treatment information.",
        step4DetailTitle: "AI Comprehensive Analysis & Hospital Recommendation",
        step4DetailDesc: "AI analyzes symptoms by combining collected medical information and survey responses, recommending the most suitable medical department. Simultaneously uses location data to find nearby appropriate hospitals (primary/secondary/tertiary).",
        processTip: "The more detailed your symptom description, the more accurate the AI analysis! Include when it started, how, and how often.",

        symptomLabel: "Symptom Description *",
        symptomPlaceholder: "Ex: I've had a throbbing headache and a fever of 38°C since 3 days ago. My throat is sore and I have a slight cough.",
        voiceBtn: "🎤 Voice Input",
        voiceStopBtn: "⏹ Stop Recording",
        cameraBtn: "📷 Add Photo (Optional)",
        infoTitle: "💡 Tips",
        infoTip1: "Tell us when it started (e.g., 3 days ago)",
        infoTip2: "Describe pain level and frequency",
        infoTip3: "Mention any other accompanying symptoms",
        infoTip4: "Up to 5 photos allowed",
        infoTip5: "Let us know if you are taking medication",
        btnPrev: "← Previous",
        btnNext: "Next (Survey) →",
        alertVoiceNotSupported: "Voice recognition is not supported in this browser.",
        alertMaxImages: "You can upload up to 5 images.",
        alertImageLoadError: "Error loading image: ",
        alertNoSymptom: "Please enter your symptoms.",
        alertShortSymptom: "Please enter at least 10 characters.",
        processing: "Processing...",
        surveyTitle: "🩺 Additional Questions",
        surveySubtitle: "Please answer a few more questions regarding your symptoms.",
        surveySubmit: "Next Step →",
        alertAnswerAll: "Please answer all questions.",
        analyzingTitle: "🧠 Analyzing...",
        analyzingMessage: "AI is analyzing your symptoms...",
        inputSymptom: "Your Symptoms:",
        analysisComplete: "✅ Analysis Complete!",
        aiResultTitle: "🔬 AI Analysis Result",
        aiResultSubtitle: "Here is the result based on your input.",
        inputSymptomTitle: "📋 Your Input",
        uploadedImagesTitle: "📸 Uploaded Photos",
        aiDiagnosisTitle: "🧠 AI Diagnosis",
        recommendationTitle: "💡 Recommendations",
        recommendedDept: "Department:",
        urgencyLevel: "Urgency:",
        hospitalTitle: "🏥 Recommended Hospitals",
        hospitalSubtitle: "Finding hospitals near you suitable for your symptoms.",
        hospital1st: "Local Clinics (Primary)",
        hospital2nd: "General Hospitals (Secondary)",
        hospital3rd: "University Hospitals (Tertiary)",
        searching: "Searching for nearby hospitals...",
        warningTitle: "⚠️ Important Notice",
        warningMessage: "This service is an AI-based reference and does not replace professional medical diagnosis or treatment. Please consult a medical professional for accurate diagnosis. In emergencies, contact emergency services immediately.",
        btnDownloadPDF: "📄 Download PDF",
        btnViewMap: "🗺️ View Map",
        btnNewDiagnosis: "🔄 New Diagnosis",
        btnHome: "🏠 Go Home"
    },
    ja: {
        logo: "🏥 AI 医療マッチング",
        navHome: "ホーム",
        navServices: "サービス",
        navDiagnosis: "自己診断",
        navHospital: "病院検索",
        navContact: "お問い合わせ",
        step1: "症状入力",
        step2: "問診",
        step3: "AI分析",
        step4: "結果確認",
        pageTitle: "症状を入力してください",
        pageSubtitle: "不快な症状を詳しく説明してください。AIが分析します。",

        howItWorks: "AI診断システムの動作方法",
        step1DetailTitle: "症状入力・収集",
        step1DetailDesc: "テキスト、音声、画像など様々な方法で症状を入力すると、AIがすべての情報を収集します。「3日前から頭痛と発熱」のような自然な文章で書いても大丈夫です。",
        step2DetailTitle: "カスタムアンケート生成",
        step2DetailDesc: "入力された症状に基づいてAIが追加で必要な情報を把握し、カスタムアンケートを自動生成します。例：頭痛なら「痛みの部位」「持続時間」「強度」などを尋ねます。",
        step3DetailTitle: "キーワード抽出・RAG検索",
        step3DetailDesc: "AIが症状から主要キーワード（「頭痛」「発熱」「嘔吐」など）を抽出し、これを基にRAG(Retrieval-Augmented Generation)を通じて膨大な医療PDF文書とデータベースをリアルタイム検索して関連疾患、症状パターン、治療法情報を収集します。",
        step4DetailTitle: "AI総合分析・病院推薦",
        step4DetailDesc: "収集された医療情報とアンケート回答を総合してAIが症状を分析し、最も適切な診療科を推薦します。同時に位置情報を活用して近くの適切な病院（1次/2次/3次）を探します。",
        processTip: "症状を詳しく入力するほど、AIがより正確に分析できます。いつから、どのように、どのくらいの頻度かなどを含めてください！",

        symptomLabel: "症状の説明 *",
        symptomPlaceholder: "例：3日前から頭がズキズキ痛く、38度の熱があります。喉も痛く、咳も少し出ます。",
        voiceBtn: "🎤 音声入力",
        voiceStopBtn: "⏹ 録音停止",
        cameraBtn: "📷 写真追加 (任意)",
        infoTitle: "💡 入力のヒント",
        infoTip1: "いつから始まったか教えてください (例: 3日前から)",
        infoTip2: "痛みの程度や頻度を具体的に説明してください",
        infoTip3: "他の症状があれば一緒に教えてください",
        infoTip4: "写真は最大5枚までアップロード可能です",
        infoTip5: "服用中の薬があれば教えてください",
        btnPrev: "← 戻る",
        btnNext: "次へ (問診) →",
        alertVoiceNotSupported: "このブラウザは音声認識をサポートしていません。",
        alertMaxImages: "画像は最大5枚までアップロードできます。",
        alertImageLoadError: "画像の読み込みエラー: ",
        alertNoSymptom: "症状を入力してください。",
        alertShortSymptom: "正確な分析のため、10文字以上入力してください。",
        processing: "処理中...",
        surveyTitle: "🩺 追加質問",
        surveySubtitle: "症状に関する追加の質問にお答えください。",
        surveySubmit: "次へ進む →",
        alertAnswerAll: "すべての質問にお答えください。",
        analyzingTitle: "🧠 AI分析中",
        analyzingMessage: "症状を分析しています...",
        inputSymptom: "入力された症状:",
        analysisComplete: "✅ 分析完了!",
        aiResultTitle: "🔬 AI分析結果",
        aiResultSubtitle: "入力された症状に基づく分析結果です。",
        inputSymptomTitle: "📋 入力内容",
        uploadedImagesTitle: "📸 アップロード写真",
        aiDiagnosisTitle: "🧠 AI総合診断",
        recommendationTitle: "💡 推奨事項",
        recommendedDept: "推奨診療科:",
        urgencyLevel: "緊急度:",
        hospitalTitle: "🏥 推奨病院",
        hospitalSubtitle: "症状に適した近くの病院を推奨します。",
        hospital1st: "近くの医院・クリニック",
        hospital2nd: "総合病院",
        hospital3rd: "大学病院・専門病院",
        searching: "近くの病院を検索しています...",
        warningTitle: "⚠️ 重要なお知らせ",
        warningMessage: "本サービスはAIに基づく参考情報の提供であり、医学的な診断や治療に代わるものではありません。正確な診断と治療については、必ず医療専門家の診療を受けてください。緊急時や症状が急激に悪化する場合は、直ちに救急車を呼ぶか救急外来を受診してください。",
        btnDownloadPDF: "📄 PDFダウンロード",
        btnViewMap: "🗺️ 地図を見る",
        btnNewDiagnosis: "🔄 最初からやり直す",
        btnHome: "🏠 ホームへ"
    },
    zh: {
        logo: "🏥 AI 医疗匹配系统",
        navHome: "首页",
        navServices: "服务介绍",
        navDiagnosis: "自我诊断",
        navHospital: "查找医院",
        navContact: "联系我们",
        step1: "输入症状",
        step2: "问卷调查",
        step3: "AI 分析",
        step4: "确认结果",
        pageTitle: "请输入您的症状",
        pageSubtitle: "请详细描述您的不适症状，AI 将为您分析。",

        howItWorks: "AI诊断系统运作方式",
        step1DetailTitle: "症状输入与收集",
        step1DetailDesc: "通过文字、语音、图片等多种方式输入症状，AI会收集所有信息。可以用\"3天前开始头痛和发烧\"这样的自然语句描述。",
        step2DetailTitle: "定制问卷生成",
        step2DetailDesc: "基于您输入的症状，AI会识别需要的额外信息并自动生成定制问卷。例如：如果是头痛，会询问\"疼痛部位\"、\"持续时间\"、\"强度\"等。",
        step3DetailTitle: "关键词提取与RAG搜索",
        step3DetailDesc: "AI从症状中提取关键词（\"头痛\"、\"发烧\"、\"呕吐\"等），并基于此通过RAG(Retrieval-Augmented Generation)实时搜索庞大的医疗PDF文档和数据库，收集相关疾病、症状模式、治疗方法信息。",
        step4DetailTitle: "AI综合分析与医院推荐",
        step4DetailDesc: "综合收集的医疗信息和问卷回答，AI分析症状并推荐最合适的科室。同时利用位置信息查找附近适合的医院（一级/二级/三级）。",
        processTip: "症状描述越详细，AI分析就越准确！请包含何时开始、如何发生、频率等信息。",

        symptomLabel: "症状描述 *",
        symptomPlaceholder: "例如：从3天前开始头痛，发烧38度左右。喉咙痛，还有一点咳嗽。",
        voiceBtn: "🎤 语音输入",
        voiceStopBtn: "⏹ 停止录音",
        cameraBtn: "📷 添加照片 (可选)",
        infoTitle: "💡 输入提示",
        infoTip1: "请告知症状开始的时间 (如：3天前)",
        infoTip2: "请具体描述疼痛程度或频率",
        infoTip3: "请一并说明伴随的其他症状",
        infoTip4: "最多可上传 5 张照片",
        infoTip5: "如有正在服用的药物，请一并告知",
        btnPrev: "← 上一步",
        btnNext: "下一步 (问卷) →",
        alertVoiceNotSupported: "此浏览器不支持语音识别。",
        alertMaxImages: "最多只能上传 5 张图片。",
        alertImageLoadError: "加载图片时出错: ",
        alertNoSymptom: "请输入症状。",
        alertShortSymptom: "为了准确分析，请输入 10 个字以上。",
        processing: "处理中...",
        surveyTitle: "🩺 附加问题",
        surveySubtitle: "请回答关于症状的附加问题。",
        surveySubmit: "下一步 →",
        alertAnswerAll: "请回答所有问题。",
        analyzingTitle: "🧠 AI 分析中",
        analyzingMessage: "正在分析您的症状...",
        inputSymptom: "输入的症状:",
        analysisComplete: "✅ 分析完成!",
        aiResultTitle: "🔬 AI 分析结果",
        aiResultSubtitle: "这是基于您输入症状的分析结果。",
        inputSymptomTitle: "📋 输入内容",
        uploadedImagesTitle: "📸 上传的照片",
        aiDiagnosisTitle: "🧠 AI 综合诊断",
        recommendationTitle: "💡 建议事项",
        recommendedDept: "推荐科室:",
        urgencyLevel: "紧急程度:",
        hospitalTitle: "🏥 推荐医院",
        hospitalSubtitle: "为您推荐适合症状的附近医院。",
        hospital1st: "附近诊所",
        hospital2nd: "综合医院",
        hospital3rd: "大学医院",
        searching: "正在搜索附近医院...",
        warningTitle: "⚠️ 重要提示",
        warningMessage: "本服务仅提供基于 AI 的参考信息，不能替代医学诊断或治疗。为了准确的诊断和治疗，请务必咨询医疗专家。如遇紧急情况或症状急剧恶化，请立即联系急救中心或前往急诊室。",
        btnDownloadPDF: "📄 下载 PDF",
        btnViewMap: "🗺️ 查看地图",
        btnNewDiagnosis: "🔄 重新诊断",
        btnHome: "🏠 返回首页"
    }
};

// 2. 현재 언어 상태 관리 (LocalStorage 사용)
// 저장된 언어가 없으면 기본값 'ko'
let currentLang = localStorage.getItem('selectedLang') || 'ko';

// 3. 번역 헬퍼 함수 (스크립트에서 사용: t('key'))
function t(key) {
    if (translations[currentLang] && translations[currentLang][key]) {
        return translations[currentLang][key];
    }
    // 해당 언어에 키가 없으면 한국어로 대체, 한국어도 없으면 키 반환
    return (translations['ko'] && translations['ko'][key]) ? translations['ko'][key] : key;
}

// 4. 화면 텍스트 업데이트 함수
function updateContent() {
    // data-i18n 속성을 가진 모든 요소 찾기
    const elements = document.querySelectorAll('[data-i18n]');

    elements.forEach(element => {
        const key = element.getAttribute('data-i18n');
        const text = t(key);

        // input이나 textarea의 경우 placeholder 속성을 변경
        if (element.tagName === 'INPUT' || element.tagName === 'TEXTAREA') {
            element.placeholder = text;
        } else {
            // 일반 태그는 텍스트 내용 변경
            element.textContent = text;
        }
    });

    // dia1.jsp의 hidden input 값 업데이트 (폼 전송용)
    const langInput = document.getElementById('languageInput');
    if (langInput) {
        langInput.value = currentLang;
    }

    // 버튼 활성화 상태 업데이트
    document.querySelectorAll('.lang-btn').forEach(btn => {
        if (btn.getAttribute('data-lang') === currentLang) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });

    // HTML lang 속성 변경
    document.documentElement.lang = currentLang;
}

// 5. 언어 변경 함수
function changeLanguage(lang) {
    if (!translations[lang]) return;

    currentLang = lang;
    localStorage.setItem('selectedLang', lang); // 설정 저장
    updateContent();

    console.log(`🌐 Language changed to: ${lang}`);
}

// 6. 초기화 및 이벤트 리스너 등록
document.addEventListener('DOMContentLoaded', () => {
    // 초기 언어 적용
    updateContent();

    // 언어 버튼 클릭 이벤트 바인딩
    const langButtons = document.querySelectorAll('.lang-btn');
    langButtons.forEach(btn => {
        btn.addEventListener('click', (e) => {
            // 버튼이 form 안에 있을 경우 submit 방지
            e.preventDefault();
            const lang = btn.getAttribute('data-lang');
            changeLanguage(lang);
        });
    });
});