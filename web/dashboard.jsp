<%@ page import="java.sql.*, java.io.*, java.util.*, jakarta.servlet.http.Part" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<%
    String DB_URL = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String DB_USER = "root";
    String dbPassword = System.getenv("DB_PASSWORD");

    String message = "";
    String errorMsg = "";

    // ===== IMAGE PATH =====
    String uploadPath = application.getRealPath("/") + "images";
    File dir = new File(uploadPath);
    if (!dir.exists()) dir.mkdirs();

    try {
        String action = request.getParameter("action");

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, dbPassword);

        // ================= ADD COURSE =================
        if ("add".equals(action)) {
out.print("<script>window.alert('Welcome chagol')</script>");
            String name = request.getParameter("course_name");
            String des = request.getParameter("course_des");
            String price = request.getParameter("price");
            String cat = request.getParameter("catagory");
            String status = request.getParameter("status");
            String tag = request.getParameter("tag");

            String fileNameDB = "";

            // ===== FILE UPLOAD =====
            Part filePart = request.getPart("course_file");

            if (filePart == null) {
                errorMsg = "File part is NULL!";
            } 
            else if (filePart.getSize() == 0) {
                errorMsg = "No file selected!";
            } 
            else {

                // ... previous code ...
String fileName = filePart.getSubmittedFileName();

if (fileName == null || fileName.isEmpty()) {
    errorMsg = "File name is empty!";
} else {
    // Check if a dot exists to avoid StringIndexOutOfBoundsException
    int lastDot = fileName.lastIndexOf(".");
    String ext = (lastDot != -1) ? fileName.substring(lastDot).toLowerCase() : "";

    if (!ext.equals(".png")) {
        errorMsg = "Only PNG files allowed!";
    } else {
        try {
            // Ensure uploadPath directory exists
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();

            String newFileName = System.currentTimeMillis() + "_" + fileName;
            String fullPath = uploadPath + File.separator + newFileName;

            filePart.write(fullPath);
            fileNameDB = newFileName;
            message = "File uploaded successfully to: " + newFileName;

        } catch (Exception ex) {
            errorMsg = "File upload error: " + ex.getMessage();
            ex.printStackTrace(); // Always print stack trace for debugging
        }
    }
}
            }

            // ===== INSERT ONLY IF NO ERROR =====
            if (errorMsg.equals("")) {

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

                message = "✅ Course Added Successfully!";
            }
        }

        // ================= DELETE =================
        if ("delete".equals(action)) {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM courses WHERE id=?");
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
            message = "Course Deleted!";
        }

        conn.close();

    } catch (Exception e) {
        errorMsg = "MAIN ERROR: " + e.getMessage();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-light">

<div class="container mt-4">

    <h3>Course Dashboard</h3>

    <!-- SUCCESS MESSAGE -->
    <% if (!message.equals("")) { %>
        <div class="alert alert-success"><%= message %></div>
    <% } %>

    <!-- ERROR MESSAGE -->
    <% if (!errorMsg.equals("")) { %>
        <div class="alert alert-danger"><%= errorMsg %></div>
    <% } %>

   <!-- ADD COURSE -->
<form method="post" action="dashboard.jsp" enctype="multipart/form-data" class="card p-3 mb-4">

    <input type="hidden" name="action" value="add">

    <input type="text" name="course_name" placeholder="Course Name" class="form-control mb-2" required>

    <textarea name="course_des" placeholder="Description" class="form-control mb-2"></textarea>

    <input type="number" name="price" placeholder="Price" class="form-control mb-2">

    <input type="text" name="catagory" placeholder="Category" class="form-control mb-2">

    <!-- FILE INPUT -->
    <input type="file" name="course_file" class="form-control mb-2" required>

    <select name="status" class="form-control mb-2">
        <option value="active">Active</option>
        <option value="inactive">Inactive</option>
    </select>

    <input type="text" name="tag" placeholder="Tags" class="form-control mb-2">

    <!-- FIXED BUTTON -->
    <button type="submit" class="btn btn-primary">
        Add Course
    </button>

</form>

    <!-- COURSE LIST -->
    <table class="table table-bordered bg-white">
        <tr>
            <th>ID</th>
            <th>Image</th>
            <th>Name</th>
            <th>Price</th>
            <th>Action</th>
        </tr>

        <%
            try {
                Connection conn = DriverManager.getConnection(DB_URL, DB_USER, dbPassword);
                Statement st = conn.createStatement();
                ResultSet rs = st.executeQuery("SELECT * FROM courses ORDER BY id DESC");

                while (rs.next()) {
        %>

        <tr>
            <td><%= rs.getInt("id") %></td>

            <td>
                <img src="images/<%= rs.getString("course_file") %>" width="60">
            </td>

            <td><%= rs.getString("course_name") %></td>
            <td>$<%= rs.getInt("price") %></td>

            <td>
                <a href="dashboard.jsp?action=delete&id=<%= rs.getInt("id") %>" 
                   class="btn btn-danger btn-sm">Delete</a>
            </td>
        </tr>

        <%
                }
                conn.close();
            } catch (Exception e) {
                out.print(e.getMessage());
            }
        %>

    </table>

</div>

</body>
</html>