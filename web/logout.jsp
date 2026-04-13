<%-- 
    Document   : logout
    Created on : 02-Apr-2026, 6:47:52 pm
    Author     : Administrator
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1. Destroy the session
    session.invalidate();

    // 2. Start a NEW session just to hold the logout message
    HttpSession newSession = request.getSession(true);
    newSession.setAttribute("message", "You have been logged out successfully!");
    newSession.setAttribute("messageType", "info");

    // 3. Redirect back to login page
    response.sendRedirect("index.jsp");
%>