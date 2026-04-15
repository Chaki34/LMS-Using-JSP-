<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>The Daily Scholar | Study Materials & Archives</title>

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Crimson+Text:ital,wght@0,400;0,700;1,400&family=Playfair+Display:wght@700;900&family=Special+Elite&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <!-- Three.js and Animation Library -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.9.1/gsap.min.js"></script>

    <style>
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

        /* Newspaper Header */
        .top-bar {
            background: var(--ink);
            color: var(--paper);
            padding: 8px 0;
            border-bottom: 2px solid var(--accent-red);
            font-family: 'Special Elite', cursive;
            font-size: 14px;
        }
        .top-bar-content { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; padding: 0 20px; }

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
            display: flex; justify-content: space-between;
            max-width: 1200px; margin: 0 auto; font-size: 14px;
        }
        .logo-title {
            font-family: 'Playfair Display', serif;
            font-size: 60px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: -2px;
            margin: 10px 0;
            color: var(--ink);
            text-decoration: none;
            display: block;
        }

        /* Three.js Canvas Section */
        #archive-canvas-container {
            width: 100%;
            height: 450px;
            background: #e8e4d9;
            border: 2px solid var(--ink);
            margin-bottom: 30px;
            position: relative;
            cursor: pointer;
            box-shadow: inset 0 0 40px rgba(0,0,0,0.1);
        }
        #book-label {
            position: absolute;
            top: 15px;
            left: 50%;
            transform: translateX(-50%);
            background: white;
            padding: 8px 20px;
            border: 1px solid var(--ink);
            font-family: 'Special Elite', cursive;
            box-shadow: 4px 4px 0px var(--ink);
            display: none;
            z-index: 10;
        }

        /* Layout */
        .main-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            display: grid;
            grid-template-columns: 3fr 1fr;
            gap: 40px;
        }

        .section-title {
            font-family: 'Playfair Display', serif;
            font-size: 32px;
            border-bottom: 2px solid var(--ink);
            margin-bottom: 25px;
            text-transform: uppercase;
        }

        /* Material Grid / PDF Section */
        .materials-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 25px;
        }
        .book-card {
            background: white;
            border: 1px solid var(--ink);
            padding: 15px;
            position: relative;
            transition: all 0.3s;
        }
        .book-card:hover {
            transform: translateY(-5px);
            box-shadow: 8px 8px 0px var(--ink);
        }
        .book-image {
            width: 100%;
            height: 200px;
            background: #eee;
            border: 1px solid #ccc;
            margin-bottom: 10px;
            display: flex;
            align-items: center; justify-content: center;
            overflow: hidden;
        }
        .book-image img {
            width: 100%; height: 100%; object-fit: cover;
            filter: grayscale(100%) sepia(20%);
        }

        .status-badge {
            position: absolute;
            top: 10px; right: 10px;
            padding: 5px 10px;
            font-family: 'Special Elite', cursive;
            font-size: 10px;
            background: var(--paper);
            border: 1px solid var(--ink);
            z-index: 5;
        }
        .status-free { color: green; }
        .status-paid { color: var(--accent-red); }

        .action-btn {
            display: block; text-align: center;
            background: var(--ink); color: var(--paper);
            text-decoration: none; padding: 10px;
            font-family: 'Special Elite', cursive;
            font-size: 12px; margin-top: 10px;
        }
        .action-btn:hover { background: var(--accent-red); }

        /* Sidebar Ads / Info */
        .sidebar-box {
            border: 1px solid var(--ink);
            padding: 15px;
            margin-bottom: 20px;
            background: rgba(255,255,255,0.3);
        }

        .sidebar-box h4 {
            font-family: 'Playfair Display', serif;
            text-decoration: underline;
            margin-bottom: 10px;
        }

        /* REVIEWS */
        .reviews-section {
            max-height: 400px;
            overflow-y: auto;
        }

        .review-item {
            border-bottom: 1px dashed #ccc;
            padding: 10px 0;
            font-size: 13px;
        }

        .review-stars {
            color: #d4af37;
            font-size: 14px;
        }

        .review-item span {
            font-family: 'Special Elite';
            font-size: 11px;
            color: var(--accent-red);
        }

        /* AI SECTION */
        .ai-section {
            position: relative;
        }

        .ai-input {
            width: 100%;
            padding: 8px;
            border: 1px solid var(--ink);
            font-family: 'Special Elite', cursive;
            margin-bottom: 8px;
        }

        .ai-btn {
            width: 100%;
            padding: 8px;
            background: var(--ink);
            color: var(--paper);
            border: none;
            font-family: 'Special Elite', cursive;
            cursor: pointer;
            transition: 0.3s;
        }

        .ai-btn:hover {
            background: var(--accent-red);
        }

        .ai-response {
            margin-top: 10px;
            padding: 8px;
            background: #f9f9f9;
            border-left: 3px solid var(--accent-red);
            font-size: 12px;
            min-height: 40px;
        }

        footer {
            border-top: 4px double var(--ink);
            margin: 50px 20px 0 20px;
            padding: 30px;
            text-align: center;
            font-family: 'Special Elite', cursive;
        }

        /* =========================
           MOBILE RESPONSIVE (SMALL SCREENS)
        ========================= */

        @media (max-width: 600px) {

            body {
                font-size: 14px;
            }

            /* TOP BAR */
            .top-bar-content {
                flex-direction: column;
                text-align: center;
                gap: 5px;
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

            /* MAIN LAYOUT (STACK) */
            .main-container {
                grid-template-columns: 1fr;
                gap: 20px;
                padding: 10px;
            }

            /* SECTION TITLE */
            .section-title {
                font-size: 20px;
                margin-bottom: 15px;
            }

            /* THREE JS CANVAS */
            #archive-canvas-container {
                height: 250px;
            }

            #book-label {
                font-size: 12px;
                padding: 5px 10px;
            }

            /* BOOK GRID */
            .materials-grid {
                grid-template-columns: 1fr;
                gap: 15px;
            }

            /* BOOK CARD */
            .book-card {
                padding: 12px;
            }

            .book-image {
                height: 150px;
            }

            .book-title {
                font-size: 16px;
            }

            .action-btn {
                font-size: 11px;
                padding: 8px;
            }

            .status-badge {
                font-size: 9px;
                padding: 4px 6px;
            }

            /* SIDEBAR */
            aside {
                order: 2;
            }

            .sidebar-box {
                padding: 10px;
            }

            .sidebar-box h4 {
                font-size: 16px;
            }

            .sidebar-box p {
                font-size: 13px;
            }

            .sidebar-box input {
                font-size: 12px;
            }




            /* FOOTER */
            footer {
                padding: 20px 10px;
                margin: 30px 10px 0 10px;
                font-size: 12px;
            }

            /* IMAGE FIX */
            img {
                max-width: 100%;
                height: auto;
            }
        }

        /* MOVE REVIEWS TO MAIN SECTION ON MOBILE */
        @media (max-width: 600px) {

            .reviews-section {
                order: -1;
            }

            aside {
                display: flex;
                flex-direction: column;
            }

            /* OPTIONAL: move reviews above everything */
            .reviews-section {
                width: 100%;
            }
        }
        /* AI section moves properly */
        @media (max-width: 600px) {

            .ai-section {
                order: 3;
            }

        }

        /* BETTER BALANCED MOBILE SPACING */
        @media (max-width: 600px) {

            .main-container {
                padding: 10px 15px;
            }

            aside {
                margin-left: 8px;
                margin-right: 5px;
            }

            .sidebar-box {
                margin-left: 5px;
                margin-right: 5px;
            }
        }
    </style>
