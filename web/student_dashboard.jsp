<!DOCTYPE html>
<html lang="en">
<%@ page import="java.sql.*" %>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.5">
    <title>The Chronicle · Student Dashboard</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=Crimson+Text:ital,wght@0,400;0,600;0,700;1,400;1,600&family=Playfair+Display:wght@700;900&family=Special+Elite&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

<%@ page import="java.sql.*" %>

<%
Integer userId = (Integer) session.getAttribute("userId");

String profileImage = "default.png";
String phone = "";
String address = "";
String bio = "";
boolean profileExists = false;

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

if (userId != null) {
    try {
        // 1. Load Driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // 2. Connect DB
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
            "root",
            System.getenv("DB_PASSWORD")
        );

        // 3. Query
        ps = conn.prepareStatement(
            "SELECT profile_image, phone, address, bio FROM user_profiles WHERE user_id=?"
        );
        ps.setInt(1, userId);

        rs = ps.executeQuery();

        if (rs.next()) {
            profileExists = true;

            profileImage = rs.getString("profile_image");
            if (profileImage == null || profileImage.trim().isEmpty()) {
                profileImage = "default.png";
            }

            phone = rs.getString("phone");
            address = rs.getString("address");
            bio = rs.getString("bio");

            if (phone == null) phone = "";
            if (address == null) address = "";
            if (bio == null) bio = "";
        }

    } catch (Exception e) {
        out.print("DB ERROR: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch(Exception e) {}
        try { if (ps != null) ps.close(); } catch(Exception e) {}
        try { if (conn != null) conn.close(); } catch(Exception e) {}
    }
}
%>

<style>
        :root {
            --paper: #f4f1ea;
            --ink: #1a1a1a;
            --accent-red: #8b0000;
            --border-ink: #333333;
            --faded-ink: #555555;
            --sidebar-width: 280px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            background-color: var(--paper);
            background-image: url('https://www.transparenttextures.com/patterns/paper-fibers.png');
            color: var(--ink);
            font-family: 'Crimson Text', serif;
            line-height: 1.6;
            display: flex;
            min-height: 100vh;
        }

        .dashboard-sidebar {
            width: var(--sidebar-width);
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(2px);
            border-right: 2px solid var(--ink);
            display: flex;
            flex-direction: column;
            padding: 24px 0;
        }

        .sidebar-header { padding: 0 20px 20px; border-bottom: 1px dashed var(--ink); margin-bottom: 20px; }

        .sidebar-masthead {
            font-family: 'Playfair Display', serif;
            font-size: 24px;
            font-weight: 900;
        }

        .sidebar-masthead small {
            display: block;
            font-family: 'Special Elite', cursive;
            font-size: 10px;
            color: var(--accent-red);
        }

        .student-badge { margin-top: 16px; display: flex; gap: 12px; }

        .student-avatar {
            width: 48px; height: 48px;
            border-radius: 50%;
            border: 2px solid var(--ink);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .sidebar-nav { flex: 1; padding: 10px; }

        .nav-item {
            display: flex;
            gap: 14px;
            padding: 14px;
            text-decoration: none;
            color: var(--ink);
            font-family: 'Special Elite', cursive;
        }

        .nav-item:hover {
            background: var(--ink);
            color: var(--paper);
        }

        .dashboard-main { flex: 1; padding: 20px 30px; }

        .top-ticker {
            background: var(--ink);
            color: var(--paper);
            padding: 8px 16px;
            display: flex;
            justify-content: space-between;
            font-family: 'Special Elite', cursive;
        }

        .section-title {
            font-family: 'Playfair Display', serif;
            font-size: 32px;
            border-bottom: 3px double var(--ink);
            margin: 30px 0 20px;
        }

        .analytics-grid {
            display: grid;
            grid-template-columns: 1.2fr 1.8fr;
            gap: 24px;
        }

        .progress-card, .chart-container {
            background: white;
            border: 1px solid var(--ink);
            padding: 20px;
        }

        .big-number {
            font-size: 56px;
            font-family: 'Playfair Display', serif;
            color: var(--accent-red);
        }

        .courses-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 20px;
        }

        .course-card {
            background: white;
            border: 1px solid var(--ink);
            padding: 14px;
        }

        .status-badge {
            font-family: 'Special Elite', cursive;
            font-size: 12px;
            margin-top: 10px;
        }

        .tools-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
        }

        .tool-item {
            background: white;
            border: 1px solid var(--ink);
            padding: 16px;
            text-align: center;
        }

        @media(max-width:900px){
            body{flex-direction:column;}
            .analytics-grid{grid-template-columns:1fr;}
            .tools-grid{grid-template-columns:1fr 1fr;}
        }
    </style>
