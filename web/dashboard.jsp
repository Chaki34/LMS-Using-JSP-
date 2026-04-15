<%@ page import="java.sql.*, java.io.*, java.util.*, jakarta.servlet.http.Part" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<%
    // Database Configuration
    String DB_URL = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String DB_USER = "root";
    String dbPassword = System.getenv("DB_PASSWORD");

    String message = "";
    String errorMsg = "";
    Map<Integer, String[]> curriculumMap = new HashMap<>();

    int totalCourses = 0;
    int activeCourses = 0;
    int inactiveCourses = 0;

    StringBuilder chartData = new StringBuilder("[");
    StringBuilder labels2D = new StringBuilder("[");
    StringBuilder ratings2D = new StringBuilder("[");
    StringBuilder clients2D = new StringBuilder("[");

    String uploadPath = application.getRealPath("/") + "images";
    File dir = new File(uploadPath);
    if (!dir.exists()) dir.mkdirs();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, dbPassword);
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            String name = request.getParameter("course_name");
            String des = request.getParameter("course_des");
            String price = request.getParameter("price");
            String cat = request.getParameter("catagory");
            String status = request.getParameter("status");
            String tag = request.getParameter("tag");

            String fileNameDB = "";
            Part filePart = request.getPart("course_file");

            if (filePart != null && filePart.getSize() > 0) {
                String fileName = filePart.getSubmittedFileName();
                if (fileName.toLowerCase().endsWith(".png")) {
                    fileNameDB = System.currentTimeMillis() + "_" + fileName;
                    filePart.write(uploadPath + File.separator + fileNameDB);
                } else {
                    errorMsg = "Only PNG files allowed!";
                }
            }

            if (errorMsg.isEmpty()) {
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO courses(course_name,course_des,price,catagory,course_file,status,tag) VALUES(?,?,?,?,?,?,?)"
                );
                ps.setString(1, name);
                ps.setString(2, des);
                ps.setInt(3, Integer.parseInt(price));
                ps.setString(4, cat);
                ps.setString(5, fileNameDB);
                ps.setString(6, status);
                ps.setString(7, tag);
                ps.executeUpdate();
                message = "Edition Published Successfully!";
            }
        }

        if ("delete".equals(action)) {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM courses WHERE id=?");
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
            message = "Article Deleted!";
        }

        if ("toggle".equals(action)) {
            String idParam = request.getParameter("id");
            if (idParam != null) {
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE courses SET status = CASE WHEN status='active' THEN 'inactive' ELSE 'active' END WHERE id=?");
                ps.setInt(1, Integer.parseInt(idParam));
                ps.executeUpdate();
                message = "Status Revised!";
            }
        }

        if ("addCurriculum".equals(request.getParameter("action"))) {
            int courseId = Integer.parseInt(request.getParameter("course_id"));
            String curriculum = request.getParameter("curriculum");
            String longDesc = request.getParameter("long_description");

            PreparedStatement ps = conn.prepareStatement("INSERT INTO course_curriculams (course_id, curriculum, long_description) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE curriculum=?, long_description=?");
            ps.setInt(1, courseId);
            ps.setString(2, curriculum);
            ps.setString(3, longDesc);
            ps.setString(4, curriculum);
            ps.setString(5, longDesc);
            ps.executeUpdate();
            message = "Curriculum Archived!";
        }

        PreparedStatement ps2 = conn.prepareStatement("SELECT course_id, curriculum, long_description FROM course_curriculams");
        ResultSet rs2 = ps2.executeQuery();
        while (rs2.next()) {
            curriculumMap.put(rs2.getInt("course_id"), new String[]{rs2.getString("curriculum"), rs2.getString("long_description")});
        }

        Statement st = conn.createStatement();
        ResultSet r1 = st.executeQuery("SELECT COUNT(*) FROM courses");
        if (r1.next()) totalCourses = r1.getInt(1);

        ResultSet r2 = st.executeQuery("SELECT COUNT(*) FROM courses WHERE status='active'");
        if (r2.next()) activeCourses = r2.getInt(1);

        ResultSet r3 = st.executeQuery("SELECT COUNT(*) FROM courses WHERE status='inactive'");
        if (r3.next()) inactiveCourses = r3.getInt(1);

        ResultSet rs3d = st.executeQuery("SELECT c.course_name, cc.rating, cc.happy_clients FROM courses c INNER JOIN course_curriculams cc ON c.id = cc.course_id");
        while(rs3d.next()) {
            String cName = rs3d.getString("course_name");
            float cRating = rs3d.getFloat("rating");
            int cClients = rs3d.getInt("happy_clients");
            chartData.append(String.format("{\"name\":\"%s\", \"rating\":%f, \"clients\":%d},", cName, cRating, cClients));
            labels2D.append("'").append(cName).append("',");
            ratings2D.append(cRating).append(",");
            clients2D.append(cClients).append(",");
        }
        if (chartData.length() > 1) chartData.setLength(chartData.length() - 1);
        if (labels2D.length() > 1) labels2D.setLength(labels2D.length() - 1);
        if (ratings2D.length() > 1) ratings2D.setLength(ratings2D.length() - 1);
        if (clients2D.length() > 1) clients2D.setLength(clients2D.length() - 1);
        chartData.append("]"); labels2D.append("]"); ratings2D.append("]"); clients2D.append("]");
        conn.close();
    } catch (Exception e) {
        errorMsg = "Dispatch Error: " + e.getMessage();
    }
