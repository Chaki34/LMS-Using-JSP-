<%@ page import="java.sql.*,java.util.*" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>



<%
String search = request.getParameter("search");
String tag = request.getParameter("tag");

if(search == null) search = "";
if(tag == null) tag = "";


// =========================
// FIX: LOAD TAGS FROM DB
// =========================
List<String> tags = new ArrayList<>();
Set<String> tagSet = new HashSet<>();

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    String dbPassword = System.getenv("DB_PASSWORD");

    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
        "root",
        dbPassword
    );

    Statement st = con.createStatement();
    ResultSet rsTags = st.executeQuery("SELECT tag FROM courses");

    while(rsTags.next()) {
        String t = rsTags.getString("tag");

        if(t != null) {
            t = t.trim().toLowerCase(); // 🔥 normalize (removes AI vs ai issue)

            if(!t.isEmpty() && !tagSet.contains(t)) {
                tagSet.add(t);
                tags.add(t);
            }
        }
    }

    rsTags.close();
    st.close();
    con.close();

} catch(Exception e) {
    out.print("");
}
%>



<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>The Daily Scholar | All Courses</title>

<!-- Fonts for Newspaper Theme -->
<link href="https://fonts.googleapis.com/css2?family=Crimson+Text:ital,wght@0,400;0,700;1,400&family=Playfair+Display:wght@700;900&family=Special+Elite&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