</head>

<body>

<aside class="dashboard-sidebar">
    <div class="sidebar-header">
        <div class="sidebar-masthead">
            <h3>Learners</h3>
            <small>· SLOW BUT STEADY WON THE RACE ! ·</small>
        </div>

        <div class="student-badge">
           <div class="student-avatar" onclick="openProfileModal()" style="cursor:pointer;">
             <img
                 src="images/<%= (profileImage == null || profileImage.trim().isEmpty()) ? "default.png" : profileImage %>"
                 style="
                     width: 70px;
                     height: 70px;
                     border-radius: 51%;
                     border: 3px solid #1a1a1a;
                     object-fit: cover;
                     transition: 0.3s;
                     cursor: pointer;
                 "
                 onmouseover="this.style.transform='scale(1.05)'"
                 onmouseout="this.style.transform='scale(1)'"
             >
           </div>
            <div>
                <h4><%= session.getAttribute("fullname") != null ? session.getAttribute("fullname") : "Guest User" %></h4>
                <p>
                  <!-- LOCATION (ADDRESS) -->
                    <p style="
                        font-size: 12px;
                        color: red;
                        margin-top: 4px;
                        display: flex;
                        align-items: center;
                        gap: 6px;
                    ">
                         <%= (address == null || address.trim().isEmpty()) ? "No location set" : address %>
                    </p>
                    <%
                        String role = (String) session.getAttribute("role");
                        if (role == null) {
                            out.print("UNKNOWN");
                        } else if ("student".equalsIgnoreCase(role)) {
                            out.print("STUDENT | LEARNER");
                        }                     %>
                </p>
            </div>
        </div>
    </div>

    <nav class="sidebar-nav">
        <a class="nav-item" href="#">Dashboard</a>
        <a class="nav-item" href="#">Courses</a>
        <a class="nav-item" href="#">Analytics</a>
        <a class="nav-item" href="logout.jsp">LOG OUT</a>
    </nav>
</aside>

