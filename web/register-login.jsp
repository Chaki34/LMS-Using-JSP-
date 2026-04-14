<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.security.MessageDigest" %>

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

    // ==================== BACKEND PROCESSING (UNTOUCHED) ====================
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
    <title>Personnel Ledger - LearnSphere Gazette</title>
    <!-- Same Fonts as Main Page -->
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
            display: flex; align-items: center; justify-content: center;
            padding: 60px 20px;
        }

        .auth-card {
            background: white;
            border: 4px double var(--ink); /* Newspaper double border */
            box-shadow: 10px 10px 0px rgba(0,0,0,0.1);
            width: 100%; max-width: 500px;
            padding: 40px;
            position: relative;
        }

        /* Newspaper Header inside Card */
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
            letter-spacing: -1px;
            font-size: 28px;
        }

        .card-masthead p {
            font-family: 'Special Elite', cursive;
            font-size: 12px;
            text-transform: uppercase;
            margin: 0;
        }

        /* Form Styling */
        .form-label {
            font-family: 'Special Elite', cursive;
            text-transform: uppercase;
            font-size: 13px;
            font-weight: bold;
        }

        .form-control {
            border: 1px solid var(--ink);
            border-radius: 0;
            background-color: #fafafa;
            font-family: 'Special Elite', cursive;
        }

        .form-control:focus {
            box-shadow: none;
            border-color: var(--accent-red);
            background-color: #fff;
        }

        /* Custom Button */
        .btn-auth {
            background: var(--ink);
            color: var(--paper);
            border: none;
            padding: 12px;
            border-radius: 0;
            width: 100%;
            font-family: 'Special Elite', cursive;
            font-size: 16px;
            text-transform: uppercase;
            transition: 0.3s;
        }

        .btn-auth:hover {
            background: var(--accent-red);
            color: white;
        }

        /* Newspaper Style Tabs */
        .nav-tabs { border-bottom: 2px solid var(--ink); margin-bottom: 25px; }
        .nav-tabs .nav-link {
            border: none;
            color: #777;
            font-family: 'Special Elite', cursive;
            text-transform: uppercase;
            font-size: 14px;
        }
        .nav-tabs .nav-link.active {
            background: none;
            color: var(--ink);
            font-weight: bold;
            border-bottom: 4px solid var(--ink);
        }

        .alert {
            border-radius: 0;
            font-family: 'Special Elite', cursive;
            font-size: 13px;
            border: 1px dashed var(--ink);
        }
    </style>
</head>
<body>

<div class="container">
    <div class="auth-container">
        <div class="auth-card">
            <div class="card-masthead">
                <p>Official Archives - Vol. 1</p>
                <h3>LearnSphere Personnel Ledger</h3>
                <p>Classified Entry Only</p>
            </div>

            <%
                String msg = (String) session.getAttribute("message");
                String type = (String) session.getAttribute("messageType");
                if (msg != null) {
            %>
                <div class="alert alert-<%= type %> alert-dismissible fade show">
                    <strong>NOTICE:</strong> <%= msg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% session.removeAttribute("message"); } %>

            <ul class="nav nav-tabs justify-content-center" id="authTab">
                <li class="nav-item">
                    <button class="nav-link <%= !"register".equals(request.getParameter("tab")) ? "active" : "" %>" data-bs-toggle="tab" data-bs-target="#loginView">Sign In</button>
                </li>
                <li class="nav-item">
                    <button class="nav-link <%= "register".equals(request.getParameter("tab")) ? "active" : "" %>" data-bs-toggle="tab" data-bs-target="#registerView">New Enrollment</button>
                </li>
            </ul>

            <div class="tab-content">
                <!-- Login View -->
                <div class="tab-pane fade <%= !"register".equals(request.getParameter("tab")) ? "show active" : "" %>" id="loginView">
                    <form method="POST">
                        <input type="hidden" name="action" value="login">
                        <div class="mb-3">
                            <label class="form-label">Correspondent Email</label>
                            <input type="email" name="email" class="form-control" placeholder="e.g. scribe@gazette.com" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Secret Passphrase</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>
                        <button type="submit" class="btn-auth">Verify Credentials</button>
                    </form>
                </div>

                <!-- Register View -->
                <div class="tab-pane fade <%= "register".equals(request.getParameter("tab")) ? "show active" : "" %>" id="registerView">
                    <form method="POST">
                        <input type="hidden" name="action" value="register">
                        <div class="mb-3">
                            <label class="form-label">Full Legal Name</label>
                            <input type="text" name="fullname" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Electronic Mail</label>
                            <input type="email" name="email" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">New Passphrase</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Appointed Role</label>
                            <select name="role" class="form-control">
                                <option value="student">Student / Reader</option>
                                <option value="instructor">Instructor / Editor</option>
                            </select>
                        </div>
                        <button type="submit" class="btn-auth">Apply for Enrollment</button>
                    </form>
                </div>
            </div>

            <div style="text-align: center; margin-top: 30px; font-family: 'Special Elite'; font-size: 11px; color: #777;">
                <hr>
                <p>Return to <a href="index.jsp" style="color: var(--accent-red);">Front Page</a></p>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>

<%!
    // UNTOUCHED PASSWORD HASHING LOGIC
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