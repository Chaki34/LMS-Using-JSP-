<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="java.util.regex.*" %>

<%
// ==================== BACKEND LOGIC ====================
int id = Integer.parseInt(request.getParameter("q"));

// Variables from 'courses' table
String courseName = "";
String courseDes = "";
int price = 0;
String category = "";
String courseFile = "";
String status = "";
String tag = "";
String createdAt = "";

// Variables from 'course_curriculams' table
String curriculumJson = "";
String longDescription = "";
double rating = 0.0;
String feedbacksJson = "";
int happyClients = 0;

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    String myDriver = "com.mysql.cj.jdbc.Driver";
    String myUrl = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    Class.forName(myDriver);
    String dbPassword = System.getenv("DB_PASSWORD");
    conn = DriverManager.getConnection(myUrl, "root", dbPassword);

    // JOIN Query to get data from both tables
    String query = "SELECT c.*, cc.curriculum, cc.long_description, cc.rating, cc.feedbacks, cc.happy_clients " +
                   "FROM courses c " +
                   "LEFT JOIN course_curriculams cc ON c.id = cc.course_id " +
                   "WHERE c.id = ?";

    ps = conn.prepareStatement(query);
    ps.setInt(1, id);
    rs = ps.executeQuery();

    if (rs.next()) {
        courseName = rs.getString("course_name");
        courseDes = rs.getString("course_des");
        price = rs.getInt("price");
        category = rs.getString("catagory");
        courseFile = rs.getString("course_file");
        status = rs.getString("status");
        tag = rs.getString("tag");
        createdAt = rs.getString("created_at");

        // Curriculum data
        curriculumJson = rs.getString("curriculum");
        longDescription = rs.getString("long_description");
        rating = rs.getDouble("rating");
        feedbacksJson = rs.getString("feedbacks");
        happyClients = rs.getInt("happy_clients");
    }
} catch (Exception e) {
    out.println("<h3 style='color:red;'>DATABASE ERROR: " + e.getMessage() + "</h3>");
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (ps != null) ps.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
}

List<String> curriculumList = new ArrayList<>();

if (curriculumJson != null && !curriculumJson.trim().isEmpty()) {
    try {
        String data = curriculumJson.trim();

        // ✅ Case 1: JSON format [{"title":"Intro"}]
        if (data.startsWith("[") && data.contains("title")) {
            Matcher m = Pattern.compile("\"title\"\\s*:\\s*\"(.*?)\"").matcher(data);
            while (m.find()) {
                curriculumList.add(m.group(1));
            }
        }

        // ✅ Case 2: Simple comma-separated list
       else {
                   // split by newline OR comma
                   String[] parts = data.split("\\r?\\n|,");

                   for (String part : parts) {
                       String clean = part.trim();

                       if (!clean.isEmpty()) {
                           // ✅ remove numbering like "1. Intro", "2) CSS"
                           clean = clean.replaceAll("^\\d+\\s*[.)-]?\\s*", "");

                           curriculumList.add(clean);
                       }
                   }
               }

    } catch(Exception e) {
        out.println("Curriculum Parse Error: " + e.getMessage());
    }
}

