<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>

<%
// ==================== BACKEND LOGIC (UNTOUCHED) ====================
int id = Integer.parseInt(request.getParameter("q"));

String courseName = "";
String courseDes = "";
int price = 0;
String category = "";
String courseFile = "";
String status = "";
String tag = "";
String createdAt = "";

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    String myDriver = "com.mysql.cj.jdbc.Driver";
    String myUrl = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    Class.forName(myDriver);
    String dbPassword = System.getenv("DB_PASSWORD");
    conn = DriverManager.getConnection(myUrl, "root", dbPassword);

    String query = "SELECT * FROM courses WHERE id=?";
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
    }
} catch (Exception e) {
    out.println("<h3 style='color:red;'>ERROR: " + e.getMessage() + "</h3>");
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
    <title><%= courseName %> - Gazette Special Report</title>

    <!-- External Fonts and Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=Crimson+Text:ital,wght@0,400;0,700;1,400&family=Special+Elite&display=swap" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>

    <style>
        :root {
            --paper: #f4f1ea;
            --ink: #1a1a1a;
            --accent-red: #8b0000;
        }

        body {
            background-color: var(--paper);
            background-image: url('https://www.transparenttextures.com/patterns/paper-fibers.png');
            color: var(--ink);
            font-family: 'Crimson Text', serif;
            margin: 0;
            padding: 20px;
        }

        /* Newspaper Article Container */
        .article-container {
            max-width: 1100px;
            margin: 0 auto;
            border: 1px solid #d3d3d3;
            background: #fff;
            padding: 40px;
            box-shadow: 0 0 20px rgba(0,0,0,0.05);
            position: relative;
        }

        /* Masthead / Top meta */
        .article-meta-top {
            font-family: 'Special Elite', cursive;
            text-transform: uppercase;
            border-bottom: 2px solid var(--ink);
            display: flex;
            justify-content: space-between;
            padding-bottom: 5px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        /* Headlines */
        .headline {
            font-family: 'Playfair Display', serif;
            font-size: 52px;
            font-weight: 900;
            line-height: 1;
            margin: 0 0 20px 0;
            text-align: center;
            text-transform: uppercase;
        }

        .sub-headline {
            font-family: 'Special Elite', cursive;
            text-align: center;
            border-top: 1px solid var(--ink);
            border-bottom: 1px solid var(--ink);
            padding: 10px 0;
            margin-bottom: 30px;
            font-style: italic;
        }

        /* Layout Grid */
        .article-body {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 40px;
        }

        /* Image Grayscale to Color Effect */
        .featured-image-wrapper {
            position: relative;
            border: 1px solid var(--ink);
            padding: 5px;
            background: #fff;
            margin-bottom: 25px;
        }

        .featured-image-wrapper img {
            width: 100%;
            display: block;
            filter: grayscale(100%) contrast(110%);
            transition: all 0.7s ease-in-out;
        }

        .featured-image-wrapper:hover img {
            filter: grayscale(0%) contrast(100%);
        }

        /* Sidebar info */
        .sidebar-notices {
            border-left: 1px solid #ccc;
            padding-left: 30px;
        }

        .notice-box {
            margin-bottom: 25px;
            border-bottom: 1px dashed #ccc;
            padding-bottom: 15px;
        }

        .notice-label {
            font-family: 'Special Elite', cursive;
            font-size: 12px;
            color: var(--accent-red);
            display: block;
        }

        .notice-value {
            font-size: 18px;
            font-weight: bold;
            display: block;
        }

        .price-tag {
            font-size: 32px;
            font-family: 'Playfair Display', serif;
            color: var(--ink);
        }

        /* Drop cap for description */
        .description-text::first-letter {
            float: left;
            font-size: 75px;
            line-height: 60px;
            padding-top: 4px;
            padding-right: 8px;
            padding-left: 3px;
            font-family: 'Playfair Display', serif;
            font-weight: 900;
        }

        .description-text {
            line-height: 1.8;
            font-size: 19px;
            text-align: justify;
        }

        /* Three.js Knowledge Orb Container */
        #seal-container {
            width: 100%;
            height: 150px;
            margin-top: 20px;
            border: 1px double var(--ink);
            background: #fdfdfd;
        }

        /* Back Button */
        .btn-newspaper {
            display: inline-block;
            background: var(--ink);
            color: var(--paper);
            text-decoration: none;
            padding: 12px 25px;
            font-family: 'Special Elite', cursive;
            text-transform: uppercase;
            margin-top: 30px;
            transition: 0.3s;
        }

        .btn-newspaper:hover {
            background: var(--accent-red);
        }

        @media (max-width: 768px) {
            .article-body { grid-template-columns: 1fr; }
            .sidebar-notices { border-left: none; padding-left: 0; border-top: 1px solid #ccc; padding-top: 20px; }
            .headline { font-size: 36px; }
        }
    </style>
</head>
<body>

<div class="article-container">
    <div class="article-meta-top">
        <span>Gazette Special Report</span>
        <span>File ID: #<%= id %></span>
        <span>Registered: <%= createdAt %></span>
    </div>

    <header>
        <h1 class="headline"><%= courseName %></h1>
        <div class="sub-headline">
            "A Comprehensive Inquiry into the Field of <%= category %>"
        </div>
    </header>

    <div class="article-body">
        <div class="main-column">
            <div class="featured-image-wrapper">
                <img src="<%= request.getContextPath() %>/images/<%= (courseFile != null && !courseFile.isEmpty()) ? courseFile : "default.png" %>" alt="Course Archive Image">
            </div>

            <h2 style="font-family: 'Playfair Display'; border-bottom: 2px solid #000;">Full Transcript</h2>
            <div class="description-text">
                <%= courseDes %>
            </div>

            <a href="index.jsp" class="btn-newspaper">
                <i class="fas fa-arrow-left"></i> Return to Archives
            </a>
        </div>

        <aside class="sidebar-notices">
            <div class="notice-box">
                <span class="notice-label">Classification</span>
                <span class="notice-value"><%= category %></span>
            </div>

            <div class="notice-box">
                <span class="notice-label">Access Fee</span>
                <span class="notice-value price-tag"><i class="fas fa-rupee-sign"></i> <%= price %></span>
            </div>

            <div class="notice-box">
                <span class="notice-label">Verification Status</span>
                <span class="notice-value" style="color: <%= "active".equalsIgnoreCase(status) ? "green" : "red" %>">
                    <i class="fas fa-certificate"></i> <%= status.toUpperCase() %>
                </span>
            </div>

            <div class="notice-box">
                <span class="notice-label">Keywords & Tags</span>
                <span class="notice-value" style="font-size: 14px; font-style: italic;">#<%= tag.replace(" ", " #") %></span>
            </div>

            <!-- THREE.JS SEAL -->
            <div class="notice-label" style="margin-top: 20px;">Institutional Seal</div>
            <div id="seal-container"></div>
            <p style="font-family: 'Special Elite'; font-size: 10px; text-align: center; margin-top: 5px;">
                Interactive 3D Knowledge Core
            </p>
        </aside>
    </div>
</div>

<script>
    // --- THREE.JS SEAL ANIMATION ---
    function initSeal() {
        const container = document.getElementById('seal-container');
        const scene = new THREE.Scene();
        const camera = new THREE.PerspectiveCamera(45, container.clientWidth / container.clientHeight, 0.1, 1000);
        const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });

        renderer.setSize(container.clientWidth, container.clientHeight);
        container.appendChild(renderer.domElement);

        // Create a geometric 'Knowledge Orb' (Icosahedron)
        const geometry = new THREE.IcosahedronGeometry(2, 0);
        const material = new THREE.MeshPhongMaterial({
            color: 0x1a1a1a,
            wireframe: true,
            emissive: 0x8b0000,
            emissiveIntensity: 0.2
        });
        const orb = new THREE.Mesh(geometry, material);
        scene.add(orb);

        const light = new THREE.PointLight(0xffffff, 1, 100);
        light.position.set(5, 5, 5);
        scene.add(light);
        scene.add(new THREE.AmbientLight(0xffffff, 0.5));

        camera.position.z = 6;

        function animate() {
            requestAnimationFrame(animate);
            orb.rotation.x += 0.005;
            orb.rotation.y += 0.01;
            renderer.render(scene, camera);
        }
        animate();

        window.addEventListener('resize', () => {
            camera.aspect = container.clientWidth / container.clientHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(container.clientWidth, container.clientHeight);
        });
    }

    document.addEventListener('DOMContentLoaded', initSeal);
</script>

</body>
</html>