<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The LearnSphere Gazette - Learning Management System</title>

    <!-- External Libraries -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/vanilla-tilt/1.7.2/vanilla-tilt.min.js"></script>

    <!-- Newspaper Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=Crimson+Text:ital,wght@0,400;0,700;1,400&family=Special+Elite&display=swap" rel="stylesheet">

    <style>
        /* Newspaper Color Palette */
        :root {
            --paper: #f4f1ea;
            --ink: #1a1a1a;
            --accent-red: #8b0000;
            --border-ink: #333333;
            --faded-ink: #555555;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            background-color: var(--paper);
            background-image: url('https://www.transparenttextures.com/patterns/paper-fibers.png');
            color: var(--ink);
            font-family: 'Crimson Text', serif;
            line-height: 1.6;
        }

        /* Top Bar Ticker Style */
        .top-bar {
            background: var(--ink);
            color: var(--paper);
            padding: 8px 0;
            border-bottom: 2px solid var(--accent-red);
        }
        .top-bar-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            padding: 0 20px;
            align-items: center;
        }

        /* Typewriter Animation */
        .typewriter {
            font-family: 'Special Elite', cursive;
            display: inline-block;
            overflow: hidden;
            white-space: nowrap;
            border-right: .15em solid var(--accent-red);
            animation: typing 4s steps(40, end) infinite, blink-caret .75s step-end infinite;
        }
        @keyframes typing { from { width: 0 } to { width: 100% } }
        @keyframes blink-caret { from, to { border-color: transparent } 50% { border-color: var(--accent-red); } }

        .login-btn {
            color: var(--paper);
            text-decoration: none;
            font-family: 'Special Elite', cursive;
            font-size: 14px;
        }

        /* Newspaper Masthead */
        .news-header {
            text-align: center;
            padding: 30px 20px;
            border-bottom: 4px double var(--ink);
            margin: 0 20px 20px 20px;
        }
        .header-meta {
            font-family: 'Special Elite', cursive;
            text-transform: uppercase;
            border-top: 1px solid var(--ink);
            border-bottom: 1px solid var(--ink);
            padding: 5px 0;
            display: flex;
            justify-content: space-between;
            font-size: 14px;
        }
        .logo-title {
            font-family: 'Playfair Display', serif;
            font-size: 70px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: -2px;
            margin: 10px 0;
        }

        /* Navbar Editorial Style */
        .navbar { border-bottom: 1px solid var(--ink); margin-bottom: 30px; }
        .nav-container { max-width: 1200px; margin: 0 auto; padding: 10px; }
        .nav-menu { display: flex; justify-content: center; list-style: none; gap: 40px; }
        .nav-link {
            text-decoration: none; color: var(--ink);
            font-family: 'Special Elite', cursive;
            font-weight: bold;
            text-transform: uppercase;
        }

        /* Hero Section Headline Style */
        .hero-section { padding: 40px 20px; max-width: 1200px; margin: 0 auto; }
        .hero-container { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; }
        .hero-title {
            font-family: 'Playfair Display', serif;
            font-size: 50px;
            line-height: 1.1;
            margin-bottom: 15px;
            border-bottom: 2px solid var(--ink);
        }
        .hero-subtitle { font-style: italic; font-size: 20px; margin-bottom: 25px; }

        .search-container {
            background: #fff;
            padding: 15px;
            border: 1px solid var(--ink);
            box-shadow: 5px 5px 0px var(--ink);
        }
        .search-input {
            width: 70%; padding: 10px; border: 1px solid #ccc;
            font-family: 'Special Elite', cursive;
        }
        .search-btn {
            width: 25%; padding: 10px; background: var(--ink);
            color: var(--paper); border: none; cursor: pointer;
            font-family: 'Special Elite', cursive;
        }

        /* Hero Image - Grayscale to Color Effect */
        .ink-wash img {
            filter: grayscale(100%) contrast(110%) sepia(20%);
            border: 1px solid var(--ink);
            padding: 5px;
            background: white;
            width: 100%;
            transition: all 0.6s ease-in-out; /* Smooth color transition */
            cursor: crosshair;
        }

        .ink-wash img:hover {
            filter: grayscale(0%) contrast(100%) sepia(0%);
            transform: scale(1.02); /* Slight pop effect */
            box-shadow: 10px 10px 0px var(--ink);
        }

        /* THREE.JS STATS SECTION */
        .stats-section {
            max-width: 1200px;
            margin: 60px auto;
            padding: 40px 20px;
            border: 2px solid var(--ink);
            background: rgba(255,255,255,0.5);
            display: grid;
            grid-template-columns: 1fr 1.5fr;
            gap: 40px;
        }
        .stats-text h2 { font-size: 32px; margin-bottom: 20px; text-decoration: underline; }
        .stats-text ul { padding-left: 20px; font-family: 'Crimson Text', serif; font-size: 18px; }
        .stats-text li { margin-bottom: 15px; }

        #three-canvas-container {
            height: 400px;
            background: #eeeae0;
            border: 1px solid var(--ink);
            position: relative;
        }

        /* Course Cards Redesign */
        .courses-section { max-width: 1200px; margin: 0 auto; padding: 40px 20px; }
        .courses-container { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
        .course-card {
            background: white; border: 1px solid var(--ink);
            padding: 10px; transition: all 0.3s;
        }
        .course-card:hover { transform: translateY(-5px); box-shadow: 8px 8px 0px var(--ink); }
        .course-image img { width: 100%; height: 150px; object-fit: cover; filter: grayscale(50%); }
        .course-title { font-family: 'Playfair Display', serif; font-size: 20px; margin: 10px 0; }
        .read-more-btn {
            display: block; text-align: center; background: var(--ink);
            color: var(--paper); text-decoration: none; padding: 10px;
            font-family: 'Special Elite', cursive; font-size: 12px; margin-top: 10px;
        }

        /* Footer */
        .footer {
            border-top: 4px double var(--ink);
            margin-top: 50px;
            padding: 40px 20px;
            text-align: center;
            background: var(--paper);
        }

        /* =========================
           RESPONSIVE DESIGN
        ========================= */

        /* Tablet */
        @media (max-width: 992px) {

            .hero-container {
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .stats-section {
                grid-template-columns: 1fr;
            }

            .courses-container {
                grid-template-columns: repeat(2, 1fr);
            }

            .logo-title {
                font-size: 50px;
            }

            .hero-title {
                font-size: 36px;
            }

            .nav-menu {
                gap: 20px;
                flex-wrap: wrap;
            }
        }

        /* Mobile */
        @media (max-width: 600px) {

            body {
                font-size: 14px;
            }

            .top-bar-content {
                flex-direction: column;
                gap: 5px;
                text-align: center;
            }

            .header-meta {
                flex-direction: column;
                gap: 5px;
                text-align: center;
            }

            .logo-title {
                font-size: 32px;
                letter-spacing: 0;
            }

            .hero-title {
                font-size: 26px;
            }

            .hero-subtitle {
                font-size: 16px;
            }

            .search-container {
                display: flex;
                flex-direction: column;
                gap: 10px;
            }

            .search-input,
            .search-btn {
                width: 100%;
            }

            .nav-menu {
                flex-direction: column;
                align-items: center;
                gap: 10px;
            }

            .courses-container {
                grid-template-columns: 1fr;
            }

            .stats-section {
                padding: 20px 10px;
            }

            #three-canvas-container {
                height: 250px;
            }

            .course-image img {
                height: 120px;
            }
        }
    </style>
</head>
<body class="newspaper-theme">

    <div class="top-bar">
        <div class="top-bar-content">
            <span class="offer-text typewriter"><i class="fas fa-bullhorn"></i> EXTRA: Get 50% OFF! Use code: LEARN50</span>
            <div class="top-bar-actions">
                <a href="register-login.jsp" class="login-btn">Member Login</a>
            </div>
        </div>
    </div>

    <header class="news-header">
        <div class="header-meta">
            <span>Established 2023</span>
            <span>Edition: International</span>
            <span><%= new java.util.Date() %></span>
        </div>
        <h1 class="logo-title">LearnSphere Gazette</h1>
        <div class="header-meta" style="border-top: none;">
            <span>Weather: Bright for Knowledge</span>
            <span>Price: One Effort</span>
        </div>
    </header>

    <nav class="navbar">
        <div class="nav-container">
            <ul class="nav-menu">
                <li><a href="#" class="nav-link">About Us</a></li>
                <li><a href="all_courses.jsp" class="nav-link">All Courses</a></li>
                <li><a href="#" class="nav-link">Help Desk</a></li>
            </ul>
        </div>
    </nav>

    <section class="hero-section">
        <div class="hero-container">
            <div class="hero-content">
                <h2 class="hero-title">A NEW AGE OF SCHOLARSHIP ARRIVES</h2>
                <p class="hero-subtitle">"Learn anything, anytime, anywhere. 5000+ reports from industry titans."</p>
                <div class="search-container">
                    <input type="text" class="search-input" placeholder="Search Archives...">
                    <button class="search-btn">Find</button>
                </div>
            </div>
            <!-- Modified Hero Image Class for Grayscale Effect -->
            <div class="hero-image ink-wash">
                <img src="https://images.pexels.com/photos/20432872/pexels-photo-20432872.jpeg" alt="Historical Education">
            </div>
        </div>
    </section>

    <!-- NEW SECTION: WHY WE USE THREE.JS -->
    <section class="stats-section">
        <div class="stats-text">
            <h2>REVOLUTIONIZING DATA VISUALIZATION</h2>
            <p>While this newspaper theme honors the past, our technology looks to the future. We utilize <strong>Three.js</strong> for our responsive statistics because:</p>
            <ul>
                <li><strong>Interactive Narratives:</strong> Static 2D charts are "flat." Three.js allows learners to interact with data in 3D space, increasing engagement.</li>
                <li><strong>GPU Acceleration:</strong> By using the device's graphics processor, we render thousands of data points smoothly without slowing down the browser.</li>
                <li><strong>Responsive Visuals:</strong> 3D models automatically adjust perspective based on screen size, ensuring a perfect view on mobile or desktop.</li>
            </ul>
        </div>
        <div id="three-canvas-container">
            <!-- Three.js Visualizations render here -->
        </div>
    </section>

    <%@include file="languages.jsp" %>

    <!-- Course Section with Integrated Backend Logic -->
    <section class="courses-section">
        <h2 style="font-family: 'Playfair Display'; font-size: 35px; border-bottom: 2px solid #000; margin-bottom: 20px;">LATEST CLASSIFIEDS</h2>
        <div class="courses-container">
            <%
                Connection conn = null;
                Statement st = null;
                ResultSet rs = null;
                try {
                    String myDriver = "com.mysql.cj.jdbc.Driver";
                    String myUrl = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
                    Class.forName(myDriver);
                    String dbPassword = System.getenv("DB_PASSWORD");
                    conn = DriverManager.getConnection(myUrl, "root", dbPassword != null ? dbPassword : "");

                    String query = "SELECT * FROM courses ORDER BY id DESC LIMIT 4";
                    st = conn.createStatement();
                    rs = st.executeQuery(query);

                    while (rs.next()) {
                        int id = rs.getInt("id");
                        String courseName = rs.getString("course_name");
                        String courseDes = rs.getString("course_des");
                        String courseFile = rs.getString("course_file");
                        String img = (courseFile != null && !courseFile.isEmpty()) ? courseFile : "default.png";
            %>
            <div class="course-card" data-tilt>
                <div class="course-image">
                    <img src="<%= request.getContextPath() %>/images/<%= img %>" alt="Course Image">
                </div>
                <div class="course-content">
                    <h3 class="course-title"><%= courseName %></h3>
                    <p style="font-size: 14px;"><%= (courseDes.length() > 60) ? courseDes.substring(0, 60) + "..." : courseDes %></p>
                    <a href="course_info.jsp?q=<%= id %>" class="read-more-btn">DISCOVER MORE</a>
                </div>
            </div>
            <%
                    }
                } catch (Exception e) {
                    out.println("<p>Archives unavailable: " + e.getMessage() + "</p>");
                } finally {
                    if (rs != null) rs.close();
                    if (st != null) st.close();
                    if (conn != null) conn.close();
                }
            %>
        </div>
    </section>

    <footer class="footer">
        <p>&copy; 2023 LearnSphere Gazette - All Rights Reserved. Printed in Digital Format.</p>
        <div style="margin-top: 10px; font-family: 'Special Elite';">
            <a href="#">Privacy</a> | <a href="#">Terms</a> | <a href="#">Archives</a>
        </div>
    </footer>

    <script>
        // --- THREE.JS LOGIC FOR RESPONSIVE STATISTICS ---
        function initThreeJS() {
            const container = document.getElementById('three-canvas-container');
            if(!container) return;

            const scene = new THREE.Scene();
            const camera = new THREE.PerspectiveCamera(75, container.clientWidth / container.clientHeight, 0.1, 1000);
            const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
            renderer.setSize(container.clientWidth, container.clientHeight);
            container.appendChild(renderer.domElement);

            // Create 3D Bars representing learning statistics
            const dataHeights = [3, 7, 5, 9, 4];
            const bars = [];
            dataHeights.forEach((h, i) => {
                const geometry = new THREE.BoxGeometry(0.8, h, 0.8);
                const material = new THREE.MeshPhongMaterial({ color: 0x8b0000 });
                const bar = new THREE.Mesh(geometry, material);
                bar.position.x = (i - 2) * 1.5;
                bar.position.y = h / 2;
                scene.add(bar);
                bars.push(bar);
            });

            const light = new THREE.PointLight(0xffffff, 1, 100);
            light.position.set(10, 10, 10);
            scene.add(light);
            scene.add(new THREE.AmbientLight(0xffffff, 0.5));

            camera.position.z = 10;
            camera.position.y = 5;
            camera.lookAt(0, 3, 0);

            function animate() {
                requestAnimationFrame(animate);
                bars.forEach((b, idx) => {
                    b.rotation.y += 0.01;
                    b.scale.y = 1 + Math.sin(Date.now() * 0.002 + idx) * 0.1;
                });
                renderer.render(scene, camera);
            }
            animate();

            window.addEventListener('resize', () => {
                camera.aspect = container.clientWidth / container.clientHeight;
                camera.updateProjectionMatrix();
                renderer.setSize(container.clientWidth, container.clientHeight);
            });
        }

        document.addEventListener('DOMContentLoaded', () => {
            initThreeJS();
            if (typeof VanillaTilt !== 'undefined') {
                VanillaTilt.init(document.querySelectorAll(".course-card"), {
                    max: 10, speed: 400, glare: true, "max-glare": 0.1
                });
            }
        });
    </script>
</body>
</html>