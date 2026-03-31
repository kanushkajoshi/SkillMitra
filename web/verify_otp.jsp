<%@ page contentType="text/html; charset=UTF-8" %>

<%
/* Prevent browser cache */
response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
response.setHeader("Pragma","no-cache");
response.setDateHeader("Expires", 0);

/* Check OTP session */
if(session.getAttribute("otp")==null){
    response.sendRedirect("jobseeker_register.jsp");
    return;
}
%>
<html>
<head>
<title>Email Verification</title>
<link rel="stylesheet" href="verify_otp.css">
</head>
<body>

<!-- HEADER -->
<div class="navbar">
    <div class="nav-container">
        <div class="logo">
           <img src="skillmitralogo.jpg" alt="SkillMitra Logo">
            SkillMitra
        </div>
    </div>
</div>

<div class="otp-container">

<div class="otp-card">

<h2 class="title">Email Verification</h2>
<p class="subtitle">Enter the OTP sent to your email</p>

<% if(request.getAttribute("error")!=null){ %>
<p class="error-msg">
<%=request.getAttribute("error")%>
</p>
<% } %>

<p class="timer">
OTP expires in:
<span id="timer">05:00</span>
</p>

<form action="VerifyOtpServlet" method="post">

<label>Enter OTP:</label>

<input class="otp-input" type="text" name="otp" maxlength="6" required>

<div class="btn-row">

<button class="verifyBtn" type="submit">
Verify OTP
</button>

</form>

<form action="ResendOtpServlet" method="post">

<button class="resendBtn" type="submit">
Resend OTP
</button>

</form>

</div>

<div class="back-link">
<a href="jobseeker_register.jsp">⬅ Back</a>
</div>

</div>
</div>

</body>

<script>
let time = 300; // 5 minutes

let timer = setInterval(function(){

    let minutes = Math.floor(time/60);
    let seconds = time%60;

    seconds = seconds<10 ? "0"+seconds : seconds;

    document.getElementById("timer")
        .innerText = minutes + ":" + seconds;

    time--;

    if(time<0){
        clearInterval(timer);

        document.getElementById("timer")
            .innerText = "Expired";

        alert("OTP expired! Please resend.");
    }

},1000);
</script>

</html>