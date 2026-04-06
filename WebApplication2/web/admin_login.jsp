<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // If already logged in, go to dashboard
    HttpSession adminSession = request.getSession(false);
    if (adminSession != null && adminSession.getAttribute("adminId") != null) {
        response.sendRedirect("admin_dash.jsp");
        return;
    }
    String errorMsg = (String) request.getAttribute("adminLoginError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Login | SkillMitra</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; font-family:"Segoe UI", Tahoma, sans-serif; }

        body {
            background: linear-gradient(135deg, #3e5a70 0%, #4f6d84 50%, #6b8fa8 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-card {
            background: #fff;
            border-radius: 18px;
            padding: 42px 44px;
            width: 420px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.25);
        }

        .login-header {
            text-align: center;
            margin-bottom: 32px;
        }

        .login-header .logo-circle {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: #4f6d84;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 14px;
            font-size: 22px;
        }

        .login-header h2 {
            font-size: 22px;
            color: #1a2a3a;
            font-weight: 700;
        }

        .login-header p {
            font-size: 13px;
            color: #9ca3af;
            margin-top: 4px;
        }

        .admin-badge {
            display: inline-block;
            background: #fef9c3;
            color: #854d0e;
            font-size: 11px;
            font-weight: 700;
            padding: 3px 12px;
            border-radius: 20px;
            margin-top: 8px;
            letter-spacing: 0.05em;
            text-transform: uppercase;
        }

        label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 6px;
        }

        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 11px 14px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 14px;
            color: #1a2a3a;
            outline: none;
            transition: border-color 0.2s;
            margin-bottom: 18px;
        }

        input[type="text"]:focus,
        input[type="password"]:focus {
            border-color: #4f6d84;
            box-shadow: 0 0 0 3px rgba(79,109,132,0.12);
        }

        .login-btn {
            width: 100%;
            padding: 12px;
            background: #4f6d84;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
            margin-top: 4px;
        }

        .login-btn:hover { background: #3e5a70; }

        .error-box {
            background: #fef2f2;
            border: 1px solid #fca5a5;
            color: #991b1b;
            padding: 10px 14px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 18px;
        }

        .back-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            font-size: 13px;
            color: #6b7280;
            text-decoration: none;
        }

        .back-link:hover { color: #4f6d84; }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="login-header">
            <div class="logo-circle">
                <img src="skillmitralogo.jpg" alt="Logo"
                     style="width:40px; height:40px; border-radius:50%; object-fit:cover;"
                     onerror="this.outerHTML='<span style=\'color:white;font-weight:700;\'>SM</span>'">
            </div>
            <h2>SkillMitra</h2>
            <p>Administration Portal</p>
            <span class="admin-badge">🔒 Admin Access Only</span>
        </div>

        <% if (errorMsg != null) { %>
        <div class="error-box">⚠️ <%= errorMsg %></div>
        <% } %>

        <form action="AdminLoginServlet" method="post">
            <label for="username">Username</label>
            <input type="text" id="username" name="username"
                   placeholder="Enter admin username" required autocomplete="off">

            <label for="password">Password</label>
            <input type="password" id="password" name="password"
                   placeholder="Enter admin password" required>

            <button type="submit" class="login-btn">Sign In →</button>
        </form>

        <a href="login.jsp" class="back-link">← Back to main login</a>
    </div>
</body>
</html>