<style>
    /* Newspaper Color Palette */
    :root {
        --paper: #f4f1ea;
        --ink: #1a1a1a;
        --accent-red: #8b0000;
        --border-ink: #333333;
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

    .typewriter {
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
        max-width: 1200px;
        margin: 0 auto;
    }
    .logo-title {
        font-family: 'Playfair Display', serif;
        font-size: 70px;
        font-weight: 900;
        text-transform: uppercase;
        letter-spacing: -2px;
        margin: 10px 0;
        color: var(--ink);
        text-decoration: none;
    }

    /* SEARCH BOX */
    .search-container {
        max-width: 600px;
        margin: 20px auto;
        display: flex;
        background: #fff;
        padding: 5px;
        border: 1px solid var(--ink);
        box-shadow: 5px 5px 0px var(--ink);
    }
    .search-input {
        flex: 1;
        padding: 10px;
        border: none;
        font-family: 'Special Elite', cursive;
        outline: none;
    }
    .search-btn {
        padding: 10px 20px;
        background: var(--ink);
        color: var(--paper);
        border: none;
        cursor: pointer;
        font-family: 'Special Elite', cursive;
    }

    /* TAGS */
    .tags {
        display: flex;
        justify-content: center;
        gap: 15px;
        flex-wrap: wrap;
        margin: 20px 0;
        font-family: 'Special Elite', cursive;
    }
    .tags a {
        text-decoration: none;
        color: var(--ink);
        border-bottom: 2px solid transparent;
        padding: 2px 5px;
        transition: 0.3s;
    }
    .tags a.active {
        border-bottom: 2px solid var(--accent-red);
        font-weight: bold;
    }
    .tags a:hover {
        background: var(--ink);
        color: var(--paper);
    }

    /* GRID */
    .courses-container {
        max-width: 1200px;
        margin: auto;
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
        gap: 30px;
        padding: 30px;
    }

    /* COURSE CARD */
    .course-card {
        background: white;
        border: 1px solid var(--ink);
        padding: 15px;
        transition: all 0.3s;
        display: flex;
        flex-direction: column;
    }
    .course-card:hover {
        transform: translateY(-5px);
        box-shadow: 10px 10px 0px var(--ink);
    }

    .course-image img {
        width: 100%;
        height: 180px;
        object-fit: cover;
        filter: grayscale(100%) contrast(110%);
        border: 1px solid var(--ink);
        transition: all 0.5s;
    }
    .course-card:hover .course-image img {
        filter: grayscale(0%);
    }

    .course-title {
        font-family: 'Playfair Display', serif;
        font-size: 22px;
        margin: 15px 0 10px 0;
        line-height: 1.2;
        border-bottom: 1px solid #ccc;
        padding-bottom: 5px;
    }

    .course-description {
        font-size: 15px;
        color: #333;
        margin-bottom: 15px;
        flex-grow: 1;
    }

    .course-meta {
        font-family: 'Special Elite', cursive;
        font-size: 12px;
        display: flex;
        justify-content: space-between;
        padding: 10px 0;
        border-top: 1px double var(--ink);
        color: var(--accent-red);
    }

    .read-more-btn {
        display: block;
        text-align: center;
        background: var(--ink);
        color: var(--paper);
        text-decoration: none;
        padding: 12px;
        font-family: 'Special Elite', cursive;
        font-size: 13px;
        transition: 0.3s;
    }
    .read-more-btn:hover {
        background: var(--accent-red);
    }

    .footer {
        border-top: 4px double var(--ink);
        margin: 50px 20px 0 20px;
        padding: 40px;
        text-align: center;
        font-family: 'Special Elite', cursive;
    }
    /* =========================
       RESPONSIVE (SMALL SCREENS ONLY)
    ========================= */

    @media (max-width: 600px) {

        body {
            font-size: 14px;
        }

        /* TOP BAR */
        .top-bar-content {
            flex-direction: column;
            gap: 6px;
            text-align: center;
        }

        .typewriter {
            font-size: 12px;
        }

        /* HEADER */
        .news-header {
            padding: 20px 10px;
            margin: 0 10px 15px 10px;
        }

        .header-meta {
            flex-direction: column;
            gap: 5px;
            text-align: center;
            font-size: 12px;
        }

        .logo-title {
            font-size: 32px;
            letter-spacing: 0;
        }

        /* SEARCH */
        .search-container {
            flex-direction: column;
            padding: 10px;
        }

        .search-input,
        .search-btn {
            width: 100%;
        }

        .search-btn {
            margin-top: 5px;
        }

        /* TAGS */
        .tags {
            gap: 8px;
            padding: 0 10px;
        }

        .tags a {
            font-size: 12px;
        }

        /* GRID */
        .courses-container {
            grid-template-columns: 1fr; /* single column */
            padding: 15px;
            gap: 20px;
        }

        /* CARD */
        .course-card {
            padding: 12px;
        }

        .course-image img {
            height: 140px;
        }

        .course-title {
            font-size: 18px;
        }

        .course-description {
            font-size: 13px;
        }

        .course-meta {
            flex-direction: column;
            gap: 5px;
            text-align: center;
        }

        .read-more-btn {
            font-size: 12px;
            padding: 10px;
        }

        /* FOOTER */
        .footer {
            padding: 20px 10px;
            margin: 30px 10px 0 10px;
            font-size: 12px;
        }
    }
</style>
</head>

<body>

<div class="top-bar">
    <div class="top-bar-content">
        <div class="typewriter">LATEST UPDATES: New Curriculum Released...</div>
        <div><i class="fas fa-calendar-alt"></i> <%= new java.text.SimpleDateFormat("EEEE, MMMM dd, yyyy").format(new java.util.Date()) %></div>
    </div>
</div>

<div class="news-header">
    <div class="header-meta">
        <span>Vol. LXIV ... No. 32,104</span>
        <span>ACADEMIC EDITION</span>
        <span>PRICE: KNOWLEDGE</span>
    </div>

    <a href="all_courses.jsp" class="logo-title">The Daily Scholar</a>

    <p style="font-style: italic; font-size: 18px;">"All the Knowledge That's Fit to Print"</p>

    <!-- SEARCH -->
    <form class="search-container" method="get">
        <input type="text" name="search" class="search-input" value="<%= search %>" placeholder="Search archives...">
        <button type="submit" class="search-btn">SEARCH</button>
    </form>

<div class="tags">

    <a href="all_courses.jsp"
       class="<%= (tag == null || tag.equals("")) ? "active" : "" %>">
       ALL COURSES
    </a>

    <%
    for (String t : tags) {
    %>
        <a href="all_courses.jsp?tag=<%= t %>"
           class="<%= t.equals(tag) ? "active" : "" %>">
           <%= t.toUpperCase() %>
        </a>
    <%
    }
    %>

</div>



<div class="courses-container">

<%
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    String dbPassword = System.getenv("DB_PASSWORD");
    conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
        "root",
        dbPassword
    );

   String sql = "SELECT c.*, cc.rating FROM courses c " +
                "LEFT JOIN course_curriculams cc ON c.id = cc.course_id WHERE 1=1";

   if(!search.isEmpty()) {
       sql += " AND (course_name LIKE ? OR course_des LIKE ?)";
   }

   if(!tag.isEmpty()) {
       sql += " AND tag = ?";   // ✅ FIX HERE
   }

   sql += " ORDER BY id DESC";

   ps = conn.prepareStatement(sql);
   int i = 1;

   if(!search.isEmpty()) {
       ps.setString(i++, "%" + search + "%");
       ps.setString(i++, "%" + search + "%");
   }

   if(!tag.isEmpty()) {
       ps.setString(i++, tag);
   }

    rs = ps.executeQuery();
    Random r = new Random();

    while(rs.next()) {
        int id = rs.getInt("id");
        String courseName = rs.getString("course_name");
        String courseDes = rs.getString("course_des");
        String category = rs.getString("catagory");
        String courseFile = rs.getString("course_file");

        double rating = rs.getDouble("rating");

        // fallback if null (0.0)
        String ratingDisplay = (rating > 0) ? rating + "/5" : "N/A";

        String shortDes = (courseDes != null && courseDes.length() > 80)
                ? courseDes.substring(0, 80) + "..."
                : courseDes;

        String img = (courseFile != null && !courseFile.isEmpty())
                ? courseFile
                : "default.png";

        int students = r.nextInt(5000);
        int reviews = r.nextInt(800);
%>

    <div class="course-card">
        <div class="course-image">
            <img src="<%= request.getContextPath() %>/images/<%= img %>" alt="Course Illustration">
        </div>

        <div class="course-content">
            <h3 class="course-title"><%= courseName %></h3>
            <p class="course-description"><%= shortDes %></p>

             <div class="course-meta">
                            <span>ENROLLED: <%= students %></span>
                            <span>RATING: <%= ratingDisplay %></span>
                        </div>

            <a class="read-more-btn" href="course_info.jsp?q=<%= id %>">
                READ FULL STORY
            </a>
        </div>
    </div>

<%
    }
} catch(Exception e) {
%>
    <div style="color:var(--accent-red); text-align:center; font-family:'Special Elite'; grid-column: 1/-1;">
        CORRESPONDENCE ERROR: <%= e.getMessage() %>
    </div>
<%
} finally {
    try { if(rs!=null) rs.close(); } catch(Exception e){}
    try { if(ps!=null) ps.close(); } catch(Exception e){}
    try { if(conn!=null) conn.close(); } catch(Exception e){}
}
%>

</div>

<footer class="footer">
    <p>&copy; 1894 - <%= new java.util.Date().getYear() + 1900 %> The Daily Scholar Press. All Rights Reserved.</p>
</footer>

</body>
</html>