<main class="dashboard-main">

    <div class="top-ticker">
        <span>SPRING SEMESTER</span>
        <span>📰 LIVE DASHBOARD</span>
        <span>3 alerts</span>
    </div>

    <h2 class="section-title">Progress Analytics</h2>

    <div class="analytics-grid">
        <div class="progress-card">
            <span class="big-number">72%</span>
            <p>Overall completion</p>
        </div>

        <div class="chart-container">
            <canvas id="progressChart"></canvas>
        </div>
    </div>

    <h2 class="section-title">Enrolled Courses</h2>
    <div class="courses-grid" id="coursesContainer"></div>

    <h2 class="section-title">Tools</h2>
    <div class="tools-grid">
        <a href="resources.jsp" style="text-decoration:none; color:inherit;">
            <div class="tool-item">Library</div>
        </a>
        <a href="planner.jsp" style="text-decoration:none; color:inherit;">
            <div class="tool-item">Planner</div>
        </a>
        <a href="messages.jsp" style="text-decoration:none; color:inherit;">
            <div class="tool-item">Messages</div>
        </a>
    </div>

    <div id="profileModal"
    style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;
    background:rgba(0,0,0,0.75);z-index:9999;backdrop-filter:blur(5px);">

        <div style="
            background:#ffffff;
            width:420px;
            margin:6% auto;
            padding:25px;
            border-radius:12px;
            box-shadow:0 10px 40px rgba(0,0,0,0.4);
            font-family:'Arial',sans-serif;
            position:relative;
        ">

            <!-- HEADER -->
            <h2 style="
                margin:0 0 15px 0;
                font-size:22px;
                text-align:center;
                color:#1a1a1a;
                border-bottom:2px solid #eee;
                padding-bottom:10px;
            ">
                My Profile
            </h2>

            <!-- PROFILE IMAGE -->
            <div style="text-align:center;margin-bottom:15px;">
                <img
                    src="images/<%= (profileImage == null || profileImage.trim().isEmpty()) ? "default.png" : profileImage %>"
                    style="
                        width:90px;
                        height:90px;
                        border-radius:50%;
                        border:3px solid #1a1a1a;
                        object-fit:cover;
                    "
                >
            </div>

            <form method="post" action="saveProfile.jsp" enctype="multipart/form-data">

                <!-- UPLOAD -->
                <label style="font-weight:bold;font-size:13px;">Change Profile Image</label><br>
                <input type="file" name="profile_image" accept="image/*"
                style="
                    width:100%;
                    margin:5px 0 12px 0;
                    padding:6px;
                    border:1px solid #ccc;
                    border-radius:6px;
                ">

                <!-- NAME -->
                <div style="margin-bottom:10px;">
                    <label style="font-size:12px;color:#555;">Name</label><br>
                    <b><%= session.getAttribute("fullname") != null ? session.getAttribute("fullname") : "N/A" %></b>
                </div>

                <!-- ROLE -->
                <div style="margin-bottom:10px;">
                    <label style="font-size:12px;color:#555;">Role</label><br>
                    <b><%= session.getAttribute("role") != null ? session.getAttribute("role") : "N/A" %></b>
                </div>

                <!-- PHONE -->
                <input type="text" name="phone" placeholder="Phone"
                value="<%= phone != null ? phone : "" %>"
                style="
                    width:100%;
                    padding:10px;
                    margin-bottom:10px;
                    border:1px solid #ccc;
                    border-radius:6px;
                    outline:none;
                " required>

                <!-- ADDRESS -->
                <input type="text" name="address" placeholder="Address"
                value="<%= address != null ? address : "" %>"
                style="
                    width:100%;
                    padding:10px;
                    margin-bottom:10px;
                    border:1px solid #ccc;
                    border-radius:6px;
                    outline:none;
                " required>

                <!-- BIO -->
                <textarea name="bio" placeholder="Bio"
                style="
                    width:100%;
                    height:80px;
                    padding:10px;
                    border:1px solid #ccc;
                    border-radius:6px;
                    outline:none;
                    resize:none;
                    margin-bottom:15px;
                " required><%= bio != null ? bio : "" %></textarea>

                <!-- BUTTONS -->
                <div style="display:flex;gap:10px;">

                    <button type="submit"
                    style="
                        flex:1;
                        padding:10px;
                        background:#1a1a1a;
                        color:white;
                        border:none;
                        border-radius:6px;
                        cursor:pointer;
                        font-weight:bold;
                    ">
                        Save Profile
                    </button>

                    <button type="button" onclick="closeProfileModal()"
                    style="
                        flex:1;
                        padding:10px;
                        background:#8b0000;
                        color:white;
                        border:none;
                        border-radius:6px;
                        cursor:pointer;
                        font-weight:bold;
                    ">
                        Close
                    </button>

                </div>

            </form>


        </div>
    </div>

</main>

<script>
const courses = [
    { code: "JOUR 401", title: "Investigative Reporting", progress: 85, pending: 2 },
    { code: "HIST 312", title: "Print Media History", progress: 60, pending: 3 },
    { code: "ENGL 210", title: "Literary Journalism", progress: 92, pending: 0 },
    { code: "DATA 101", title: "Data Storytelling", progress: 45, pending: 4 }
];

function render() {
    var container = document.getElementById("coursesContainer");
    var html = "";

    for (var i = 0; i < courses.length; i++) {
        var c = courses[i];

        var statusText = "";
        if (c.pending === 0) {
            statusText = "✔ All caught up";
        } else {
            statusText = c.pending + " pending";
        }

        html += "<div class='course-card'>";
        html += "<b>" + c.code + "</b>";
        html += "<div>" + c.title + "</div>";
        html += "<div>Progress: " + c.progress + "%</div>";
        html += "<div class='status-badge'>" + statusText + "</div>";
        html += "</div>";
    }

    container.innerHTML = html;
}

render();

new Chart(document.getElementById("progressChart"), {
    type: "bar",
    data: {
        labels: courses.map(function(c){ return c.code; }),
        datasets: [{
            label: "Progress",
            data: courses.map(function(c){ return c.progress; }),
            backgroundColor: "#1a1a1a"
        }]
    }
});
</script>

<script>
            function openProfileModal(){
                document.getElementById("profileModal").style.display = "block";
            }

            function closeProfileModal(){
                document.getElementById("profileModal").style.display = "none";
            }
            </script>


</body>
</html>