<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // Database credentials
    String dbUrl = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String dbUser = "root";
    String dbPassword = System.getenv("DB_PASSWORD");

    // Get Course ID safely
    int courseId = 0;
    String idParam = request.getParameter("courseId");

    if (idParam != null && !idParam.trim().isEmpty()) {
        try {
            courseId = Integer.parseInt(idParam);
        } catch (Exception e) {
            courseId = 0;
        }
    }

    String name = "N/A";
    int price = 0;
    String desc = "No description available.";

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);

        String sql = "SELECT c.course_name, c.price, c.course_des FROM courses c WHERE c.id=?";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, courseId);

        rs = ps.executeQuery();

        if (rs.next()) {
            name = rs.getString("course_name");
            price = rs.getInt("price");
            desc = rs.getString("course_des");
        }

    } catch (Exception e) {
        out.println("<div style='color:red'>DB ERROR: " + e.getMessage() + "</div>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Payment Bureau - The Daily Scholar</title>
    <link href="https://fonts.googleapis.com/css2?family=Crimson+Text:ital,wght@0,400;0,700;1,400&family=Playfair+Display:wght@900&family=Special+Elite&display=swap" rel="stylesheet">

    <style>
        :root {
            --paper: #f4f1ea;
            --ink: #1a1a1a;
            --accent-red: #8b0000;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background-color: var(--paper);
            background-image: url('https://www.transparenttextures.com/patterns/paper-fibers.png');
            color: var(--ink);
            font-family: 'Crimson Text', serif;
            line-height: 1.6;
        }

        /* --- Header Styles --- */
        .top-bar { background: var(--ink); color: var(--paper); padding: 8px 0; border-bottom: 2px solid var(--accent-red); }
        .top-bar-content { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; padding: 0 20px; align-items: center; }
        .typewriter { font-family: 'Special Elite', cursive; overflow: hidden; white-space: nowrap; border-right: .15em solid var(--accent-red); animation: typing 4s steps(40, end) infinite; }
        @keyframes typing { from { width: 0 } to { width: 100% } }

        .news-header { text-align: center; padding: 30px 20px; border-bottom: 4px double var(--ink); margin: 0 20px 20px 20px; }
        .logo-title { font-family: 'Playfair Display', serif; font-size: 60px; text-transform: uppercase; margin: 10px 0; }
        .header-meta { font-family: 'Special Elite', cursive; border-top: 1px solid var(--ink); border-bottom: 1px solid var(--ink); padding: 5px 0; display: flex; justify-content: space-between; font-size: 14px; }

        /* --- Billing Layout --- */
        .billing-container { max-width: 1100px; margin: 40px auto; display: grid; grid-template-columns: 1fr 1.2fr; gap: 50px; padding: 0 20px; }

        /* Left Column: Invoice */
        .invoice-box { border: 2px solid var(--ink); padding: 30px; background: white; box-shadow: 10px 10px 0px rgba(0,0,0,0.1); }
        .invoice-title { font-family: 'Playfair Display', serif; font-size: 28px; border-bottom: 2px solid var(--ink); margin-bottom: 20px; text-align: center; }
        .detail-row { display: flex; justify-content: space-between; margin-bottom: 15px; border-bottom: 1px dotted #ccc; padding-bottom: 5px; }
        .fee-label { font-family: 'Special Elite', cursive; font-size: 14px; }
        .fee-value { font-weight: bold; }
        .total-section { margin-top: 30px; padding: 15px; border: 2px dashed var(--ink); background: #fdfdfd; text-align: center; }
        .total-amount { font-size: 32px; font-weight: 900; color: var(--accent-red); }

        /* Right Column: Payment Tabs */
        .payment-methods { border-left: 1px solid var(--ink); padding-left: 40px; }
        .method-tabs { display: flex; gap: 10px; margin-bottom: 30px; }
        .tab-btn {
            flex: 1; padding: 10px; border: 1px solid var(--ink);
            font-family: 'Special Elite', cursive; cursor: pointer;
            text-align: center; background: transparent; transition: 0.3s;
        }
        .tab-btn.active { background: var(--ink); color: var(--paper); box-shadow: 4px 4px 0px var(--accent-red); }

        .payment-content { display: none; border: 1px solid var(--ink); padding: 20px; min-height: 300px; }
        .payment-content.active { display: block; }

        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; font-family: 'Special Elite', cursive; font-size: 12px; margin-bottom: 5px; }
        .form-group input { width: 100%; padding: 10px; border: 1px solid var(--ink); background: #fff; font-family: 'Crimson Text'; }

        .qr-placeholder { text-align: center; padding: 20px; }
        .qr-placeholder img { width: 180px; filter: grayscale(1); border: 1px solid var(--ink); padding: 5px; }

        .pay-now-btn {
            width: 100%; padding: 15px; background: var(--ink); color: var(--paper);
            border: none; font-family: 'Special Elite', cursive; font-size: 18px;
            cursor: pointer; margin-top: 20px;
        }
        .pay-now-btn:hover { background: var(--accent-red); }

        footer { text-align: center; padding: 40px; border-top: 4px double var(--ink); margin-top: 50px; font-family: 'Special Elite'; }
    </style>
</head>
<body>

    <div class="top-bar">
        <div class="top-bar-content">
            <div class="typewriter">TELEGRAPHIC TRANSFER PROTOCOL INITIATED...</div>
            <span style="font-family: 'Special Elite'; font-size: 12px;">ENCRYPTION: AES-256</span>
        </div>
    </div>

    <header class="news-header">
        <div class="header-meta">
            <span>VOL. LIX ... No. 365</span>
            <span><%= new java.util.Date() %></span>
            <span>FINAL EDITION</span>
        </div>
        <h1 class="logo-title">The Daily Scholar</h1>
    </header>

    <div class="billing-container">

        <!-- SELECTED COURSE DETAILS -->
        <div class="invoice-box">
            <h2 class="invoice-title">Official Enrollment Voucher</h2>
            <div class="detail-row">
                <span class="fee-label">COURSE TITLE</span>
                <span class="fee-value"><%= name %></span>
            </div>
            <div class="detail-row">
                <span class="fee-label">COURSE ID</span>
                <span class="fee-value">#<%= courseId %></span>
            </div>
            <div style="margin: 20px 0; font-style: italic; font-size: 14px; color: #444;">
                <p><%= desc %></p>
            </div>
            <div class="detail-row">
                <span class="fee-label">TUITION FEES</span>
                <span class="fee-value">$<%= price %>.00</span>
            </div>
            <div class="detail-row">
                <span class="fee-label">LIBRARY ACCESS</span>
                <span class="fee-value">INCLUDED</span>
            </div>

            <div class="total-section">
                <p class="fee-label">TOTAL AMOUNT DUE</p>
                <h3 class="total-amount">$<%= price %>.00</h3>
            </div>

            <p style="font-size: 11px; margin-top: 20px; text-align: center; text-transform: uppercase; font-family: 'Special Elite';">
                Valid for enrollment in the current academic term only.
            </p>
        </div>

        <!-- PAYMENT SELECTION -->
        <div class="payment-methods">
            <h3 style="font-family: 'Special Elite'; margin-bottom: 15px;">SELECT SETTLEMENT METHOD:</h3>

            <div class="method-tabs">
                <div class="tab-btn active" onclick="showPayment('card', this)">1. CREDIT CARD</div>
                <div class="tab-btn" onclick="showPayment('upi', this)">2. UPI ID</div>
                <div class="tab-btn" onclick="showPayment('qr', this)">3. QR SCAN</div>
            </div>

            <form action="process_payment.jsp" method="post">
                <input type="hidden" name="courseId" value="<%= courseId %>">
                <input type="hidden" name="amount" value="<%= price %>">

                <!-- Card Payment -->
                <div id="card" class="payment-content active">
                    <div class="form-group">
                        <label>CARDHOLDER NAME</label>
                        <input type="text" name="cardname" placeholder="Name as printed on card">
                    </div>
                    <div class="form-group">
                        <label>CARD NUMBER</label>
                        <input type="text" name="cardnumber" placeholder="0000 0000 0000 0000">
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                        <div class="form-group">
                            <label>EXPIRY</label>
                            <input type="text" placeholder="MM/YY">
                        </div>
                        <div class="form-group">
                            <label>CVV</label>
                            <input type="password" placeholder="***">
                        </div>
                    </div>
                </div>

                <!-- UPI Payment -->
                <div id="upi" class="payment-content">
                    <div class="form-group">
                        <label>ENTER UPI ID (VPA)</label>
                        <input type="text" name="upiId" placeholder="username@bank">
                    </div>
                    <p style="font-size: 13px; font-style: italic;">A request will be sent to your mobile application.</p>
                </div>

                <!-- QR Payment -->
                <div id="qr" class="payment-content">
                    <div class="qr-placeholder">
                        <p class="fee-label">SCAN TO PAY</p>
                        <!-- Sample QR code -->
                        <img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=PaymentForCourse<%=courseId%>" alt="QR Code">
                        <p style="font-size: 12px; margin-top: 10px;">Use any UPI App: GPay, PhonePe, Paytm</p>
                    </div>
                </div>

                <button type="submit" class="pay-now-btn">AUTHORIZE TRANSACTION</button>
            </form>
        </div>
    </div>

    <footer>
        <p>&copy; 1924 THE DAILY SCHOLAR PRESS. ALL RIGHTS RESERVED. <br> REGISTERED AT THE GENERAL POST OFFICE.</p>
    </footer>

    <script>
        function showPayment(methodId, btn) {
            // Hide all contents
            document.querySelectorAll('.payment-content').forEach(content => {
                content.classList.remove('active');
            });
            // Remove active class from buttons
            document.querySelectorAll('.tab-btn').forEach(tab => {
                tab.classList.remove('active');
            });
            // Show selected
            document.getElementById(methodId).classList.add('active');
            btn.classList.add('active');
        }
    </script>

</body>
</html>