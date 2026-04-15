<%@ page import="java.sql.*, java.io.*, jakarta.servlet.http.Part" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>

<%
Integer userId = (Integer) session.getAttribute("userId");

if (userId == null) {
    response.sendRedirect("login.jsp");
    return;
}

String DB_URL = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
String DB_USER = "root";
String DB_PASS = System.getenv("DB_PASSWORD");

String uploadPath = application.getRealPath("/") + "images";
File dir = new File(uploadPath);
if (!dir.exists()) dir.mkdirs();

String phone = request.getParameter("phone");
String address = request.getParameter("address");
String bio = request.getParameter("bio");

String fileNameDB = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

    // ========== IMAGE UPLOAD ==========
    Part filePart = request.getPart("profile_image");

    if (filePart != null && filePart.getSize() > 0) {

        String original = filePart.getSubmittedFileName();

        if (original != null && (
            original.endsWith(".png") ||
            original.endsWith(".jpg") ||
            original.endsWith(".jpeg") ||
            original.endsWith(".webp")
        )) {
            fileNameDB = System.currentTimeMillis() + "_" + original;

            filePart.write(uploadPath + File.separator + fileNameDB);
        }
    }

    // ========== CHECK EXISTING PROFILE ==========
    PreparedStatement check = conn.prepareStatement(
        "SELECT id FROM user_profiles WHERE user_id=?"
    );
    check.setInt(1, userId);

    ResultSet rs = check.executeQuery();

    if (rs.next()) {

        // UPDATE
        if (fileNameDB != null) {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE user_profiles SET profile_image=?, phone=?, address=?, bio=? WHERE user_id=?"
            );
            ps.setString(1, fileNameDB);
            ps.setString(2, phone);
            ps.setString(3, address);
            ps.setString(4, bio);
            ps.setInt(5, userId);
            ps.executeUpdate();
        } else {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE user_profiles SET phone=?, address=?, bio=? WHERE user_id=?"
            );
            ps.setString(1, phone);
            ps.setString(2, address);
            ps.setString(3, bio);
            ps.setInt(4, userId);
            ps.executeUpdate();
        }

    } else {

        // INSERT
        PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO user_profiles(user_id, profile_image, phone, address, bio) VALUES(?,?,?,?,?)"
        );

        ps.setInt(1, userId);
        ps.setString(2, fileNameDB);
        ps.setString(3, phone);
        ps.setString(4, address);
        ps.setString(5, bio);

        ps.executeUpdate();
    }

    conn.close();

    response.sendRedirect("student_dashboard.jsp");

} catch (Exception e) {
    out.println("ERROR: " + e.getMessage());
}
%>