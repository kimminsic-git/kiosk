<%@page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%
    // 세션 초기화: 항상 새 세션을 생성
    session.invalidate(); // 기존 세션을 무효화
    session = request.getSession(true); // 새로운 세션 생성
    session.setMaxInactiveInterval(10 * 60); // 10분

    // 새 세션에 selectedCofnums 초기화
    Map<String, Integer> selectedCofnums = new HashMap<String, Integer>();
    session.setAttribute("selectedCofnums", selectedCofnums);

    // 요청에서 cofnums 파라미터 가져오기
    String cofnumsParam = request.getParameter("cofnums");

    // JSON 문자열 파싱
    if (cofnumsParam != null) {
        String[] entries = cofnumsParam.replace("{", "").replace("}", "").split(",");
        for (String entry : entries) {
            String[] keyValue = entry.split(":");
            if (keyValue.length == 2) {
                String cofnum = keyValue[0].replace("\"", "").trim();
                int quantity = Integer.parseInt(keyValue[1].trim());
                if (quantity > 0) {
                    selectedCofnums.put(cofnum, quantity);
                } else {
                    selectedCofnums.remove(cofnum);
                }
            }
        }
    }

    // 세션에 저장 (업데이트된 selectedCofnums)
    session.setAttribute("selectedCofnums", selectedCofnums);

    // JSON 응답 생성
    response.setContentType("application/json");
    String jsonResponse = "{\"success\": true}"; // 성공 응답
    out.print(jsonResponse);
%>