</head>
<body>

<div class="top-bar">
    <div class="top-bar-content">
        <div>SPECIAL EDITION: THE DIGITAL ARCHIVE</div>
        <div><%= new java.text.SimpleDateFormat("MMMM dd, yyyy").format(new java.util.Date()) %></div>
    </div>
</div>

<div class="news-header">
    <div class="header-meta">
        <span>ESTABLISHED 1894</span>
        <span>LITERATURE & RESEARCH</span>
        <span>No. 442</span>
    </div>
    <a href="#" class="logo-title">The Scholar's Library</a>
    <p><i>"A room without books is like a body without a soul."</i></p>
</div>

<div class="main-container">

    <!-- LEFT COLUMN -->
    <main>
        <h2 class="section-title">Interactive 3D Archive</h2>

        <!-- THREE.JS AREA -->
        <div id="archive-canvas-container">
            <div id="book-label">TITLE: <span id="selected-title"></span></div>
        </div>

        <h2 class="section-title">Books & PDF Archives</h2>
        <div class="materials-grid">
            <!-- Free Content -->
            <div class="book-card">
                <div class="status-badge status-free"><i class="fas fa-unlock"></i> FREE</div>
                <div class="book-image">
                    <img src="https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=500" alt="Book">
                </div>
                <div class="book-title" style="font-weight:bold; font-family:'Playfair Display';">Logic Foundations</div>
                <p style="font-size:12px; margin:5px 0;">Standard reference for introductory logic.</p>
                <a href="#" class="action-btn">DOWNLOAD PDF</a>
            </div>

            <!-- Paid Content -->
            <div class="book-card">
                <div class="status-badge status-paid"><i class="fas fa-lock"></i> $12.00</div>
                <div class="book-image">
                    <img src="https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=500" alt="Book">
                </div>
                <div class="book-title" style="font-weight:bold; font-family:'Playfair Display';">The Machine Mind</div>
                <p style="font-size:12px; margin:5px 0;">Exclusive research on early neural networks.</p>
                <a href="#" class="action-btn">PAY TO UNLOCK</a>
            </div>

            <!-- Paid Content -->
            <div class="book-card">
                <div class="status-badge status-paid"><i class="fas fa-lock"></i> $9.50</div>
                <div class="book-image">
                    <img src="https://images.unsplash.com/photo-1516979187457-637abb4f9353?q=80&w=500" alt="Book">
                </div>
                <div class="book-title" style="font-weight:bold; font-family:'Playfair Display';">Renaissance Arts</div>
                <p style="font-size:12px; margin:5px 0;">Digitalized portfolio of historical designs.</p>
                <a href="#" class="action-btn">PURCHASE ACCESS</a>
            </div>
        </div>
    </main>

    <!-- RIGHT COLUMN -->
    <aside>
        <div class="sidebar-box">
            <h4>LIBRARIAN'S NOTE</h4>
            <p style="font-size: 14px; font-style: italic;">"Please click on any volume in the 3D rack to pull it from the shelf for detailed inspection."</p>
        </div>
        <div class="sidebar-box">
            <h4>QUICK SEARCH</h4>
            <input type="text" style="width:100%; padding:8px; font-family:'Special Elite';" placeholder="Keyword...">
        </div>

        <div class="sidebar-box reviews-section">
            <h4>USER REVIEWS</h4>

            <div class="review-item">
                <div class="review-stars">★★★★★</div>
                <p>"Amazing collection of study material!"</p>
                <span>- Rahul</span>
            </div>

            <div class="review-item">
                <div class="review-stars">★★★★☆</div>
                <p>"Very useful for exams."</p>
                <span>- Anjali</span>
            </div>

            <!-- Repeat like this up to 10 reviews -->

        </div>

        <div class="sidebar-box ai-section">
            <h4>AI ASSISTANT</h4>

            <p style="font-size: 13px; margin-bottom: 10px;">
                "Ask anything about your studies, instantly powered by AI."
            </p>

            <input type="text" class="ai-input" placeholder="Ask your question...">

            <button class="ai-btn">
                <i class="fas fa-robot"></i> Ask AI
            </button>

            <!-- Response Box -->
            <div class="ai-response">
                <p><i>AI response will appear here...</i></p>
            </div>
        </div>

    </aside>
