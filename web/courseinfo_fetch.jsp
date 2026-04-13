<%-- 
    Document   : courseinfo_fetch.jsp
    Created on : 25-Feb-2026, 12:05:42 pm
    Author     : Administrator
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
      
          <%
                try
    {
      // create our mysql database connection
      String myDriver = "com.mysql.cj.jdbc.Driver";
      String myUrl = "jdbc:mysql://localhost:3306/lms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";;
      Class.forName(myDriver);
      String dbPassword = System.getenv("DB_PASSWORD");
      Connection conn = DriverManager.getConnection(myUrl, "root", dbPassword);
      
      // our SQL SELECT query. 
      // if you only need a few columns, specify them by name instead of using "*"
      String query = "SELECT * FROM COURSES";

      // create the java statement
      Statement st = conn.createStatement();
      
      // execute the query, and get a java resultset
      ResultSet rs = st.executeQuery(query);
      
      // iterate through the java resultset
      while (rs.next())
      {
        int id = rs.getInt("id");
        String courseName = rs.getString("course_name");
        String courseDes = rs.getString("course_des");
        int price = rs.getInt("price");
        String category = rs.getString("catagory");
        String courseFile = rs.getString("course_file");
        String status = rs.getString("status");
        String tag = rs.getString("tag");
        String h =courseDes.substring(0, 50);
         Random r= new Random();
            int rand = r.nextInt(10000); 
           int rand2 = r.nextInt(1000);
        %>
        
        

         
         
        
        
        <div class="course-card" data-tilt data-tilt-scale="1.05" data-tilt-glare data-tilt-max-glare="0.2">
                <div class="course-image">
                    <img src="http://localhost:8080/LMS/images/<% out.print(courseFile); %>" alt="Web Development">
                    <div class="course-category"><%= category %></div>
                </div>
                <div class="course-content">
                    <h3 class="course-title"><%= courseName %></h3>
                    <p class="course-description"> <%= h %></p>
                    <div class="course-meta">
                       
                                   
                      <span><i class="fas fa-user-graduate"></i><%= rand %> students</span>
                       <span><i class="fas fa-star"></i> 4.8 (<%= rand2 %> reviews)</span>  
                    </div>
                    <a href="course_info.jsp?q=<%= id %>" class="read-more-btn">
                        Read More <i class="fas fa-arrow-right"></i>
                    </a>
                </div>
            </div>
        
        
        
     <%
        
       
       
      }
      
      
    }
    catch (Exception e)
    {
      System.err.println("Got an exception! ");
      System.err.println(e.getMessage());
    }
                %>
            
        
        
    </body>
</html>
