<%-- 
    Document   : courseinfo.jsp
    Created on : 25-Feb-2026, 11:58:16?am
    Author     : Administrator
--%>

<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>

<!DOCTYPE html>
<html lang="en">
    
    
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LearnSphere - Course details</title>
    <!-- Font Awesome & Google Fonts (same as main page) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    
    
    
    
    <style>
        /* ===== GLOBAL STYLES (exactly matching the vibe of the provided HTML) ===== */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: #f8fafd;
            color: #1e293b;
            line-height: 1.5;
        }

        /* top bar */
        .top-bar {
            background: linear-gradient(135deg, #0f172a, #1e293b);
            color: white;
            padding: 10px 0;
            font-size: 0.9rem;
            border-bottom: 1px solid #334155;
        }
        .top-bar-content {
            max-width: 1280px;
            margin: 0 auto;
            padding: 0 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
        }
        .offer-text i {
            margin-right: 8px;
            color: #fbbf24;
        }
        .login-btn {
            color: white;
            text-decoration: none;
            background: rgba(255,255,255,0.1);
            padding: 6px 16px;
            border-radius: 30px;
            transition: 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-weight: 500;
        }
        .login-btn:hover {
            background: rgba(255,255,255,0.2);
        }

        /* navbar */
        .navbar {
            background: white;
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
            position: sticky;
            top: 0;
            z-index: 100;
            border-bottom: 1px solid #eef2f6;
        }
        .nav-container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 0 30px;
            height: 75px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1.7rem;
            font-weight: 700;
            color: #0f172a;
        }
        .logo i {
            color: #3b82f6;
            font-size: 2rem;
        }
        .nav-menu {
            display: flex;
            list-style: none;
            gap: 10px;
        }
        .nav-link {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 10px 18px;
            color: #334155;
            text-decoration: none;
            font-weight: 500;
            border-radius: 40px;
            transition: 0.2s;
        }
        .nav-link i {
            font-size: 1rem;
            color: #64748b;
        }
        .nav-link:hover {
            background: #f1f5f9;
            color: #0f172a;
        }
        .mobile-toggle {
            display: none;
            font-size: 1.5rem;
            color: #0f172a;
        }

        /* breadcrumb (custom for course page) */
        .breadcrumb-wrap {
            max-width: 1280px;
            margin: 20px auto 0;
            padding: 0 30px;
        }
        .breadcrumb {
            display: flex;
            flex-wrap: wrap;
            list-style: none;
            background: transparent;
            padding: 10px 0;
            font-size: 0.95rem;
        }
        .breadcrumb li {
            display: flex;
            align-items: center;
        }
        .breadcrumb li a {
            color: #3b82f6;
            text-decoration: none;
        }
        .breadcrumb li a:hover {
            text-decoration: underline;
        }
        .breadcrumb li+li:before {
            content: "�";
            margin: 0 10px;
            color: #94a3b8;
            font-weight: 600;
        }

        /* main course info section (hero-like) */
        .course-info-hero {
            background: white;
            border-bottom: 1px solid #e9eef3;
            padding: 40px 0 30px;
        }
        .course-info-container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 0 30px;
            display: grid;
            grid-template-columns: 1fr 360px;
            gap: 40px;
        }
        .info-left h1 {
            font-size: 2.5rem;
            font-weight: 700;
            line-height: 1.2;
            color: #0f172a;
            margin-bottom: 20px;
        }
        .badge-group {
            display: flex;
            flex-wrap: wrap;
            gap: 15px 30px;
            margin-bottom: 25px;
        }
        .badge {
            background: #eef2ff;
            color: #1e40af;
            padding: 5px 14px;
            border-radius: 30px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .badge i {
            color: #3b82f6;
        }
        .stats-row {
            display: flex;
            flex-wrap: wrap;
            gap: 25px 40px;
            margin: 20px 0 25px;
        }
        .stat-item {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1rem;
        }
        .stat-item i {
            font-size: 1.4rem;
            color: #2563eb;
            width: 32px;
        }
        .stat-item strong {
            font-weight: 700;
            color: #0f172a;
        }
        .instructor-short {
            display: flex;
            align-items: center;
            gap: 15px;
            margin: 30px 0 20px;
        }
        .instructor-short img {
    width: 100%;        /* Increased width for banner shape */
    height: 100%;        /* Reduced height for rectangular look */
    border-radius: 12px; /* Slightly rounded corners (optional) */
    object-fit: cover;
    background: #cbd5e1;
    border: 2px solid #3b82f6; /* Optional: adds a nice border */
}
        .instructor-short div p {
            color: #475569;
        }
        .info-right {
            background: #ffffff;
            border-radius: 24px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.05);
            padding: 25px;
            border: 1px solid #eef2f6;
            height: fit-content;
        }
        .price-tag {
            font-size: 2.2rem;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 5px;
        }
        .price-info {
            color: #64748b;
            font-size: 0.95rem;
            margin-bottom: 25px;
        }
        .btn-primary {
            background: #3b82f6;
            color: white;
            border: none;
            padding: 16px 24px;
            width: 100%;
            border-radius: 16px;
            font-weight: 700;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            cursor: pointer;
            transition: 0.15s;
            margin-bottom: 15px;
            border: 1px solid #2563eb;
        }
        .btn-primary:hover {
            background: #2563eb;
            transform: scale(1.02);
        }
        .btn-outline {
            background: white;
            border: 1px solid #cbd5e1;
            padding: 14px 24px;
            width: 100%;
            border-radius: 16px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            cursor: pointer;
            transition: 0.15s;
        }
        .btn-outline i {
            color: #3b82f6;
        }
        .btn-outline:hover {
            background: #f8fafc;
            border-color: #94a3b8;
        }
        .includes-box {
            margin-top: 25px;
            padding-top: 20px;
            border-top: 1px dashed #d1d9e6;
        }
        .includes-box h4 {
            font-size: 1rem;
            margin-bottom: 15px;
            color: #334155;
        }
        .includes-box ul {
            list-style: none;
        }
        .includes-box li {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 12px;
            color: #1e293b;
            font-size: 0.95rem;
        }
        .includes-box li i {
            color: #22c55e;
            width: 20px;
        }

        /* description, curriculum, instructor (tabs style) */
        .details-section {
            max-width: 1280px;
            margin: 40px auto 60px;
            padding: 0 30px;
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 40px;
        }
        .details-tabs {
            background: white;
            border-radius: 24px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.02);
            border: 1px solid #eef2f6;
            overflow: hidden;
        }
        .tab-headers {
            display: flex;
            border-bottom: 1px solid #e9eef3;
            background: #f9fbfd;
        }
        .tab-btn {
            flex: 1;
            background: none;
            border: none;
            padding: 18px 10px;
            font-weight: 600;
            color: #64748b;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            transition: 0.1s;
            font-size: 1rem;
        }
        .tab-btn.active {
            color: #2563eb;
            border-bottom-color: #2563eb;
            background: white;
        }
        .tab-pane {
            padding: 30px;
            display: none;
        }
        .tab-pane.active {
            display: block;
        }
        .tab-pane h3 {
            font-size: 1.3rem;
            margin-bottom: 20px;
            color: #0f172a;
        }
        .desc-text {
            color: #334155;
            margin-bottom: 20px;
            line-height: 1.7;
        }
        .curriculum-list {
            list-style: none;
        }
        .curriculum-list li {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px 0;
            border-bottom: 1px solid #ecf1f7;
        }
        .curriculum-list li i {
            color: #2563eb;
            font-size: 1.2rem;
        }
        .instructor-card {
            display: flex;
            gap: 25px;
            background: #f8fafc;
            padding: 25px;
            border-radius: 20px;
            margin: 20px 0;
        }
        .instructor-card img {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            object-fit: cover;
        }
        /* right sidebar similar to footer/extra */
        .sidebar-card {
            background: white;
            border-radius: 24px;
            padding: 25px;
            border: 1px solid #eef2f6;
            margin-bottom: 25px;
        }
        .sidebar-card h3 {
            font-size: 1.2rem;
            margin-bottom: 20px;
        }
        .related-course {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            align-items: center;
        }
        .related-course img {
            width: 70px;
            height: 70px;
            border-radius: 14px;
            background: #ddd;
            object-fit: cover;
        }
        .related-course h4 {
            font-size: 1rem;
            font-weight: 600;
        }
        .related-course p {
            color: #3b82f6;
            font-weight: 600;
            margin-top: 5px;
        }

        /* footer exact same as main page */
        .footer {
            background: #0f172a;
            color: #cbd5e1;
            border-top: 1px solid #1e293b;
        }
        .footer-container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 60px 30px 30px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 40px;
        }
        .footer-logo {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1.8rem;
            font-weight: 700;
            color: white;
            margin-bottom: 20px;
        }
        .footer-logo i {
            color: #3b82f6;
        }
        .footer-description {
            margin-bottom: 20px;
            line-height: 1.6;
        }
        .social-icons a {
            color: #94a3b8;
            margin-right: 15px;
            font-size: 1.2rem;
            transition: 0.2s;
        }
        .social-icons a:hover {
            color: white;
        }
        .footer-heading {
            color: white;
            font-size: 1.2rem;
            margin-bottom: 20px;
            font-weight: 600;
        }
        .footer-links, .footer-contact {
            list-style: none;
        }
        .footer-links li, .footer-contact li {
            margin-bottom: 12px;
        }
        .footer-links a, .footer-contact a {
            color: #cbd5e1;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .footer-links a:hover {
            color: white;
        }
        .footer-contact i {
            width: 24px;
            color: #3b82f6;
        }
        .footer-bottom {
            border-top: 1px solid #1e293b;
            padding: 25px 0;
        }
        .footer-bottom-content {
            max-width: 1280px;
            margin: 0 auto;
            padding: 0 30px;
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            color: #94a3b8;
        }
        .footer-bottom-links a {
            color: #94a3b8;
            margin-left: 30px;
            text-decoration: none;
        }
        .footer-bottom-links a:hover {
            color: white;
        }

        @media (max-width: 900px) {
            .course-info-container, .details-section {
                grid-template-columns: 1fr;
            }
            .nav-menu { display: none; }
            .mobile-toggle { display: block; }
        }
    </style>
