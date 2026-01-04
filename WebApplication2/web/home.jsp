
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
<!--           <header>
        <div class="logo-container">
            <img src="skillmitralogo.png" alt="SkillMitra Logo" class="logo">
            <h1>Skill Mitra</h1>
        </div>
        <nav>
                    <a href="#about">About Us</a>
        <nav>
    </header>-->
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
    <section class="hero">
        <h1>Connecting Skilled People to Safe and Local Job Opportunities</h1>
        <p>Bridging the gap between talent and opportunities in underserved communities.</p>

        <div class="cta-buttons">
            <a href="login.jsp
               " class="cta-btn">Login</a>
            <a href="register.jsp" class="cta-btn">Register</a>
        </div>
    </section>
<section id="about" class="about-section">
       <div class ="background">
        <h2>About SkillMitra</h2>
        <p>We're revolutionizing how employers and job seekers connect, making the hiring process simple, transparent, and effective.</p>
        
        <div class="about-cards">
            <div class="card">
                <img src="connect_icon.png" alt="Connect Talent" class="card-icon">
                <h3>Connect Talent</h3>
                <p>Link skilled workers with employers looking for their expertise.</p>
            </div>
            <div class="card">
                <img src="match_icon.png" alt="Perfect Matches" class="card-icon">
                <h3>Perfect Matches</h3>
                <p>Our platform ensures the right fit for both parties every time.</p>
            </div>
             <div class="card">
                <img src="quality_icon.png" alt="Quality First" class="card-icon">
                <h3>Quality First</h3>
                <p>Verified profiles and transparent reviews build trust and success.</p>
            </div>
        </div>
      </div>
    </section>

<section id="faqs" class="faq-section">
    <h2>Frequently Asked Questions</h2>
    <p>Got questions? We've got answers.</p>

    <div class="faq-container">
        <div class="faq-item">
            <button class="faq-question">How does SkillMitra work?</button>
            <div class="faq-answer">
                <p>SkillMitra connects employers with skilled workers. Employers post jobs, workers apply, and our platform facilitates the entire hiring process from application to payment.</p>
            </div>
        </div>

        <div class="faq-item">
            <button class="faq-question">Is there a fee to use SkillMitra?</button>
            <div class="faq-answer">
                <p>Using SkillMitra is free for workers. Employers may have a small fee for posting jobs or premium features.</p>
            </div>
        </div>
         <div class="faq-item">
            <button class="faq-question">How are workers verified?</button>
            <div class="faq-answer">
                <p>Workers are verified via ID checks, document uploads, and reviews from past employers.</p>
            </div>
        </div>

        <div class="faq-item">
            <button class="faq-question">What types of jobs can I find?</button>
            <div class="faq-answer">
                <p>SkillMitra lists various jobs including tailoring, carpentry, tutoring, home services, and more local and skilled opportunities.</p>
            </div>
        </div>

        <div class="faq-item">
            <button class="faq-question">How do payments work?</button>
             <div class="faq-answer">
                <p>Payments are securely handled through our platform once the work is completed and approved by the employer.</p>
            </div>
        </div>
    </div>
</section>

    </body>
    <script>
const faqButtons = document.querySelectorAll('.faq-question');

faqButtons.forEach(button => {
    button.addEventListener('click', () => {
        const answer = button.nextElementSibling;
        const isOpen = answer.style.display === 'block';

        // Close all answers
        document.querySelectorAll('.faq-answer').forEach(ans => ans.style.display = 'none');

        // Toggle current
        answer.style.display = isOpen ? 'none' : 'block';
    });
});
</script>

</html>
