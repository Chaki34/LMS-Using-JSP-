<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { response.sendRedirect("register-login.jsp"); return; }

    String dbURL = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    Connection conn = null;
    PreparedStatement ps = null;

    List<String> jsonEvents = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, "root", System.getenv("DB_PASSWORD"));

        // TOGGLE STATUS LOGIC
        if (request.getParameter("toggle_id") != null) {
            String current = request.getParameter("current_status");
            String nextStatus = "pending".equals(current) ? "completed" : "pending";

            ps = conn.prepareStatement("UPDATE student_planner SET task_status=? WHERE id=? AND user_id=?");
            ps.setString(1, nextStatus);
            ps.setInt(2, Integer.parseInt(request.getParameter("toggle_id")));
            ps.setInt(3, userId);
            ps.executeUpdate();

            response.sendRedirect("planner.jsp");
            return;
        }

        // ADD NEW TASK LOGIC
        if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("title") != null) {
            ps = conn.prepareStatement(
                "INSERT INTO student_planner (user_id, plan_date, title, description, task_status) VALUES (?, ?, ?, ?, 'pending')"
            );
            ps.setInt(1, userId);
            ps.setDate(2, java.sql.Date.valueOf(request.getParameter("plan_date")));
            ps.setString(3, request.getParameter("title"));
            ps.setString(4, request.getParameter("description"));
            ps.executeUpdate();

            response.sendRedirect("planner.jsp");
            return;
        }

    } catch (Exception e) {
        out.print(e.getMessage());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>The Chronicle · Editorial Planner</title>
    <link href="https://fonts.googleapis.com/css2?family=Crimson+Text&family=Playfair+Display:wght@700&family=Special+Elite&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>

    <style>
        :root { --paper: #f4f1ea; --ink: #1a1a1a; --accent: #8b0000; --github-green: #28a745; }
        body { background: var(--paper); font-family: 'Crimson Text', serif; padding: 20px; color: var(--ink); }
        .planner-header { text-align: center; border-bottom: 4px double var(--ink); margin-bottom: 30px; }
        .container { max-width: 1100px; margin: 0 auto; display: grid; grid-template-columns: 1fr 1.6fr; gap: 30px; }

        .card { background: white; border: 1px solid var(--ink); padding: 20px; box-shadow: 5px 5px 0px var(--ink); }
        input, textarea { width: 100%; border: 1px solid #ccc; padding: 10px; margin-bottom: 10px; font-family: 'Special Elite'; }

        .btn-toggle {
            border: 1px solid var(--ink); padding: 5px 10px; cursor: pointer;
            font-family: 'Special Elite'; font-size: 10px; transition: 0.3s;
        }
        .btn-pending { background: var(--accent); color: white; }
        .btn-done { background: var(--github-green); color: white; }

        #calendar { background: white; padding: 15px; border: 1px solid var(--ink); height: 480px; }

        .table-news { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .table-news th { background: var(--ink); color: white; padding: 8px; font-family: 'Special Elite'; text-align: left; }
        .table-news td { border: 1px solid var(--ink); padding: 8px; background: white; }
    </style>
</head>

<body>

<div class="planner-header">
    <h1 style="font-family:'Playfair Display'; font-size: 40px; margin:0;">EDITORIAL PLANNER</h1>
    <p style="font-family:'Special Elite';">TASK ARCHIVE & SCHEDULER</p>
</div>

<div class="container">

    <div>
        <div class="card">
            <h3 style="font-family:'Special Elite'; margin-top:0;">Assign New Task</h3>
            <form method="post">
                <input type="date" name="plan_date" required>
                <input type="text" name="title" placeholder="Task Headline" required>
                <textarea name="description" placeholder="Description..."></textarea>
                <button type="submit" style="background:var(--ink); color:white; width:100%; padding:10px; border:none; font-family:'Special Elite'; cursor:pointer;">Save to Log</button>
            </form>
        </div>

        <div class="card" style="margin-top:20px; overflow-y:auto; max-height:400px;">
            <h3 style="font-family:'Special Elite';">Recent Journal</h3>

            <table class="table-news">
                <thead>
                    <tr>
                        <th>Task</th>
                        <th>Description</th>
                        <th>Status</th>
                    </tr>
                </thead>

                <tbody>
                <%
                    ps = conn.prepareStatement("SELECT * FROM student_planner WHERE user_id=? ORDER BY plan_date DESC");
                    ps.setInt(1, userId);
                    ResultSet rs2 = ps.executeQuery();

                    while(rs2.next()){
                        boolean isDone = "completed".equals(rs2.getString("task_status"));
                        String color = isDone ? "#28a745" : "#8b0000";

                        jsonEvents.add("{title:'"
                            + rs2.getString("title") +
                            "', start:'"
                            + rs2.getString("plan_date") +
                            "', description:'"
                            + (rs2.getString("description") != null ? rs2.getString("description").replace("'", "\\'") : "") +
                            "', color:'"
                            + color +
                            "'}");
                %>
                    <tr>
                        <td><strong><%= rs2.getString("title") %></strong></td>

                        <!-- ✅ ADDED DESCRIPTION COLUMN -->
                        <td><%= rs2.getString("description") %></td>

                        <td>
                            <form method="get" style="margin:0">
                                <input type="hidden" name="toggle_id" value="<%= rs2.getInt("id") %>">
                                <input type="hidden" name="current_status" value="<%= rs2.getString("task_status") %>">

                                <button type="submit" class="btn-toggle <%= isDone ? "btn-done" : "btn-pending" %>">
                                    <%= isDone ? "DONE" : "PENDING" %>
                                </button>
                            </form>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <div>
        <div id="calendar"></div>
    </div>

</div>

<script>
document.addEventListener('DOMContentLoaded', function() {

    var calendar = new FullCalendar.Calendar(document.getElementById('calendar'), {
        initialView: 'dayGridMonth',

        events: [ <%= String.join(",", jsonEvents) %> ],

        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: ''
        },

        // ✅ SHOW FULL DETAILS ON CLICK
        eventClick: function(info) {
            alert(
                "Task: " + info.event.title +
                "\n\nDescription: " + (info.event.extendedProps.description || "")
            );
        }
    });

    calendar.render();
});
</script>

</body>
</html>

<% if (conn != null) conn.close(); %>