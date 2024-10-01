<%@page import="java.util.HashMap"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // 세션 초기화: 페이지 로드 시 주문 내역 초기화
    session.invalidate(); // 기존 세션을 무효화하여 모든 데이터 초기화
    session = request.getSession(true); // 새로운 세션 생성

    // 새 세션을 위한 설정
    session.setMaxInactiveInterval(10 * 60); // 10분
    session.setAttribute("selectedCofnums", new HashMap<String, Integer>());
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>메인페이지(처음 나타나는 화면)</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            text-align: center;
        }
        html {
            width: 100%;
            height: 100%;
            background-color: #f4f4f4; /* 전체 배경 색상 */
        }
        .main {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            width: 800px; /* 고정 너비 */
            height: 96vh; /* 뷰포트 높이의 96% */
            border: 1px solid black; /* 테두리 설정 */
            margin: 2vh auto; /* 상단과 하단 여백을 주고 가운데 정렬 */
            position: relative;
            overflow: hidden; /* 넘치는 내용 숨기기 */
            cursor: pointer; /* 마우스 커서 변경 */
        }
        .background {
            position: absolute; /* 배경 이미지를 절대 위치로 설정 */
            top: 0;
            left: 0;
            width: 100%; /* 전체 너비 */
            height: 100%; /* 전체 높이 */
            opacity: 0; /* 초기 상태에서 투명 */
            transition: opacity 1s ease-in-out; /* 페이드 전환 효과 설정 */
        }
        .background.active {
            opacity: 1; /* active 클래스가 있을 때 불투명 */
        }
        .background img {
            width: 100%; /* 가로 전체를 채움 */
            height: 100%; /* 세로 전체를 채움 */
            object-fit: cover; /* 비율을 유지하며 요소를 완전히 채움 */
        }
        h1 {
            color: white;
            font-weight: bolder;
            text-shadow: 1px 1px #ccc;
            margin-top: 20px;
            z-index: 2; /* z-index로 텍스트를 위로 배치 */
            position: relative;
        }
        .info {
            color: white;
            margin-bottom: 20px; /* 하단 여백 */
            z-index: 2; /* z-index로 텍스트를 위로 배치 */
            position: relative;
        }
    </style>
</head>
<body>
    <div class="main" onclick="startSession();">
        <div class="background active">
            <img src="mainImage/first.jpg" alt="첫 번째 이미지">
        </div>
        <div class="background">
            <img src="mainImage/second.jpg" alt="두 번째 이미지">
        </div>
        <div class="background">
            <img src="mainImage/third.jpg" alt="세 번째 이미지">
        </div>
        <h1>Coffee</h1>
        <footer class="info">누르면 주문 화면으로 넘어갑니다.</footer>
    </div>

    <script>
        let isSessionInitializing = false; // 세션 초기화 플래그
        let currentBackground = 0; // 현재 배경 이미지 인덱스
        const backgrounds = document.querySelectorAll('.background'); // 모든 배경 이미지

        // 배경 이미지 자동 전환
        function changeBackground() {
            backgrounds[currentBackground].classList.remove('active'); // 현재 배경 이미지 숨기기
            currentBackground = (currentBackground + 1) % backgrounds.length; // 다음 이미지 인덱스
            backgrounds[currentBackground].classList.add('active'); // 다음 배경 이미지 표시
        }

        // 일정 시간마다 배경 이미지 변경
        setInterval(changeBackground, 5000); // 5초마다 이미지 변경

        function startSession() {
            // 세션 시작을 위한 AJAX 호출
            initializeSession();
        }

        function initializeSession() {
            if (isSessionInitializing) return; // 이미 초기화 중이면 종료

            isSessionInitializing = true; // 초기화 시작
            // 세션 리셋 요청 추가
            fetch('order/saveOrder.jsp') // 이 URL은 세션 초기화 스크립트로 교체 가능
                .then(response => response.json())
                .then(data => {
                    isSessionInitializing = false; // 초기화 완료
                    if (data.success) {
                        console.log("세션이 초기화되었습니다.");
                        location.href = 'order/fav.jsp'; // 주문 페이지로 이동
                    } else {
                        alert('세션 초기화에 실패했습니다.');
                    }
                })
                .catch(error => {
                    isSessionInitializing = false; // 초기화 실패
                    console.error('AJAX 오류:', error);
                });
        }
    </script>
</body>
</html>
