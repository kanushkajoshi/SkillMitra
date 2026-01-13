<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>SkillMitra - Empowering People, One Skill at a Time</title>
    <link rel="icon" href="skillmitralogo.jpg" type="image/x-icon">
    <link rel="stylesheet" href="home.css">
</head>

<body>

<!-- ================= HEADER ================= -->
<header class="header-flex">
    <div class="logo-container">
        <img src="skillmitralogo.jpg" alt="SkillMitra Logo" class="logo">
        <h1>SkillMitra</h1>
    </div>

    <nav class="navbar">
        <a href="#about">About Us</a>
        <a href="#features">Features</a>
        <a href="#contact">Contact</a>
        <a href="#faqs">FAQs</a>
    </nav>
</header>

<!-- ================= HERO ================= -->
<section class="hero">
    <h1>Connecting Skilled People to Safe and Local Job Opportunities</h1>
    <p>Bridging the gap between talent and opportunities in underserved communities.</p>

    <div class="cta-buttons">
        <a href="login.jsp" class="cta-btn">Login</a>
        <a href="register.jsp" class="cta-btn">Register</a>
    </div>
</section>

<!-- ================= ABOUT ================= -->
<section id="about" class="about-section">
    <h2>About SkillMitra</h2>
    <p>We're revolutionizing how employers and job seekers connect, making the hiring process simple, transparent, and effective.</p>

    <div class="about-cards">
        <div class="card">
            <img src="connect_icon.png" class="card-icon">
            <h3>Connect Talent</h3>
            <p>Link skilled workers with employers looking for their expertise.</p>
        </div>

        <div class="card">
            <img src="match_icon.png" class="card-icon">
            <h3>Perfect Matches</h3>
            <p>Our platform ensures the right fit for both parties every time.</p>
        </div>

        <div class="card">
            <img src="quality_icon.png" class="card-icon">
            <h3>Quality First</h3>
            <p>Verified profiles and transparent reviews build trust and success.</p>
        </div>
    </div>
</section>

<!-- ================= FEATURES ================= -->
<section id="features">
    <div class="container">
        <h2>Our Features</h2>

        <div class="features-grid">
            <div class="feature-card">
                <h3>Job Posting</h3>
                <p>Easily post jobs and reach skilled workers instantly.</p>
            </div>

            <div class="feature-card">
                <h3>Direct Proposal System</h3>
                <p>Send and receive proposals directly without hassle.</p>
            </div>

            <div class="feature-card">
                <h3>Bidding System</h3>
                <p>Workers can bid on jobs to ensure fair pricing.</p>
            </div>

            <div class="feature-card">
                <h3>Search by Skill & Location</h3>
                <p>Find the right worker or job based on skill and location.</p>
            </div>

            <div class="feature-card">
                <h3>Secure Chat Communication</h3>
                <p>Communicate safely and privately with your connections.</p>
            </div>

            <div class="feature-card">
                <h3>Ratings & Feedback</h3>
                <p>Leave and view feedback to build trust in the community.</p>
            </div>
        </div>
    </div>
</section>

<!-- ================= CONTACT ================= -->
<section id="contact">
    <div class="container">
        <h2>Contact Us</h2>
        <p class="contact-email">support@skillmitra.com</p>

        <form id="contactForm" class="contact-form">
            <input type="text" name="name" placeholder="Your Name" required>
            <input type="email" name="email" placeholder="Your Email" required>
            <textarea name="message" placeholder="Your Message" required></textarea>

            <input type="hidden" name="_subject" value="New Contact Message from SkillMitra">
            <input type="hidden" name="_captcha" value="false">

            <button type="submit">Send Message</button>
        </form>

        <p id="formStatus" style="display:none; margin-top:15px;"></p>
    </div>
</section>

<!-- ================= FAQ ================= -->
<section id="faqs" class="faq-section">
    <h2>Frequently Asked Questions</h2>
    <p>Got questions? We've got answers.</p>

    <div class="faq-container">
        <div class="faq-item">
            <button class="faq-question">How does SkillMitra work?</button>
            <div class="faq-answer">
                <p>SkillMitra connects employers with skilled workers from job posting to payment.</p>
            </div>
        </div>

        <div class="faq-item">
            <button class="faq-question">Is there a fee to use SkillMitra?</button>
            <div class="faq-answer">
                <p>Free for workers. Employers may have charges for premium features.</p>
            </div>
        </div>

        <div class="faq-item">
            <button class="faq-question">How are workers verified?</button>
            <div class="faq-answer">
                <p>ID checks, document uploads, and reviews from employers.</p>
            </div>
        </div>

        <div class="faq-item">
            <button class="faq-question">What jobs are available?</button>
            <div class="faq-answer">
                <p>Tailoring, carpentry, tutoring, home services, and more.</p>
            </div>
        </div>
    </div>
</section>

<!-- ================= FOOTER ================= -->
<footer class="site-footer">
    <p>© 2025 SkillMitra. All Rights Reserved.</p>
    <div class="footer-links">
        <a href="privacy.html">Privacy Policy</a> |
        <a href="#contact">Contact Us</a>
    </div>
</footer>

<!-- ================= SCRIPTS ================= -->
<script>
/* FAQ Toggle */
document.querySelectorAll('.faq-question').forEach(btn => {
    btn.addEventListener('click', () => {
        const ans = btn.nextElementSibling;
        document.querySelectorAll('.faq-answer').forEach(a => a.style.display = "none");
        ans.style.display = (ans.style.display === "block") ? "none" : "block";
    });
});

/* Contact Form */
document.getElementById("contactForm").addEventListener("submit", function(e) {
    e.preventDefault();
    const status = document.getElementById("formStatus");

    fetch("https://formsubmit.co/ajax/9c36c951b94826caf8bf7f93bd1ab129", {
        method: "POST",
        body: new FormData(this)
    })
    .then(res => res.json())
    .then(() => {
        status.style.display = "block";
        status.style.color = "green";
        status.innerHTML = "✅ Message sent successfully!";
        this.reset();
    })
    .catch(() => {
        status.style.display = "block";
        status.style.color = "red";
        status.innerHTML = "❌ Something went wrong.";
    });
});
</script>

</body>
</html>
