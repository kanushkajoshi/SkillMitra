<%@ page contentType="text/html; charset=UTF-8" %>
<html>
<head>
<title>Email Verification</title>
</head>
<body>

<h2>Email Verification</h2>

<% if(request.getAttribute("error")!=null){ %>
<p style="color:red;font-weight:bold;">
<%=request.getAttribute("error")%>
</p>
<% } %>
<p style="color:blue;">
OTP expires in:
<span id="timer">05:00</span>
</p>

<form action="VerifyOtpServlet" method="post">
Enter OTP:
<input type="text" name="otp" required>
<button type="submit">Verify OTP</button>
</form>

<br>

<form action="ResendOtpServlet" method="post">
<button type="submit">Resend OTP</button>
</form>

<br>
<a href="jobseeker_register.jsp">⬅ Back</a>


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
