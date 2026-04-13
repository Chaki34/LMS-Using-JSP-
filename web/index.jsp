<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LearnSphere - Learning Management System</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
</head>
<body>
    <!-- Top Bar with Discount Offer -->
    <div class="top-bar">
        <div class="top-bar-content">
            <span class="offer-text"><i class="fas fa-gift"></i> Special Offer: Get 50% OFF on all annual plans! Use code: LEARN50</span>
            <div class="top-bar-actions">
                <a href="register-login.jsp" class="login-btn">
                    <i   class="fas fa-user-circle"></i> Login / Register
                </a>
            </div>
        </div>
    </div>

    <!-- Navigation Menu -->
    <nav class="navbar">
        <div class="nav-container">
            <div class="logo">
                <i class="fas fa-graduation-cap"></i>
                <span>LearnSphere</span>
            </div>
            
            <ul class="nav-menu">
                <li class="nav-item active">
                    <a href="#" class="nav-link">
                        <i class="fas fa-home"></i> Home
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <i class="fas fa-cogs"></i> Services
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <i class="fas fa-question-circle"></i> Help
                    </a>
                </li>
            </ul>
            
            <div class="mobile-toggle">
                <i class="fas fa-bars"></i>
            </div>
        </div>
    </nav>

    <!-- Hero Section with Search Bar -->
    <section class="hero-section">
        <div class="hero-container">
            <div class="hero-content">
                <h1 class="hero-title">Learn Anything, Anytime, Anywhere</h1>
                <p class="hero-subtitle">Access 5000+ courses from top instructors in technology, business, arts, and more.</p>
                
                <!-- Jumbo Search Bar with Category Selection -->
                <div class="search-container">
                    <div class="search-box">
                        <div class="category-selector">
                            <select id="categorySelect" class="category-dropdown">
                                <option value="all">All Categories</option>
                                <option value="tech">Technology</option>
                                <option value="business">Business</option>
                                <option value="design">Design</option>
                                <option value="science">Science</option>
                                <option value="arts">Arts & Humanities</option>
                                <option value="health">Health & Fitness</option>
                            </select>
                            <i class="fas fa-chevron-down"></i>
                        </div>
                        <div class="search-input-wrapper">
                            <input type="text" id="searchInput" class="search-input" placeholder="What do you want to learn today?">
                            <button class="search-btn">
                                <i class="fas fa-search"></i> Search
                            </button>
                        </div>
                    </div>
                    <p class="search-hint">Try searching for "Web Development", "Data Science", or "Digital Marketing"</p>
                </div>
            </div>
            
            <div class="hero-image">
                <img src="https://images.pexels.com/photos/20432872/pexels-photo-20432872.jpeg" alt="Online Learning">
            </div>
        </div>
    </section>

    <!-- Course Blocks Section -->
    <%@include file="COURSES.jsp" %>

    <!-- Footer Section -->
    <footer class="footer">
        <div class="footer-container">
            <div class="footer-section">
                <div class="footer-logo">
                    <i class="fas fa-graduation-cap"></i>
                    <span>LearnSphere</span>
                </div>
                <p class="footer-description">LearnSphere is a leading online learning platform that provides high-quality courses from industry experts to learners worldwide.</p>
                <div class="social-icons">
                    <a href="#"><i class="fab fa-facebook-f"></i></a>
                    <a href="#"><i class="fab fa-twitter"></i></a>
                    <a href="#"><i class="fab fa-instagram"></i></a>
                    <a href="#"><i class="fab fa-linkedin-in"></i></a>
                    <a href="#"><i class="fab fa-youtube"></i></a>
                </div>
            </div>
            
            <div class="footer-section">
                <h3 class="footer-heading">Quick Links</h3>
                <ul class="footer-links">
                    <li><a href="#"><i class="fas fa-chevron-right"></i> Home</a></li>
                    <li><a href="#"><i class="fas fa-chevron-right"></i> About Us</a></li>
                    <li><a href="#"><i class="fas fa-chevron-right"></i> Courses</a></li>
                    <li><a href="#"><i class="fas fa-chevron-right"></i> Instructors</a></li>
                    <li><a href="#"><i class="fas fa-chevron-right"></i> Pricing</a></li>
                </ul>
            </div>
            
            <div class="footer-section">
                <h3 class="footer-heading">Services</h3>
                <ul class="footer-links">
                    <li><a href="#"><i class="fas fa-chevron-right"></i> Corporate Training</a></li>
                    <li><a href="#"><i class="fas fa-chevron-right"></i> Academic Partners</a></li>
                    <li><a href="#"><i class="fas fa-chevron-right"></i> Custom Courses</a></li>
                    <li><a href="#"><i class="fas fa-chevron-right"></i> Certification</a></li>
                    <li><a href="#"><i class="fas fa-chevron-right"></i> Career Support</a></li>
                </ul>
            </div>
            
            <div class="footer-section">
                <h3 class="footer-heading">Contact Us</h3>
                <ul class="footer-contact">
                    <li><i class="fas fa-map-marker-alt"></i> 123 Learning Street, Education City, EC 10101</li>
                    <li><i class="fas fa-phone"></i> +1 (555) 123-4567</li>
                    <li><i class="fas fa-envelope"></i> support@learnsphere.com</li>
                    <li><i class="fas fa-clock"></i> Mon-Fri: 9:00 AM - 6:00 PM</li>
                </ul>
            </div>
        </div>
        
        <div class="footer-bottom">
            <div class="footer-bottom-content">
                <p>&copy; 2023 LearnSphere Learning Management System. All Rights Reserved.</p>
                <div class="footer-bottom-links">
                    <a href="#">Privacy Policy</a>
                    <a href="#">Terms of Service</a>
                    <a href="#">Cookie Policy</a>
                </div>
            </div>
        </div>
    </footer>
    
    
    


    <!-- JavaScript -->
    <script src="script.js"></script>
    <!-- Tilt.js for mouse move animation -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/vanilla-tilt/1.7.2/vanilla-tilt.min.js"></script>
</body>
</html>