</head>

<body>
    
    
    
      
        
        

         
     
        
        
        
   
            
    
    
    <!-- TOP BAR exactly from your file -->
    <div class="top-bar">
        <div class="top-bar-content">
            <span class="offer-text"><i class="fas fa-gift"></i> Special Offer: Get 50% OFF on all annual plans! Use code: LEARN50</span>
            <div class="top-bar-actions">
                <a href="#" class="login-btn">
                    <i class="fas fa-user-circle"></i> Login / Register
                </a>
            </div>
        </div>
    </div>

    <!-- NAVBAR identical to given design -->
    <nav class="navbar">
        <div class="nav-container">
            <div class="logo">
                <i class="fas fa-graduation-cap"></i>
                <span>LearnSphere</span>
            </div>
            <ul class="nav-menu">
                <li class="nav-item"><a href="#" class="nav-link"><i class="fas fa-home"></i> Home</a></li>
                <li class="nav-item"><a href="#" class="nav-link"><i class="fas fa-cogs"></i> Services</a></li>
                <li class="nav-item"><a href="#" class="nav-link"><i class="fas fa-question-circle"></i> Help</a></li>
            </ul>
            <div class="mobile-toggle"><i class="fas fa-bars"></i></div>
        </div>
    </nav>

    <!-- BREADCRUMB (looks native) -->
    <div class="breadcrumb-wrap">
        <ul class="breadcrumb">
            <li><a href="#"><i class="fas fa-home" style="margin-right: 5px;"></i>Home</a></li>
            <li><a href="#">Courses</a></li>
            <li></li>
        </ul>
    </div>
    
    
    
    <%
                
                
                int id = Integer.parseInt(request.getParameter("q"));
                  String courseName = "";
                  String courseDes="";
                  
                  int price = 0 ;
        String category = "";
        String courseFile = "";
        String status = "";
        String tag =" ";
        String h ="";
                
                
                
                try
    {
      // create our mysql database connection
      String myDriver = "com.mysql.cj.jdbc.Driver";
      String myUrl = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";;
      Class.forName(myDriver);
      String dbPassword = System.getenv("DB_PASSWORD");
      Connection conn = DriverManager.getConnection(myUrl, "root", dbPassword);
      
      // our SQL SELECT query. 
      // if you only need a few columns, specify them by name instead of using "*"
      String query = "SELECT * FROM courses WHERE id = "+id;

      // create the java statement
      Statement st = conn.createStatement();
      
      // execute the query, and get a java resultset
      ResultSet rs = st.executeQuery(query);
      
      // iterate through the java resultset
      while (rs.next())
      {
         id = rs.getInt("id");
        courseName = rs.getString("course_name");
        courseDes = rs.getString("course_des");
         price = rs.getInt("price");
         category = rs.getString("catagory");
         courseFile = rs.getString("course_file");
         status = rs.getString("status");
         tag = rs.getString("tag");
         h =courseDes.substring(0, 50);
         




        
       
       
      }
      
      
    }
    catch (Exception e)
    {
      System.err.println("Got an exception! ");
      System.err.println(e.getMessage());
    }
                %>

       

    <!-- MAIN COURSE INFO HERO (dynamic style as if from JSP) -->
    <div class="course-info-hero">
        <div class="course-info-container">
            <div class="info-left">
                <!-- category badge -->
                <div class="badge-group">
                    <span class="badge"><i class="fas fa-code"></i><%= id %></span>
                    <span class="badge"><i class="fas fa-video"></i> Bestseller</span>
                </div>
                <h1> <%= courseName %></h1>
                <div class="stats-row">
                    <span class="stat-item"><i class="fas fa-user-graduate"></i> <strong>5502</strong> students</span>
                    <span class="stat-item"><i class="fas fa-star" style="color: #fbbf24;"></i> <strong>4.8</strong> (593 reviews)</span>
                    <span class="stat-item"><i class="fas fa-clock"></i> <strong>32h</strong> total</span>
                </div>
               
                    <!-- dummy instructor avatar (same placeholder vibe) -->
                    
                    <div >
                            <img src="http://localhost:8080/LMS/images/<% out.print(courseFile); %>" alt="Web Development" style="width: 500px;">
                    </div>
               
            </div>
            <div class="info-right">
                <div class="price-tag"> &#8377;<%= price %>  </div>
                <div class="price-info"><i class="fas fa-tag"></i> or 4 interest-free payments of $22.50</div>
                <button class="btn-primary"><i class="fas fa-shopping-cart"></i> Enroll now</button>
                <button class="btn-outline"><i class="far fa-heart"></i> Add to wishlist</button>
                <div class="includes-box">
                    <h4>This course includes:</h4>
                    <ul>
                        <li><i class="fas fa-play-circle"></i> 32 hours on-demand video</li>
                        <li><i class="fas fa-file-alt"></i> 85 articles</li>
                        <li><i class="fas fa-trophy"></i> Certificate of completion</li>
                        <li><i class="fas fa-mobile-alt"></i> Access on mobile & TV</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
                    
                    

    <!-- DETAILS + CURRICULUM + SIDEBAR (like courseinfo.jsp) -->
    <div class="details-section">
        <!-- left column with tabs -->
        <div class="details-tabs">
            <div class="tab-headers">
                <button class="tab-btn active" id="tab1-btn">Overview</button>
                <button class="tab-btn" id="tab2-btn">Curriculum</button>
                <button class="tab-btn" id="tab3-btn">Instructor</button>
            </div>
            <!-- Overview pane -->
            <div class="tab-pane active" id="pane1">
                <h3>About this course</h3>
                <p class="desc-text"> <%= courseDes %></p>
                <p class="desc-text">By the end of this course, you'll be able to build any website you can imagine and start your career as a professional web developer. Includes 75+ hours of video, coding challenges, and quizzes.</p>
                <h3 style="margin: 30px 0 15px;">What you'll learn</h3>
                <ul style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; list-style: none;">
                    <li><i class="fas fa-check-circle" style="color:#22c55e;"></i> Build responsive websites</li>
                    <li><i class="fas fa-check-circle" style="color:#22c55e;"></i> Master modern JavaScript</li>
                    <li><i class="fas fa-check-circle" style="color:#22c55e;"></i> React & Node.js</li>
                    <li><i class="fas fa-check-circle" style="color:#22c55e;"></i> Database integration</li>
                    <li><i class="fas fa-check-circle" style="color:#22c55e;"></i> Deploy to cloud</li>
                </ul>
            </div>
            <!-- Curriculum pane -->
            <div class="tab-pane" id="pane2">
                <h3>Course curriculum (12 sections)</h3>
                <ul class="curriculum-list">
                    <li><i class="fas fa-laptop-code"></i> <strong>Section 1:</strong> HTML & semantics (3h 15m)</li>
                    <li><i class="fas fa-laptop-code"></i> <strong>Section 2:</strong> CSS fundamentals & Flexbox (4h)</li>
                    <li><i class="fas fa-laptop-code"></i> <strong>Section 3:</strong> JavaScript basics (6h 20m)</li>
                    <li><i class="fas fa-laptop-code"></i> <strong>Section 4:</strong> DOM manipulation (2h 45m)</li>
                    <li><i class="fas fa-laptop-code"></i> <strong>Section 5:</strong> Responsive design (3h)</li>
                    <li><i class="fas fa-laptop-code"></i> <strong>Section 6:</strong> Git & GitHub (2h)</li>
                    <li><i class="fas fa-laptop-code"></i> <strong>Section 7:</strong> React introduction (5h)</li>
                </ul>
            </div>
            <!-- Instructor pane -->
            <div class="tab-pane" id="pane3">
                <h3>Meet your instructor</h3>
                <div class="instructor-card">
                    <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='100' height='100' viewBox='0 0 100 100'%3E%3Ccircle cx='50' cy='50' r='50' fill='%232563eb'/%3E%3Ctext x='50' y='70' font-size='44' text-anchor='middle' fill='white' dy='.3em'%3E?%3C/text%3E%3C/svg%3E" alt="instructor">
                    <div>
                        <h4 style="font-size: 1.3rem;">Sarah Johnson</h4>
                        <p style="color: #2563eb; margin-bottom: 8px;">Lead developer at TechCorp � 12 years exp</p>
                        <p>Sarah has taught over 500,000 students worldwide. She is known for her clear, engaging teaching style and real?world projects. She holds a CS degree from Stanford and previously worked at Google.</p>
                    </div>
                </div>
            </div>
        </div>
        <!-- right column sidebar (related, extra) -->
        <div>
            <div class="sidebar-card">
                <h3>You might also like</h3>
                <div class="related-course">
                    <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='70' height='70' viewBox='0 0 70 70'%3E%3Crect width='70' height='70' fill='%23e2e8f0'/%3E%3Ctext x='35' y='44' font-size='16' text-anchor='middle' fill='%233b82f6' dy='.3em'%3E?%3C/text%3E%3C/svg%3E" alt="course">
                    <div><h4>React Native mobile</h4><p>$49.99</p></div>
                </div>
                <div class="related-course">
                    <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='70' height='70' viewBox='0 0 70 70'%3E%3Crect width='70' height='70' fill='%23e2e8f0'/%3E%3Ctext x='35' y='44' font-size='16' text-anchor='middle' fill='%233b82f6' dy='.3em'%3E?%3C/text%3E%3C/svg%3E" alt="course">
                    <div><h4>Python data science</h4><p>$79.99</p></div>
                </div>
            </div>
            <div class="sidebar-card">
                <h3>Money-back guarantee</h3>
                <p style="display: flex; gap: 10px;"><i class="fas fa-shield-alt" style="color: #3b82f6; font-size: 2rem;"></i> 30-day satisfaction guarantee. If you're not happy, get a full refund.</p>
            </div>
        </div>
    </div>

    <!-- FOOTER exact copy from your file -->
    <footer class="footer">
        <div class="footer-container">
            <div class="footer-section">
                <div class="footer-logo"><i class="fas fa-graduation-cap"></i><span>LearnSphere</span></div>
                <p class="footer-description">LearnSphere is a leading online learning platform that provides high-quality courses from industry experts to learners worldwide.</p>
                <div class="social-icons">
                    <a href="#"><i class="fab fa-facebook-f"></i></a><a href="#"><i class="fab fa-twitter"></i></a><a href="#"><i class="fab fa-instagram"></i></a><a href="#"><i class="fab fa-linkedin-in"></i></a><a href="#"><i class="fab fa-youtube"></i></a>
                </div>
            </div>
            <div class="footer-section"><h3 class="footer-heading">Quick Links</h3><ul class="footer-links"><li><a href="#"><i class="fas fa-chevron-right"></i> Home</a></li><li><a href="#"><i class="fas fa-chevron-right"></i> About Us</a></li><li><a href="#"><i class="fas fa-chevron-right"></i> Courses</a></li><li><a href="#"><i class="fas fa-chevron-right"></i> Instructors</a></li><li><a href="#"><i class="fas fa-chevron-right"></i> Pricing</a></li></ul></div>
            <div class="footer-section"><h3 class="footer-heading">Services</h3><ul class="footer-links"><li><a href="#"><i class="fas fa-chevron-right"></i> Corporate Training</a></li><li><a href="#"><i class="fas fa-chevron-right"></i> Academic Partners</a></li><li><a href="#"><i class="fas fa-chevron-right"></i> Custom Courses</a></li><li><a href="#"><i class="fas fa-chevron-right"></i> Certification</a></li><li><a href="#"><i class="fas fa-chevron-right"></i> Career Support</a></li></ul></div>
            <div class="footer-section"><h3 class="footer-heading">Contact Us</h3><ul class="footer-contact"><li><i class="fas fa-map-marker-alt"></i> 123 Learning Street, Education City, EC 10101</li><li><i class="fas fa-phone"></i> +1 (555) 123-4567</li><li><i class="fas fa-envelope"></i> support@learnsphere.com</li><li><i class="fas fa-clock"></i> Mon-Fri: 9:00 AM - 6:00 PM</li></ul></div>
        </div>
        <div class="footer-bottom"><div class="footer-bottom-content"><p>� 2023 LearnSphere Learning Management System. All Rights Reserved.</p><div class="footer-bottom-links"><a href="#">Privacy Policy</a><a href="#">Terms of Service</a><a href="#">Cookie Policy</a></div></div></div>
    </footer>

    <!-- tiny vanilla js for tabs (similar to style) -->
    <script>
        (function() {
            const tab1 = document.getElementById('tab1-btn');
            const tab2 = document.getElementById('tab2-btn');
            const tab3 = document.getElementById('tab3-btn');
            const pane1 = document.getElementById('pane1');
            const pane2 = document.getElementById('pane2');
            const pane3 = document.getElementById('pane3');

            function setActive(index) {
                [tab1, tab2, tab3].forEach((btn, i) => {
                    if (i === index) btn.classList.add('active');
                    else btn.classList.remove('active');
                });
                [pane1, pane2, pane3].forEach((pane, i) => {
                    if (i === index) pane.classList.add('active');
                    else pane.classList.remove('active');
                });
            }

            tab1.addEventListener('click', (e) => { e.preventDefault(); setActive(0); });
            tab2.addEventListener('click', (e) => { e.preventDefault(); setActive(1); });
            tab3.addEventListener('click', (e) => { e.preventDefault(); setActive(2); });
        })();
    </script>
    <!-- you could add tilt but not needed for this page -->
</body>
</html>
