<%@page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    response.setContentType("application/json");

    boolean expired = (session.getAttribute("selectedCofnums") == null);

    String jsonResponse = "{\"expired\": " + expired + "}";
    out.print(jsonResponse);
%>
