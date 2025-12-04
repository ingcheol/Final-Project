<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>DB 연결 테스트</title>
    <style>
        body {
            font-family: 'Noto Sans KR', sans-serif;
            padding: 40px;
            background: #f5f7fa;
        }
        h1 { color: #5B6FB5; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background: white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background: #5B6FB5;
            color: white;
        }
        tr:hover {
            background: #f5f5f5;
        }
    </style>
</head>
<body>
<h1>🎉 PostgreSQL 연결 성공!</h1>
<p>의료 문서 목록 (총 ${documents.size()}개)</p>

<table>
    <thead>
    <tr>
        <th>ID</th>
        <th>파일명</th>
        <th>제목</th>
        <th>크기</th>
        <th>등록일</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach var="doc" items="${documents}">
        <tr>
            <td>${doc.docId}</td>
            <td>${doc.fileName}</td>
            <td>${doc.docTitle}</td>
            <td>${doc.fileSize}</td>
            <td>${doc.createdAt}</td>
        </tr>
    </c:forEach>
    </tbody>
</table>

<br>
<a href="/dia/dia1" style="color: #5B6FB5; text-decoration: none;">← 자가진단 페이지로 돌아가기</a>
</body>
</html>
```

---

## ✅ 최종 구조:
```
edu/sm/
├── Controller/
│   ├── DiagnosisController.java (수정)
│   └── MapController.java
├── entity/
│   └── MedicalDocument.java ✅
├── repository/
│   └── MedicalDocumentRepository.java (생성)
└── service/
└── MedicalDocumentService.java (생성)

webapp/views/dia/
├── dia1.jsp
└── test.jsp (생성)