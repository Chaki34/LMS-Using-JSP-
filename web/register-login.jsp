<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.security.MessageDigest" %>

<%
    // ==================== CONFIGURATION ====================
    String dbURL = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String dbUser = "root";
    String dbPassword = System.getenv("DB_PASSWORD");

    // If user is already logged in, redirect them to dashboard immediately
    if (session.getAttribute("userId") != null && request.getParameter("logout") == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    // ==================== LOGOUT LOGIC ====================
    if (request.getParameter("logout") != null) {
        session.invalidate();
        response.sendRedirect("register-login.jsp"); // Redirect back to login page after logout
        return;
    }

    // ==================== BACKEND PROCESSING ====================
    String action = request.getParameter("action");

    if (action != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); // OK (can stay)
            conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

            if ("login".equals(action)) {
                String email = request.getParameter("email");
                String pass = request.getParameter("password");

                String sql = "SELECT * FROM users WHERE email = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, email);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    if (rs.getString("password_hash").equals(hashPassword(pass))) {
                        session.setAttribute("userId", rs.getInt("id"));
                        session.setAttribute("fullname", rs.getString("fullname"));
                        session.setAttribute("role", rs.getString("role"));

                        response.sendRedirect("dashboard.jsp");
                        return;
                    } else {
                        session.setAttribute("message", "Invalid password!");
                        session.setAttribute("messageType", "danger");
                    }
                } else {
                    session.setAttribute("message", "User not found!");
                    session.setAttribute("messageType", "warning");
                }
            }
            else if ("register".equals(action)) {
                String fullname = request.getParameter("fullname");
                String email = request.getParameter("email");
                String pass = request.getParameter("password");
                String role = request.getParameter("role");

                pstmt = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
                pstmt.setString(1, email);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    session.setAttribute("message", "Email already exists!");
                    session.setAttribute("messageType", "danger");
                } else {
                    if (rs != null) { rs.close(); }

                    pstmt = conn.prepareStatement("INSERT INTO users (fullname, email, password_hash, role) VALUES (?, ?, ?, ?)");
                    pstmt.setString(1, fullname);
                    pstmt.setString(2, email);
                    pstmt.setString(3, hashPassword(pass));
                    pstmt.setString(4, role);
                    pstmt.executeUpdate();

                    session.setAttribute("message", "Registration successful! Please login.");
                    session.setAttribute("messageType", "success");
                    response.sendRedirect("register-login.jsp?tab=login");
                    return;
                }
            }
        } catch (Exception e) {
            session.setAttribute("message", "Error: " + e.getMessage());
            session.setAttribute("messageType", "danger");
        } finally {
            try { if (rs != null) rs.close(); } catch(Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch(Exception e) {}
            try { if (conn != null) conn.close(); } catch(Exception e) {}
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LMS - Login / Register</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; font-family: sans-serif; }
        .auth-container { display: flex; align-items: center; justify-content: center; padding: 40px 20px; min-height: 100vh;}
        .auth-card { background: white; border-radius: 20px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); width: 100%; max-width: 450px; overflow: hidden; }
        .card-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }
        .card-body { padding: 30px; }
        .btn-auth { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; padding: 12px; border-radius: 10px; width: 100%; font-weight: bold; }
        .nav-tabs .nav-link { color: #666; font-weight: 600; border: none; }
        .nav-tabs .nav-link.active { color: #667eea; border-bottom: 3px solid #667eea; }
    </style>
</head>
<body>

<div class="container">
    <div class="auth-container">
        <div class="auth-card">
            <div class="card-header">
                <i class="bi bi-journal-bookmark-fill fs-1"></i>
                <h3>LMS Portal</h3>
            </div>
            <div class="card-body">

                <%
                    String msg = (String) session.getAttribute("message");
                    String type = (String) session.getAttribute("messageType");
                    if (msg != null) {
                %>
                    <div class="alert alert-<%= type %> alert-dismissible fade show">
                        <%= msg %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% session.removeAttribute("message"); } %>

                <ul class="nav nav-tabs mb-4" id="authTab">
                    <li class="nav-item">
                        <button class="nav-link <%= !"register".equals(request.getParameter("tab")) ? "active" : "" %>" data-bs-toggle="tab" data-bs-target="#loginView">Login</button>
                    </li>
                    <li class="nav-item">
                        <button class="nav-link <%= "register".equals(request.getParameter("tab")) ? "active" : "" %>" data-bs-toggle="tab" data-bs-target="#registerView">Register</button>
                    </li>
                </ul>

                <div class="tab-content">
                    <div class="tab-pane fade <%= !"register".equals(request.getParameter("tab")) ? "show active" : "" %>" id="loginView">
                        <form method="POST">
                            <input type="hidden" name="action" value="login">
                            <div class="mb-3">
                                <label class="form-label">Email</label>
                                <input type="email" name="email" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Password</label>
                                <input type="password" name="password" class="form-control" required>
                            </div>
                            <button type="submit" class="btn-auth">Login</button>
                        </form>
                    </div>

                    <div class="tab-pane fade <%= "register".equals(request.getParameter("tab")) ? "show active" : "" %>" id="registerView">
                        <form method="POST" id="regForm">
                            <input type="hidden" name="action" value="register">
                            <div class="mb-3">
                                <label class="form-label">Full Name</label>
                                <input type="text" name="fullname" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Email</label>
                                <input type="email" name="email" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Password</label>
                                <input type="password" name="password" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Role</label>
                                <select name="role" class="form-control">
                                    <option value="student">Student</option>
                                    <option value="instructor">Instructor</option>
                                </select>
                            </div>
                            <button type="submit" class="btn-auth">Create Account</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>

<%!
    public String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) { return null; }
    }
%>
</body>
</html>