</div>

<footer>
    <p>&copy; 1894 - 2025 The Daily Scholar Press. Developed via WebGL Engine.</p>
</footer>

<!-- Three.js Interactive Script -->
<script>
    let scene, camera, renderer, raycaster, mouse;
    let books = [];
    let selectedBook = null;

    const bookVolumes = [
        { name: "Vol I: C Language", color: 0x444444 },
        { name: "Vol II: C++ Pro", color: 0x003366 },
        { name: "Vol III: Java Core", color: 0x8b0000 },
        { name: "Vol IV: Python 3", color: 0x2b5b84 },
        { name: "Vol V: Machine Learning", color: 0x006633 },
        { name: "Vol VI: SQL Data", color: 0x333333 },
        { name: "Vol VII: Algorithms", color: 0x4a148c },
        { name: "Vol VIII: Web Dev", color: 0xe65100 },
        { name: "Vol IX: Security", color: 0x212121 },
        { name: "Vol X: Cloud Computing", color: 0x01579b }
    ];

    function init() {
        const container = document.getElementById('archive-canvas-container');
        scene = new THREE.Scene();
        camera = new THREE.PerspectiveCamera(45, container.clientWidth / container.clientHeight, 0.1, 1000);
        camera.position.set(0, 2, 10);

        renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
        renderer.setSize(container.clientWidth, container.clientHeight);
        container.appendChild(renderer.domElement);

        raycaster = new THREE.Raycaster();
        mouse = new THREE.Vector2();

        // Shelf (The Rack)
        const woodMat = new THREE.MeshStandardMaterial({ color: 0x3d2b1f });
        const shelfPlank = new THREE.Mesh(new THREE.BoxGeometry(14, 0.3, 4), woodMat);
        shelfPlank.position.y = -1.2;
        scene.add(shelfPlank);

        const shelfBack = new THREE.Mesh(new THREE.BoxGeometry(14, 5, 0.1), woodMat);
        shelfBack.position.set(0, 1.3, -1.8);
        scene.add(shelfBack);

        // Add 10 Books
        bookVolumes.forEach((v, i) => {
            const group = new THREE.Group();
            const geometry = new THREE.BoxGeometry(0.8, 3.5, 2.5);
            const mats = [
                new THREE.MeshStandardMaterial({ color: v.color }), // spine
                new THREE.MeshStandardMaterial({ color: v.color }), // back
                new THREE.MeshStandardMaterial({ color: 0xffffff }), // top
                new THREE.MeshStandardMaterial({ color: 0xffffff }), // bottom
                new THREE.MeshStandardMaterial({ color: v.color }), // side
                new THREE.MeshStandardMaterial({ color: v.color }), // side
            ];
            const mesh = new THREE.Mesh(geometry, mats);
            group.add(mesh);

            const xPos = -5.8 + (i * 1.3);
            group.position.set(xPos, 0.6, 0);
            group.userData = { title: v.name, origPos: new THREE.Vector3(xPos, 0.6, 0) };

            books.push(group);
            scene.add(group);
        });

        // Lights
        scene.add(new THREE.AmbientLight(0xffffff, 0.8));
        const pLight = new THREE.PointLight(0xffffff, 0.5);
        pLight.position.set(5, 5, 5);
        scene.add(pLight);

        container.addEventListener('click', handleClick);
        animate();
    }

    function handleClick(e) {
        const rect = document.getElementById('archive-canvas-container').getBoundingClientRect();
        mouse.x = ((e.clientX - rect.left) / rect.width) * 2 - 1;
        mouse.y = -((e.clientY - rect.top) / rect.height) * 2 + 1;

        raycaster.setFromCamera(mouse, camera);
        const intersects = raycaster.intersectObjects(books, true);

        if (intersects.length > 0) {
            let target = intersects[0].object;
            while(target.parent !== scene) target = target.parent;

            if (selectedBook === target) {
                returnBook(target);
            } else {
                if (selectedBook) returnBook(selectedBook);
                inspectBook(target);
            }
        } else if (selectedBook) {
            returnBook(selectedBook);
        }
    }

    function inspectBook(book) {
        selectedBook = book;
        document.getElementById('book-label').style.display = 'block';
        document.getElementById('selected-title').innerText = book.userData.title;

        gsap.to(book.position, { x: 0, y: 1.5, z: 5, duration: 0.7, ease: "power2.out" });
        gsap.to(book.rotation, { y: Math.PI / 2, x: 0.2, duration: 0.7 });
    }

    function returnBook(book) {
        selectedBook = null;
        document.getElementById('book-label').style.display = 'none';

        gsap.to(book.position, {
            x: book.userData.origPos.x,
            y: book.userData.origPos.y,
            z: book.userData.origPos.z,
            duration: 0.5
        });
        gsap.to(book.rotation, { x: 0, y: 0, z: 0, duration: 0.5 });
    }

    function animate() {
        requestAnimationFrame(animate);
        renderer.render(scene, camera);
    }

    init();
</script>

<script>
    document.querySelector('.ai-btn').addEventListener('click', function () {
        const input = document.querySelector('.ai-input').value;
        const responseBox = document.querySelector('.ai-response');

        if (!input.trim()) {
            responseBox.innerHTML = "<p>Please enter a question.</p>";
            return;
        }

        // Dummy AI response (you can connect backend later)
        responseBox.innerHTML = "<p><strong>AI:</strong> Searching knowledge archives for \"" + input + "\"...</p>";

        setTimeout(() => {
            responseBox.innerHTML = "<p><strong>AI:</strong> This topic is related to your study materials. Please explore the archive section above.</p>";
        }, 1000);
    });
</script>

</body>
</html>