%>

<%
    String adminName = (String) session.getAttribute("fullname");
    String role = (String) session.getAttribute("role");
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null || !"instructor".equalsIgnoreCase(role)) {
        response.sendRedirect("register-login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>The Academic Gazette | Teacher Ledger</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Crimson+Text:ital,wght@0,400;0,700;1,400&family=Playfair+Display:wght@700;900&family=Special+Elite&display=swap" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --paper: #f4f1ea;
            --ink: #1a1a1a;
            --accent: #8b0000;
            --sidebar-width: 240px;
        }

        body {
            background-color: var(--paper);
            background-image: url('https://www.transparenttextures.com/patterns/paper-fibers.png');
            color: var(--ink);
            font-family: 'Crimson Text', serif;
            overflow-x: hidden;
        }

        /* Sidebar Styles */
        .sidebar {
            width: var(--sidebar-width); height: 100vh; position: fixed;
            background: var(--ink); color: var(--paper); padding-top: 20px;
            border-right: 4px double var(--paper);
        }
        .sidebar h4 { font-family: 'Playfair Display', serif; border-bottom: 1px solid var(--paper); padding-bottom: 10px; margin: 0 15px 20px; }
        .sidebar a { color: #ccc; padding: 12px 25px; display: block; text-decoration: none; font-family: 'Special Elite', cursive; transition: 0.3s; font-size: 14px; }
        .sidebar a:hover { background: var(--accent); color: white; }
        .sidebar a.active { background: var(--paper); color: var(--ink); border-left: 5px solid var(--accent); }

        .main-content { margin-left: var(--sidebar-width); padding: 40px; }

        /* Masthead */
        .masthead {
            text-align: center;
            border-bottom: 4px double var(--ink);
            margin-bottom: 30px;
            padding-bottom: 10px;
        }
        .masthead h1 { font-family: 'Playfair Display', serif; font-size: 4rem; text-transform: uppercase; font-weight: 900; letter-spacing: -2px; }
        .masthead .meta { font-family: 'Special Elite', cursive; border-top: 1px solid var(--ink); border-bottom: 1px solid var(--ink); padding: 5px; display: flex; justify-content: space-between; font-size: 14px; }

        /* Cards & Components */
        .stat-card {
            background: transparent; border: 1px solid var(--ink);
            border-radius: 0; color: var(--ink); text-align: center;
            padding: 20px; position: relative;
        }
        .stat-card::after { content: ""; position: absolute; bottom: 3px; right: 3px; top: 3px; left: 3px; border: 1px solid var(--ink); pointer-events: none; }
        .stat-card h6 { font-family: 'Special Elite', cursive; text-transform: uppercase; }
        .stat-card h2 { font-family: 'Playfair Display', serif; font-weight: 900; font-size: 3rem; }

        .chart-box {
            background: white; border: 1px solid var(--ink); padding: 20px;
            box-shadow: 6px 6px 0px var(--ink); margin-bottom: 30px;
        }
        .chart-box h5 { font-family: 'Playfair Display', serif; font-weight: 700; border-bottom: 2px solid var(--ink); padding-bottom: 5px; margin-bottom: 15px; }

        /* Form */
        .news-form { border: 1px solid var(--ink); padding: 25px; background: rgba(255,255,255,0.4); }
        .form-control, .form-select {
            background: transparent; border: none; border-bottom: 1px solid var(--ink);
            border-radius: 0; padding-left: 0; font-family: 'Special Elite', cursive;
        }
        .btn-ink {
            background: var(--ink); color: var(--paper); border-radius: 0;
            font-family: 'Special Elite', cursive; text-transform: uppercase;
            padding: 10px; transition: 0.3s;
        }
        .btn-ink:hover { background: var(--accent); color: white; }

        /* Table */
        .table { border-top: 2px solid var(--ink); }
        .table thead th { font-family: 'Special Elite', cursive; text-transform: uppercase; border-bottom: 2px solid var(--ink); }
        .course-img {
            width: 60px; height: 60px; object-fit: cover;
            border: 1px solid var(--ink); padding: 2px; background: white;
            filter: grayscale(100%);
        }
        .course-img:hover { filter: grayscale(0%); }

        /* Modal */
        .modal-box { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.8); z-index: 9999; }
        .modal-content-news {
            background: var(--paper); width: 500px; margin: 50px auto; padding: 30px;
            border: 3px solid var(--ink); outline: 1px solid var(--ink); outline-offset: 4px;
        }

        .typewriter {
            font-family: 'Special Elite', cursive;
            display: inline-block;
            overflow: hidden;
            white-space: nowrap;
            border-right: .15em solid var(--accent);
            animation: typing 3s steps(30, end), blink .75s step-end infinite;
        }
        @keyframes typing { from { width: 0 } to { width: 100% } }
        @keyframes blink { from, to { border-color: transparent } 50% { border-color: var(--accent); } }
    </style>
</head>
<body>

<div class="sidebar">
    <h4><span><%= adminName %> (ADMIN)</span></h4>



    <a href="#" class="active">📊 THE DESK</a>
    <a href="#">📚 ARCHIVES</a>
    <a href="#">👥 READERSHIP</a>
    <a href="#">⚙️ EDITORIAL SETTINGS</a>
</div>

<div class="main-content">
    <div class="masthead">
        <div class="meta">
            <span>VOL. CXIV ... NO. 36,254</span>
            <span class="typewriter"><%= new java.util.Date().toString() %></span>
            <span>PRICE: ONE PENNY</span>
        </div>
        <h1>The Academic Gazette</h1>
        <p class="italic">"All the news that's fit to teach."</p>
    </div>

    <div class="mb-4">
        <% if(!message.isEmpty()){ %><span class="badge bg-dark p-2 mb-2"><%= message %></span><% } %>
        <% if(!errorMsg.isEmpty()){ %><span class="badge bg-danger p-2 mb-2"><%= errorMsg %></span><% } %>
    </div>

    <!-- METRIC CARDS -->
    <div class="row mb-4">
        <div class="col-md-4">
            <div class="stat-card">
                <h6>Total Publications</h6>
                <h2><%= totalCourses %></h2>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <h6>Live Editions</h6>
                <h2><%= activeCourses %></h2>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <h6>In The Vault</h6>
                <h2><%= inactiveCourses %></h2>
            </div>
        </div>
    </div>

    <div class="row">
        <!-- ANALYTICS -->
        <div class="col-md-7">
            <div class="chart-box">
                <h5>Scholarly Performance (Ratings)</h5>
                <canvas id="barChart" height="150"></canvas>
            </div>
            <div class="chart-box">
                <h5>Distribution of Status</h5>
                <div style="max-width: 300px; margin: 0 auto;">
                    <canvas id="pieChart"></canvas>
                </div>
            </div>
        </div>

        <!-- NEW SUBMISSION -->
        <div class="col-md-5">
            <div class="news-form shadow-sm">
                <h5 class="font-playfair fw-bold border-bottom border-dark pb-2 mb-3">SUBMIT NEW ARTICLE</h5>
                <form method="post" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="add">
                    <div class="mb-3">
                        <label class="small fw-bold">HEADLINE</label>
                        <input type="text" name="course_name" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="small fw-bold">ABSTRACT</label>
                        <textarea name="course_des" class="form-control" rows="2"></textarea>
                    </div>
                    <div class="row mb-3">
                        <div class="col"><label class="small fw-bold">FEE</label><input type="number" name="price" class="form-control" required></div>
                        <div class="col"><label class="small fw-bold">SECTION</label><input type="text" name="catagory" class="form-control"></div>
                    </div>
                    <div class="mb-3">
                        <label class="small fw-bold">ETCHING (PNG ONLY)</label>
                        <input type="file" name="course_file" class="form-control">
                    </div>
                    <div class="row mb-4">
                        <div class="col">
                            <label class="small fw-bold">STATUS</label>
                            <select name="status" class="form-select">
                                <option value="active">Active</option>
                                <option value="inactive">Draft</option>
                            </select>
                        </div>
                        <div class="col">
                            <label class="small fw-bold">TAGS</label>
                            <input type="text" name="tag" class="form-control">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-ink w-100">Publish to Front Page</button>
                </form>
            </div>
        </div>
    </div>

    <!-- TABLE SECTION -->
    <div class="row mt-5">
        <div class="col-12">
            <div class="chart-box">
                <h5>The Classifieds: Current Listings</h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th>Listing Details</th>
                                <th>Section</th>
                                <th>Subscription</th>
                                <th>Status</th>
                                <th class="text-end">Editorial Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try {
                                Connection conn = DriverManager.getConnection(DB_URL, DB_USER, dbPassword);
                                Statement stTable = conn.createStatement();
                                ResultSet rs = stTable.executeQuery("SELECT * FROM courses ORDER BY id DESC");
                                while(rs.next()){
                            %>
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <img src="images/<%= rs.getString("course_file") %>" class="course-img me-3" onerror="this.src='https://via.placeholder.com/60/ffffff/000000?text=IMAGE'">
                                        <div>
                                            <div class="fw-bold fs-5"><%= rs.getString("course_name") %></div>
                                            <small class="text-muted font-monospace">REF: #<%= rs.getInt("id") %></small>
                                        </div>
                                    </div>
                                </td>
                                <td><span class="text-uppercase"><%= rs.getString("catagory") %></span></td>
                                <td>$<%= rs.getInt("price") %></td>
                                <td><span class="badge <%= rs.getString("status").equals("active")?"bg-dark":"border border-dark text-dark" %>"><%= rs.getString("status") %></span></td>
                                <td class="text-end">
                                    <a href="?action=toggle&id=<%= rs.getInt("id") %>" class="btn btn-sm btn-outline-dark">Revise</a>
                                    <a href="#" class="btn btn-sm btn-outline-dark" onclick="openCurriculumModal(<%= rs.getInt("id") %>)">Ledger</a>
                                    <a href="?action=delete&id=<%= rs.getInt("id") %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Retract this publication?')">Retract</a>
                                </td>
                            </tr>
                            <% } conn.close(); } catch(Exception e) { out.print("Ledger error."); } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- MODAL -->
<div id="curriculumModal" class="modal-box" style="display:none;">
    <div class="modal-content-news">

        <h3 class="font-playfair border-bottom border-dark mb-4">
            Curriculum Registry
        </h3>

        <form method="post">
            <input type="hidden" name="action" value="addCurriculum">
            <input type="hidden" name="course_id" id="courseIdInput">

            <!-- CURRICULUM -->
            <div class="mb-3">
                <label class="small fw-bold">SYLLABUS (JSON OR TEXT)</label>

                <textarea
                    name="curriculum"
                    id="curriculumInput"
                    class="form-control"
                    rows="6"
                    required
                    onfocus="clearDefaultText(this)"
                    onblur="restoreDefaultText(this)"
                >JSON FORMAT:
            {
              "rating": 4.5,
              "feedbacks": "Good course",
              "happy_clients": 120
            }

            OR NON-JSON FORMAT:
            Rating: 4.5
            Feedback: Good course
            Clients: 120</textarea>
            </div>

            <!-- DESCRIPTION -->
            <div class="mb-4">
                <label class="small fw-bold">FULL ARTICLE DESCRIPTION</label>
                <textarea name="long_description" class="form-control" rows="4" required></textarea>
            </div>

            <!-- BUTTONS -->
            <div class="d-flex gap-2">
                <button type="submit" class="btn btn-ink flex-grow-1">
                    File Records
                </button>
                <button type="button" class="btn btn-outline-dark" onclick="closeModal()">
                    Dismiss
                </button>
            </div>

        </form>
    </div>
</div>

<script>
    const labels = <%= labels2D.toString() %>;
    const ratings = <%= ratings2D.toString() %>;
    const clients = <%= clients2D.toString() %>;

    // Vintage Styles for Charts
    const chartOptions = {
        responsive: true,
        plugins: { legend: { labels: { font: { family: 'Special Elite' } } } },
        scales: {
            y: { grid: { color: '#ddd' }, ticks: { font: { family: 'Special Elite' } } },
            x: { grid: { display: false }, ticks: { font: { family: 'Special Elite' } } }
        }
    };

    new Chart(document.getElementById('barChart'), {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Scholarly Rating',
                data: ratings,
                backgroundColor: '#1a1a1a',
                borderWidth: 0
            }]
        },
        options: chartOptions
    });

    new Chart(document.getElementById('pieChart'), {
        type: 'pie',
        data: {
            labels: ['Active', 'Draft'],
            datasets: [{
                data: [<%= activeCourses %>, <%= inactiveCourses %>],
                backgroundColor: ['#1a1a1a', '#8b0000'],
                borderWidth: 2,
                borderColor: '#f4f1ea'
            }]
        }
    });


        function openCurriculumModal(courseId, helpText) {
            const modal = document.getElementById("curriculumModal");
            const courseInput = document.getElementById("courseIdInput");
            const curriculumBox = document.querySelector("textarea[name='curriculum']");

            // Show modal
            modal.style.display = "block";

            // Set course ID
            courseInput.value = courseId;

            // Add placeholder guide (JSON + NON-JSON rules)
            if (helpText && curriculumBox) {
                curriculumBox.placeholder = helpText;
            }
        }

        function closeModal() {
            document.getElementById("curriculumModal").style.display = "none";
        }

        // Optional UX improvement: close when clicking outside modal
        window.onclick = function(event) {
            const modal = document.getElementById("curriculumModal");
            if (event.target === modal) {
                modal.style.display = "none";
            }
        };

</script>

<script>
let defaultCurriculumText = `JSON FORMAT:
{
  "rating": 4.5,
  "feedbacks": "Good course",
  "happy_clients": 120
}

OR NON-JSON FORMAT:
Rating: 4.5
Feedback: Good course
Clients: 120`;

function clearDefaultText(el) {
    if (el.value === defaultCurriculumText) {
        el.value = "";
    }
}

function restoreDefaultText(el) {
    if (el.value.trim() === "") {
        el.value = defaultCurriculumText;
    }
}
</script>

</body>
</html>