<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.security.MessageDigest" %>

<%
 // Already login user or admin
    if (session.getAttribute("userId") != null) {

        String role = (String) session.getAttribute("role");

        if ("student".equalsIgnoreCase(role)) {
            response.sendRedirect("student_dashboard.jsp");
            return;
        }
        else if ("instructor".equalsIgnoreCase(role)) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        else {
            response.sendRedirect("dashboard.jsp");
            return;
        }
    }

%>

<%
    // ==================== CONFIGURATION (UNTOUCHED) ====================
    String dbURL = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String dbUser = "root";
    String dbPassword = System.getenv("DB_PASSWORD");

    if (session.getAttribute("userId") != null && request.getParameter("logout") == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    if (request.getParameter("logout") != null) {
        session.invalidate();
        response.sendRedirect("register-login.jsp");
        return;
    }

    // ==================== BACKEND PROCESSING (UNTOUCHED LOGIC FLOW) ====================
    String action = request.getParameter("action");
    if (action != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
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

                        // SESSION SET
                        session.setAttribute("userId", rs.getInt("id"));
                        session.setAttribute("fullname", rs.getString("fullname"));

                        String role = rs.getString("role");
                        session.setAttribute("role", role);

                        // ✅ ROLE BASED REDIRECT
                        if ("student".equalsIgnoreCase(role)) {
                            response.sendRedirect("student_dashboard.jsp");
                        } else {
                            response.sendRedirect("dashboard.jsp");
                        }

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

                // ✅ FIX: FORCE ROLE = STUDENT ALWAYS
                String role = "student";



                pstmt = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
                pstmt.setString(1, email);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    session.setAttribute("message", "Email already exists!");
                    session.setAttribute("messageType", "danger");
                } else {
                    pstmt = conn.prepareStatement(
                        "INSERT INTO users (fullname, email, password_hash, role) VALUES (?, ?, ?, ?)"
                    );
                    pstmt.setString(1, fullname);
                    pstmt.setString(2, email);
                    pstmt.setString(3, hashPassword(pass));
                    pstmt.setString(4, role); // always student
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
    <title>Personnel Ledger - LearnSphere Gazette</title>

    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=Crimson+Text:wght@400;700&family=Special+Elite&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>
        :root {
            --paper: #f4f1ea;
            --ink: #1a1a1a;
            --accent-red: #8b0000;
        }

        body {
            background-color: var(--paper);
            background-image: url('https://www.transparenttextures.com/patterns/paper-fibers.png');
            font-family: 'Crimson Text', serif;
            color: var(--ink);
            min-height: 100vh;
        }

        .auth-container {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }

        .auth-card {
            background: white;
            border: 4px double var(--ink);
            box-shadow: 10px 10px 0px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 500px;
            padding: 40px;
        }

        .card-masthead {
            text-align: center;
            border-bottom: 2px solid var(--ink);
            margin-bottom: 30px;
            padding-bottom: 10px;
        }

        .card-masthead h3 {
            font-family: 'Playfair Display', serif;
            font-weight: 900;
            text-transform: uppercase;
        }

        .form-label {
            font-family: 'Special Elite', cursive;
            text-transform: uppercase;
        }

        .form-control {
            border-radius: 0;
            border: 1px solid var(--ink);
            font-family: 'Special Elite', cursive;
        }

        .btn-auth {
            background: var(--ink);
            color: white;
            width: 100%;
            padding: 12px;
            border: none;
            font-family: 'Special Elite', cursive;
            text-transform: uppercase;
        }

        .btn-auth:hover {
            background: var(--accent-red);
        }

        .nav-tabs .nav-link.active {
            border-bottom: 3px solid var(--ink);
            font-weight: bold;
        }
    </style>
</head>

<body>

<div class="container">
<div class="auth-container">
<div class="auth-card">

    <div class="card-masthead">
        <p>Official Archives</p>
        <h3>LearnSphere Ledger</h3>
        <p>Secure Access</p>
    </div>

    <%
        String msg = (String) session.getAttribute("message");
        String type = (String) session.getAttribute("messageType");
        if (msg != null) {
    %>
        <div class="alert alert-<%= type %>"><%= msg %></div>
    <% session.removeAttribute("message"); } %>

    <ul class="nav nav-tabs justify-content-center">
        <li class="nav-item">
            <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#loginView">Login</button>
        </li>
        <li class="nav-item">
            <button class="nav-link" data-bs-toggle="tab" data-bs-target="#registerView">Register</button>
        </li>
    </ul>

    <div class="tab-content">

        <!-- LOGIN -->
        <div class="tab-pane fade show active" id="loginView">
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

                <button class="btn-auth" type="submit">Login</button>
            </form>
        </div>

        <!-- REGISTER (ROLE REMOVED) -->
        <div class="tab-pane fade" id="registerView">
            <form method="POST">
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

                <!-- ❌ ROLE DROPDOWN REMOVED -->

                <button class="btn-auth" type="submit">Register</button>
            </form>
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
        StringBuilder sb = new StringBuilder();
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) sb.append('0');
            sb.append(hex);
        }
        return sb.toString();
    } catch (Exception e) {
        return null;
    }
}
%>

</body>
</html>