	<%@page import="java.util.HashMap"%>
	<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<%
	    // 세션 초기화
	    if (session.getAttribute("selectedCofnums") == null) {
	        session.setMaxInactiveInterval(10 * 60); // 10분
	        session.setAttribute("selectedCofnums", new HashMap<String, Integer>());
	    }
	
	    int maxInactiveInterval = session.getMaxInactiveInterval(); // 최대 비활성화 간격 (초 단위)
	    long sessionCreationTime = session.getCreationTime(); // 세션 생성 시간
	    long currentTime = System.currentTimeMillis(); // 현재 시간
	
	    // 세션이 생성된 이후 경과한 시간
	    long elapsedTime = (currentTime - sessionCreationTime) / 1000; // 초 단위
	
	    // 남은 시간 계산
	    int remainingTime = maxInactiveInterval - (int) elapsedTime;
	    if (remainingTime < 0) {
	        remainingTime = 0; // 남은 시간이 음수라면 0으로 설정
	    }
	%>
	
	<div id="sessionTimer">
	    <span id="timerDisplay"></span>
	</div>
	
	<script>
    let remainingTime = <%= remainingTime %>; // 세션의 남은 시간 (초 단위)
    let timerInterval; // 타이머 인터벌 저장 변수

    function updateTimer() {
        if (remainingTime <= 0) {
            document.getElementById("timerDisplay").innerText = "세션이 만료되었습니다.";
            clearInterval(timerInterval);
            alert("주문시간이 만료되었습니다.");
            window.location.href = "../index.jsp"; // index 페이지로 리다이렉트
            return;
        }

        const minutes = Math.floor(remainingTime / 60);
        const seconds = Math.floor(remainingTime % 60);

        // 두 자리 수로 표시
        const formattedMinutes = String(minutes).padStart(2, '0');
        const formattedSeconds = String(seconds).padStart(2, '0');

        // DOM 업데이트
        document.getElementById("timerDisplay").innerText = formattedMinutes + ":" + formattedSeconds;
        remainingTime -= 0.1; // 0.1초 감소
    }

    // DOMContentLoaded에서 timerInterval 설정
    document.addEventListener('DOMContentLoaded', function() {
        updateTimer(); // 초기 타이머 값을 설정
        timerInterval = setInterval(updateTimer, 100); // 0.1초마다 업데이트
    });
</script>

