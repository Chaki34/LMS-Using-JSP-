<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Database credentials
    String myDriver = "com.mysql.cj.jdbc.Driver";
    String myUrl = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String dbPassword = System.getenv("DB_PASSWORD");

    // Get Course ID from request
    String idParam = request.getParameter("courseId");
    int courseId = (idParam != null) ? Integer.parseInt(idParam) : 0;

    // Variables to hold data
    String name = "N/A";
    int price = 0;
    String shortDes = "";
    double rating = 0.0;
    String category = "";

    try {
        Class.forName(myDriver);
        Connection conn = DriverManager.getConnection(myUrl, "root", dbPassword);

        // SQL JOIN to get details from both tables
        String sql = "SELECT c.course_name, c.price, c.course_des, c.catagory, cc.rating " +
                     "FROM courses c " +
                     "LEFT JOIN course_curriculams cc ON c.id = cc.course_id " +
                     "WHERE c.id=?";

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, courseId);
        ResultSet rs = ps.executeQuery();

        if(rs.next()){
            name = rs.getString("course_name");
            price = rs.getInt("price");
            shortDes = rs.getString("course_des");
            category = rs.getString("catagory");
            rating = rs.getDouble("rating");
        }
        conn.close();
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Enrollment Bureau | <%= name %></title>
    <link href="https://fonts.googleapis.com/css2?family=Crimson+Text:ital,wght@0,400;0,700;1,400&family=Playfair+Display:wght@900&family=Special+Elite&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

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

        /* --- Header --- */
        .top-bar { background: var(--ink); color: var(--paper); padding: 8px 0; border-bottom: 2px solid var(--accent-red); }
        .top-bar-content { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; padding: 0 20px; font-family: 'Special Elite'; font-size: 12px; }

        .news-header { text-align: center; padding: 20px; border-bottom: 4px double var(--ink); margin: 0 20px 30px; }
        .logo-title { font-family: 'Playfair Display', serif; font-size: 50px; text-transform: uppercase; }

        /* --- Main Layout --- */
        .billing-grid { max-width: 1100px; margin: 0 auto; display: grid; grid-template-columns: 1fr 1.2fr; gap: 40px; padding: 20px; }

        /* Left Side: Course Info Voucher */
        .voucher {
            border: 1px solid var(--ink);
            padding: 25px;
            background: white;
            box-shadow: 8px 8px 0px rgba(0,0,0,0.1);
            position: relative;
        }
        .voucher-header { border-bottom: 2px solid var(--ink); margin-bottom: 15px; padding-bottom: 10px; }
        .category-tag { font-family: 'Special Elite'; font-size: 12px; background: var(--ink); color: var(--paper); padding: 2px 8px; }

        .course-title { font-family: 'Playfair Display', serif; font-size: 28px; line-height: 1.2; margin: 10px 0; }

        .rating-stars { color: #d4af37; font-size: 18px; margin-bottom: 10px; }
        .rating-num { font-family: 'Special Elite'; color: var(--ink); font-size: 14px; margin-left: 5px; }

        .short-description { font-style: italic; color: #444; margin-bottom: 20px; border-left: 3px solid var(--accent-red); padding-left: 15px; }

        .price-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .price-table td { padding: 10px 0; border-bottom: 1px dotted var(--ink); }
        .label { font-family: 'Special Elite'; font-size: 13px; }
        .amount { text-align: right; font-weight: bold; }

        .total-row { font-size: 24px; font-weight: 900; color: var(--accent-red); border-bottom: 3px double var(--ink) !important; }

        /* Right Side: Payment */
        .payment-box { border-left: 1px solid var(--ink); padding-left: 40px; }
        .payment-title { font-family: 'Special Elite'; text-decoration: underline; margin-bottom: 20px; }

        .tabs { display: flex; gap: 5px; margin-bottom: 20px; }
        .tab-btn {
            flex: 1; padding: 12px; border: 1px solid var(--ink);
            background: transparent; cursor: pointer; font-family: 'Special Elite'; font-size: 12px;
        }
        .tab-btn.active { background: var(--ink); color: var(--paper); }

        .method-content { display: none; padding: 20px; border: 1px solid var(--ink); background: rgba(255,255,255,0.5); }
        .method-content.active { display: block; }

        .input-group { margin-bottom: 15px; }
        .input-group label { display: block; font-family: 'Special Elite'; font-size: 11px; margin-bottom: 5px; }
        .input-group input { width: 100%; padding: 10px; border: 1px solid var(--ink); background: white; }

        .pay-btn {
            width: 100%; padding: 15px; background: var(--accent-red); color: white;
            border: none; font-family: 'Special Elite'; font-size: 18px; cursor: pointer; margin-top: 20px;
            box-shadow: 4px 4px 0px var(--ink);
        }

        .qr-area { text-align: center; }
        .qr-area img { width: 150px; border: 1px solid var(--ink); padding: 5px; filter: grayscale(1); }

        @media (max-width: 768px) { .billing-grid { grid-template-columns: 1fr; } .payment-box { border-left: none; padding-left: 0; } }
    </style>
</head>
<body>

    <div class="top-bar">
        <div class="top-bar-content">
            <span>SECURE TELEGRAPHIC TRANSFER</span>
            <span>TERMINAL ID: DS-992</span>
        </div>
    </div>

    <header class="news-header">
        <h1 class="logo-title">The Daily Scholar</h1>
        <p style="font-family: 'Special Elite'; font-size: 12px;">ESTABLISHED 1924 • ACADEMIC RECORD DEPT.</p>
    </header>

    <div class="billing-grid">

        <!-- LEFT: COURSE SUMMARY VOUCHER -->
        <div class="voucher">
            <div class="voucher-header">
                <span class="category-tag"><%= category %></span>
                <span style="float: right; font-family: 'Special Elite'; font-size: 12px;">#INV-<%= courseId %>77</span>
            </div>

            <h2 class="course-title"><%= name %></h2>

            <div class="rating-stars">
                <% for(int i=1; i<=5; i++) { %>
                    <i class="<%= (i <= rating) ? "fas" : "far" %> fa-star"></i>
                <% } %>
                <span class="rating-num">(<%= rating %>/5.0)</span>
            </div>

            <div class="short-description">
                "<%= shortDes %>"
            </div>

            <table class="price-table">
                <tr>
                    <td class="label">TUITION FEE</td>
                    <td class="amount">$<%= price %>.00</td>
                </tr>
                <tr>
                    <td class="label">EXAM ADMITTANCE</td>
                    <td class="amount">INCLUDED</td>
                </tr>
                <tr>
                    <td class="label">DIGITAL ARCHIVE ACCESS</td>
                    <td class="amount">$0.00</td>
                </tr>
                <tr class="total-row">
                    <td class="label">TOTAL PAYABLE</td>
                    <td class="amount">$<%= price %>.00</td>
                </tr>
            </table>

            <div style="margin-top: 30px; text-align: center; opacity: 0.6;">
                <p style="font-family: 'Special Elite'; font-size: 10px;">AUTHORIZED BY THE EDITORIAL BOARD</p>
                <i class="fas fa-stamp fa-3x"></i>
            </div>
        </div>

        <!-- RIGHT: PAYMENT METHODS -->
        <div class="payment-box">
            <h3 class="payment-title">SETTLE YOUR ACCOUNT</h3>

            <div class="tabs">
                <button class="tab-btn active" onclick="openTab(event, 'card')"><i class="fas fa-credit-card"></i> CARD</button>
                <button class="tab-btn" onclick="openTab(event, 'upi')"><i class="fas fa-mobile-alt"></i> UPI</button>
                <button class="tab-btn" onclick="openTab(event, 'qr')"><i class="fas fa-qrcode"></i> QR CODE</button>
            </div>

            <form action="process_payment.jsp" method="POST">
                <input type="hidden" name="courseId" value="<%= courseId %>">

                <!-- Card Form -->
                <div id="card" class="method-content active">
                    <div class="input-group">
                        <label>CARDHOLDER NAME</label>
                        <input type="text" name="cname" placeholder="A. SCHOLAR">
                    </div>
                    <div class="input-group">
                        <label>CREDIT CARD NUMBER</label>
                        <input type="text" name="cnum" placeholder="XXXX XXXX XXXX XXXX">
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <div class="input-group" style="flex:2">
                            <label>EXPIRY</label>
                            <input type="text" placeholder="MM/YY">
                        </div>
                        <div class="input-group" style="flex:1">
                            <label>CVV</label>
                            <input type="text" placeholder="***">
                        </div>
                    </div>
                </div>

                <!-- UPI Form -->
                <div id="upi" class="method-content">
                    <div class="input-group">
                        <label>VIRTUAL PAYMENT ADDRESS (VPA)</label>
                        <input type="text" name="upiid" placeholder="yourname@bank">
                    </div>
                    <p style="font-size: 12px; font-style: italic;">A notification will be sent to your UPI app for approval.</p>
                </div>

                <!-- QR Form -->
                <div id="qr" class="method-content">
                    <div class="qr-area">
                        <p class="label" style="margin-bottom: 10px;">SCAN TO SETTLE FEES</p>
                        <img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=PAY-SCHOLAR-<%=courseId%>" alt="QR Code">
                        <p style="font-size: 11px; margin-top: 10px;">Google Pay, PhonePe, and BharatPe accepted.</p>
                    </div>
                </div>

                <button type="submit" class="pay-btn">CONFIRM ENROLLMENT</button>
            </form>
        </div>
    </div>

    <footer style="text-align: center; padding: 40px; font-family: 'Special Elite'; border-top: 1px solid var(--ink); margin-top: 40px;">
        <p>COPYRIGHT © 1924 THE DAILY SCHOLAR PRESS • ALL ENROLLMENTS ARE FINAL</p>
    </footer>

    <script>
        function openTab(evt, methodName) {
            var i, tabcontent, tablinks;
            tabcontent = document.getElementsByClassName("method-content");
            for (i = 0; i < tabcontent.length; i++) {
                tabcontent[i].style.display = "none";
                tabcontent[i].classList.remove("active");
            }
            tablinks = document.getElementsByClassName("tab-btn");
            for (i = 0; i < tablinks.length; i++) {
                tablinks[i].classList.remove("active");
            }
            document.getElementById(methodName).style.display = "block";
            document.getElementById(methodName).classList.add("active");
            evt.currentTarget.classList.add("active");
        }
    </script>
</body>
</html>