// Helper logic to parse Feedbacks: [{"name":"Rahul","comment":"Nice"}]
List<String[]> feedbackList = new ArrayList<>();
if (feedbacksJson != null && feedbacksJson.contains("comment")) {
    Matcher m = Pattern.compile("\"name\":\"(.*?)\",\"comment\":\"(.*?)\"").matcher(feedbacksJson);
    while (m.find()) { feedbackList.add(new String[]{m.group(1), m.group(2)}); }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= courseName %> - Gazette Special Report</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=Crimson+Text:ital,wght@0,400;0,700;1,400&family=Special+Elite&display=swap" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>

    <style>
        :root { --paper: #f4f1ea; --ink: #1a1a1a; --accent-red: #8b0000; }
        body { background-color: var(--paper); background-image: url('https://www.transparenttextures.com/patterns/paper-fibers.png'); color: var(--ink); font-family: 'Crimson Text', serif; margin: 0; padding: 20px; }

        .article-container { max-width: 1100px; margin: 0 auto; border: 1px solid #d3d3d3; background: #fff; padding: 40px; box-shadow: 0 0 20px rgba(0,0,0,0.05); position: relative; }
        .article-meta-top { font-family: 'Special Elite', cursive; text-transform: uppercase; border-bottom: 2px solid var(--ink); display: flex; justify-content: space-between; padding-bottom: 5px; margin-bottom: 20px; font-size: 14px; }

        .headline { font-family: 'Playfair Display', serif; font-size: 52px; font-weight: 900; line-height: 1; margin: 0 0 20px 0; text-align: center; text-transform: uppercase; }
        .sub-headline { font-family: 'Special Elite', cursive; text-align: center; border-top: 1px solid var(--ink); border-bottom: 1px solid var(--ink); padding: 10px 0; margin-bottom: 30px; font-style: italic; }

        .article-body { display: grid; grid-template-columns: 2fr 1fr; gap: 40px; }

        .featured-image-wrapper { position: relative; border: 1px solid var(--ink); padding: 5px; background: #fff; margin-bottom: 25px; }
        .featured-image-wrapper img { width: 100%; display: block; filter: grayscale(100%); transition: 0.7s; }
        .featured-image-wrapper:hover img { filter: grayscale(0%); }

        /* Sidebar info */
        .sidebar-notices { border-left: 1px solid #ccc; padding-left: 30px; }
        .notice-box { margin-bottom: 25px; border-bottom: 1px dashed #ccc; padding-bottom: 15px; }
        .notice-label { font-family: 'Special Elite', cursive; font-size: 12px; color: var(--accent-red); display: block; }
        .notice-value { font-size: 18px; font-weight: bold; display: block; }

        /* New Styles for Curriculum and Feedbacks */
        .curriculum-section { margin-top: 30px; padding: 20px; border: 1px double var(--ink); background: #fdfdfd; }
        .curriculum-title { font-family: 'Playfair Display'; font-size: 24px; border-bottom: 1px solid #000; margin-bottom: 15px; }
        .curriculum-item { font-family: 'Special Elite'; font-size: 15px; margin-bottom: 8px; border-bottom: 1px dotted #ccc; }

        .feedback-box { font-style: italic; background: #f9f9f9; padding: 10px; border-left: 3px solid var(--accent-red); margin-top: 10px; font-size: 14px; }
        .rating-gold { color: #d4af37; font-size: 20px; }

        .description-text::first-letter { float: left; font-size: 75px; line-height: 60px; padding: 4px 8px 0 3px; font-family: 'Playfair Display', serif; font-weight: 900; }
        .description-text { line-height: 1.8; font-size: 19px; text-align: justify; margin-bottom: 20px; }

        #seal-container { width: 100%; height: 150px; margin-top: 20px; border: 1px double var(--ink); background: #fdfdfd; }
        .btn-newspaper { display: inline-block; background: var(--ink); color: var(--paper); text-decoration: none; padding: 12px 25px; font-family: 'Special Elite', cursive; text-transform: uppercase; margin-top: 30px; transition: 0.3s; }
        .btn-newspaper:hover { background: var(--accent-red); }

        @media (max-width: 768px) { .article-body { grid-template-columns: 1fr; } .sidebar-notices { border-left: none; border-top: 1px solid #ccc; padding-top: 20px; } }

        /* =========================
           SMALL SCREEN (MOBILE)
        ========================= */

        @media (max-width: 600px) {

            body {
                padding: 10px;
                font-size: 14px;
            }

            .article-container {
                padding: 15px;
            }

            .article-meta-top {
                flex-direction: column;
                gap: 5px;
                text-align: center;
                font-size: 12px;
            }

            .headline {
                font-size: 28px;
                line-height: 1.2;
            }

            .sub-headline {
                font-size: 12px;
                padding: 6px 0;
            }

            /* GRID STACK */
            .article-body {
                grid-template-columns: 1fr;
                gap: 20px;
            }

            /* IMAGE */
            .featured-image-wrapper {
                margin-bottom: 15px;
            }

            /* TEXT */
            .description-text {
                font-size: 15px;
                line-height: 1.6;
            }

            .description-text::first-letter {
                font-size: 40px;
                line-height: 30px;
            }

            /* CURRICULUM */
            .curriculum-section {
                padding: 15px;
            }

            .curriculum-title {
                font-size: 18px;
            }

            .curriculum-item {
                font-size: 13px;
            }

            /* SIDEBAR */
            .sidebar-notices {
                border-left: none;
                border-top: 1px solid #ccc;
                padding-left: 0;
                padding-top: 15px;
            }

            .notice-box {
                margin-bottom: 15px;
            }

            .notice-label {
                font-size: 11px;
            }

            .notice-value {
                font-size: 16px;
            }

            /* PRICE BIG TEXT FIX */
            .notice-value[style*="32px"] {
                font-size: 22px !important;
            }

            /* FEEDBACK */
            .feedback-box {
                font-size: 12px;
            }

            /* BUTTON */
            .btn-newspaper {
                width: 100%;
                text-align: center;
                padding: 10px;
                font-size: 12px;
            }

            /* THREE JS CONTAINER */
            #seal-container {
                height: 120px;
            }

            /* SMALL FIXES */
            img {
                max-width: 100%;
                height: auto;
            }
        }

    </style>
</head>
<body>

<div class="article-container">
    <div class="article-meta-top">
        <span>Gazette Special Report</span>
        <span>File: #<%= id %></span>
        <span>Registered: <%= createdAt %></span>
    </div>

    <header>
        <h1 class="headline"><%= courseName %></h1>
        <div class="sub-headline">"Official Transcript of the <%= category %> Department"</div>
    </header>

    <div class="article-body">
        <div class="main-column">
            <div class="featured-image-wrapper">
                <img src="<%= request.getContextPath() %>/images/<%= (courseFile != null && !courseFile.isEmpty()) ? courseFile : "default.png" %>" alt="Course Archive Image">
            </div>

            <h2 style="font-family: 'Playfair Display'; border-bottom: 2px solid #000;">I. Executive Summary</h2>
            <div class="description-text"><%= courseDes %></div>

            <!-- LONG DESCRIPTION SECTION -->
            <% if(longDescription != null) { %>
                <h2 style="font-family: 'Playfair Display'; border-bottom: 2px solid #000;">II. Detailed Analysis</h2>
                <p style="line-height:1.8; text-align: justify;"><%= longDescription %></p>
            <% } %>

            <!-- CURRICULUM SECTION -->
            <% if(!curriculumList.isEmpty()) { %>
                <div class="curriculum-section">
                    <div class="curriculum-title">Training Syllabus</div>
                    <% for(String item : curriculumList) { %>
                        <div class="curriculum-item"><i class="fas fa-check-circle"></i> <%= item %></div>
                    <% } %>
                </div>
            <% } %>

            <a href="index.jsp" class="btn-newspaper"><i class="fas fa-arrow-left"></i> Return to Archives</a>

            <a href="billings.jsp?courseId=<%= id %>"
                   class="btn-newspaper"
                   style="background:#8b0000;">
                    <i class="fas fa-credit-card"></i> Buy Now
                </a>
        </div>

        <aside class="sidebar-notices">
            <div class="notice-box">
                <span class="notice-label">Public Rating</span>
                <div class="rating-gold">
                    <% for(int i=1; i<=5; i++) { %>
                        <i class="<%= (i <= rating) ? "fas" : "far" %> fa-star"></i>
                    <% } %>
                    <span style="color:black; font-size:14px;">(<%= rating %>)</span>
                </div>
            </div>

            <div class="notice-box">
                <span class="notice-label">Successful Graduates</span>
                <span class="notice-value"><i class="fas fa-user-graduate"></i> <%= happyClients %> Members</span>
            </div>

            <div class="notice-box">
                <span class="notice-label">Classification</span>
                <span class="notice-value"><%= category %></span>
            </div>

            <div class="notice-box">
                <span class="notice-label">Access Fee</span>
                <span class="notice-value" style="font-size:32px; font-family:'Playfair Display';"><i class="fas fa-rupee-sign"></i> <%= price %></span>
            </div>

            <!-- FEEDBACK SECTION -->
            <% if(!feedbackList.isEmpty()) { %>
            <div class="notice-box">
                <span class="notice-label">Letters to the Editor</span>
                <% for(String[] fb : feedbackList) { %>
                    <div class="feedback-box">
                        <strong><%= fb[0] %>:</strong> "<%= fb[1] %>"
                    </div>
                <% } %>
            </div>
            <% } %>

            <div class="notice-box">
                <span class="notice-label">Status</span>
                <span class="notice-value" style="color: <%= "active".equalsIgnoreCase(status) ? "green" : "red" %>">
                    <i class="fas fa-certificate"></i> <%= status.toUpperCase() %>
                </span>
            </div>

            <div class="notice-label" style="margin-top: 20px;">Institutional Seal</div>
            <div id="seal-container"></div>
            <p style="font-family: 'Special Elite'; font-size: 10px; text-align: center; margin-top: 5px;">Interactive 3D Knowledge Core</p>
        </aside>
    </div>
</div>

<script>
    function initSeal() {
        const container = document.getElementById('seal-container');
        const scene = new THREE.Scene();
        const camera = new THREE.PerspectiveCamera(45, container.clientWidth / container.clientHeight, 0.1, 1000);
        const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
        renderer.setSize(container.clientWidth, container.clientHeight);
        container.appendChild(renderer.domElement);

        const geometry = new THREE.IcosahedronGeometry(2, 0);
        const material = new THREE.MeshPhongMaterial({ color: 0x1a1a1a, wireframe: true, emissive: 0x8b0000, emissiveIntensity: 0.2 });
        const orb = new THREE.Mesh(geometry, material);
        scene.add(orb);

        const light = new THREE.PointLight(0xffffff, 1, 100);
        light.position.set(5, 5, 5);
        scene.add(light);
        scene.add(new THREE.AmbientLight(0xffffff, 0.5));
        camera.position.z = 6;

        function animate() {
            requestAnimationFrame(animate);
            orb.rotation.x += 0.005; orb.rotation.y += 0.01;
            renderer.render(scene, camera);
        }
        animate();
    }
    document.addEventListener('DOMContentLoaded', initSeal);
</script>
</body>
</html>