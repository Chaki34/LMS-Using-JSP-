<%@ page import="java.sql.*,java.util.*" %>

<section class="courses-section">
    <div class="section-header">
        <h2>Popular Courses</h2>
        <p>Explore our most enrolled courses this month</p>
    </div>

    <div class="courses-container">

<%
Connection conn = null;
Statement st = null;
ResultSet rs = null;

try {
    // Load Driver
    String myDriver = "com.mysql.cj.jdbc.Driver";
    String myUrl = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    Class.forName(myDriver);

    // ✅ Get password from ENV
    String dbPassword = System.getenv("DB_PASSWORD");

    // ❗ Check if ENV is missing
    if (dbPassword == null || dbPassword.trim().isEmpty()) {
        throw new Exception("DB_PASSWORD environment variable is NOT set!");
    }

    // Connect
    conn = DriverManager.getConnection(myUrl, "root", dbPassword);

    // Query
    String query = "SELECT * FROM courses ORDER BY id DESC LIMIT 3";
    st = conn.createStatement();
    rs = st.executeQuery(query);

    Random r = new Random();

    while (rs.next()) {

        int id = rs.getInt("id");
        String courseName = rs.getString("course_name");
        String courseDes = rs.getString("course_des");
        String category = rs.getString("catagory");
        String courseFile = rs.getString("course_file");

        // ✅ Safe description
        String shortDes = "";
        if (courseDes != null) {
            shortDes = (courseDes.length() > 50) ? courseDes.substring(0, 50) + "..." : courseDes;
        }

        // ✅ Safe image
        String img = (courseFile != null && !courseFile.isEmpty()) ? courseFile : "default.png";

        int students = r.nextInt(10000);
        int reviews = r.nextInt(1000);
%>

        <div class="course-card" data-tilt data-tilt-scale="1.05" data-tilt-glare data-tilt-max-glare="0.2">
            <div class="course-image">
               <img src="<%= request.getContextPath() %>/images/<%= img %>" alt="Course Image">
                <div class="course-category"><%= category %></div>
            </div>

            <div class="course-content">
                <h3 class="course-title"><%= courseName %></h3>

                <p class="course-description"><%= shortDes %></p>

                <div class="course-meta">
                    <span><i class="fas fa-user-graduate"></i> <%= students %> students</span>
                    <span><i class="fas fa-star"></i> 4.8 (<%= reviews %> reviews)</span>
                </div>

                <a href="course_info.jsp?q=<%= id %>" class="read-more-btn">
                    Read More <i class="fas fa-arrow-right"></i>
                </a>
            </div>
        </div>

<%
    }

} catch (Exception e) {
%>
    <div style="color:red; font-weight:bold;">
        ERROR: <%= e.getMessage() %>
    </div>
<%
} finally {
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (st != null) st.close(); } catch (Exception e) {}
    try { if (conn != null) conn.close(); } catch (Exception e) {}
}
%>

    </div>

    <div class="view-all-container">
        <a href="all_courses.jsp" class="view-all-btn">
            View All Courses <i class="fas fa-arrow-right"></i>
        </a>
    </div>
</section>