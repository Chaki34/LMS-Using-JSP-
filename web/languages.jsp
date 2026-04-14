<!-- LANGUAGE SCROLLER FRAGMENT -->

<style>
/* ===== LANGUAGE SECTION ===== */
.lang-section {
    margin: 50px auto;
    max-width: 1200px;
    padding: 20px;
}

.lang-title {
    text-align: center;
    font-size: 26px;
    margin-bottom: 25px;
    color: #2c3e50;
}

/* ===== MARQUEE BASE ===== */
.marquee {
    overflow: hidden;
    white-space: nowrap;
    background: #ffffff;
    border-radius: 12px;
    padding: 15px 0;
    margin-bottom: 20px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.05);
}

/* track */
.track {
    display: inline-flex;
    gap: 40px;
    align-items: center;
    font-size: 16px;
    font-weight: 600;
    color: #34495e;
}

/* items */
.track span {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 14px;
    background: #f4f7fb;
    border-radius: 30px;
    white-space: nowrap;
}

/* icons color */
.track i {
    color: #4a6fa5;
}

/* ===== ANIMATIONS ===== */

/* LEFT → RIGHT */
.left-to-right .track {
    animation: moveLTR 20s linear infinite;
}

@keyframes moveLTR {
    0% {
        transform: translateX(-50%);
    }
    100% {
        transform: translateX(0%);
    }
}

/* RIGHT → LEFT */
.right-to-left .track {
    animation: moveRTL 20s linear infinite;
}

@keyframes moveRTL {
    0% {
        transform: translateX(0%);
    }
    100% {
        transform: translateX(-50%);
    }
}

/* pause on hover */
.marquee:hover .track {
    animation-play-state: paused;
}
</style>

<div class="lang-section">

    <h2 class="lang-title">
        <i class="fas fa-code"></i> Technologies We Cover
    </h2>

    <!-- LEFT TO RIGHT (Frontend) -->
    <div class="marquee left-to-right">
        <div class="track">
            <span><i class="fab fa-html5"></i> HTML</span>
            <span><i class="fab fa-css3-alt"></i> CSS</span>
            <span><i class="fab fa-js"></i> JavaScript</span>
            <span><i class="fab fa-react"></i> React</span>
            <span><i class="fab fa-angular"></i> Angular</span>
            <span><i class="fab fa-vuejs"></i> Vue</span>
            <span>TypeScript</span>
            <span>Bootstrap</span>

            <!-- duplicate for smooth loop -->
            <span><i class="fab fa-html5"></i> HTML</span>
            <span><i class="fab fa-angular"></i> Angular</span>
            <span><i class="fab fa-js"></i> JavaScript</span>
            <span><i class="fab fa-css3-alt"></i> CSS</span>
            <span><i class="fab fa-js"></i> JavaScript</span>

        </div>
    </div>

    <!-- RIGHT TO LEFT (Backend + DB) -->
    <div class="marquee right-to-left">
        <div class="track">
            <span><i class="fab fa-java"></i> Java</span>
            <span>Spring Boot</span>
            <span>Node.js</span>
            <span>Express.js</span>
            <span>Python</span>
            <span>Django</span>
            <span>PHP</span>
            <span>Laravel</span>

            <span>MySQL</span>
            <span>MongoDB</span>
            <span>PostgreSQL</span>
            <span>Oracle DB</span>

            <!-- duplicate for smooth loop -->
            <span>Java</span>
            <span>Spring Boot</span>
            <span>Node.js</span>
        </div>
    </div>

</div>