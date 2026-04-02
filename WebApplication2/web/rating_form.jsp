<%-- 
    Document   : ratingForm
    Created on : 2 Apr, 2026, 4:51:21 PM
    Author     : Ishitaa Gupta
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="db.DBConnection" %>
<%
    // ── Session guard ─────────────────────────────────────────────────────────
    HttpSession currentSession = request.getSession(false);
    if (currentSession == null) { response.sendRedirect("login.jsp"); return; }

    Integer eid = (Integer) currentSession.getAttribute("eid");
    Integer jid = (Integer) currentSession.getAttribute("jobseekerId");

    if (eid == null && jid == null) { response.sendRedirect("login.jsp"); return; }

    // ── Params ────────────────────────────────────────────────────────────────
    int    jobId       = Integer.parseInt(request.getParameter("job_id"));
    int    employerId  = Integer.parseInt(request.getParameter("employer_id"));
    int    jobseekerId = Integer.parseInt(request.getParameter("jobseeker_id"));
    String ratingBy;
if (jid != null && eid == null) {
    ratingBy = "Jobseeker";
} else if (eid != null && jid == null) {
    ratingBy = "Employer";
} else if (jid != null) {
    // Both set (dirty session) — use URL context to decide
    // jobseeker_dash always passes jobseeker_id matching jid
    String jsIdParam = request.getParameter("jobseeker_id");
    ratingBy = (jsIdParam != null && Integer.parseInt(jsIdParam) == jid) 
               ? "Jobseeker" : "Employer";
} else {
    response.sendRedirect("login.jsp");
    return;
}
    String jobTitle    = "";
    String targetName  = "";

    Connection con = DBConnection.getConnection();
    try {
        // Fetch job title
        PreparedStatement ps1 = con.prepareStatement("SELECT title FROM jobs WHERE job_id=?");
        ps1.setInt(1, jobId);
        ResultSet rs1 = ps1.executeQuery();
        if (rs1.next()) jobTitle = rs1.getString("title");
        rs1.close(); ps1.close();

        // Fetch target person name
        if ("Employer".equals(ratingBy)) {
            // Rating the jobseeker
            PreparedStatement ps2 = con.prepareStatement(
                "SELECT CONCAT(jfirstname,' ',jlastname) AS name FROM jobseeker WHERE jid=?");
            ps2.setInt(1, jobseekerId);
            ResultSet rs2 = ps2.executeQuery();
            if (rs2.next()) targetName = rs2.getString("name");
            rs2.close(); ps2.close();
        } else {
            // Rating the employer
            PreparedStatement ps3 = con.prepareStatement(
                "SELECT CONCAT(efirstname,' ',elastname) AS name FROM employer WHERE eid=?");
            ps3.setInt(1, employerId);
            ResultSet rs3 = ps3.executeQuery();
            if (rs3.next()) targetName = rs3.getString("name");
            rs3.close(); ps3.close();
        }
    } finally {
        con.close();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Rate & Review | SkillMitra</title>
<style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
        font-family: 'Segoe UI', sans-serif;
        background: linear-gradient(135deg, #e8f5e9 0%, #e3f2fd 100%);
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 24px;
    }

    .card {
        background: #fff;
        border-radius: 20px;
        box-shadow: 0 8px 32px rgba(0,0,0,0.12);
        padding: 40px 44px;
        width: 100%;
        max-width: 580px;
        animation: slideUp .35s ease;
    }

    @keyframes slideUp {
        from { opacity: 0; transform: translateY(30px); }
        to   { opacity: 1; transform: translateY(0); }
    }

    .logo { font-size: 22px; font-weight: 800; color: #1b5e20; margin-bottom: 6px; }

    h2 {
        font-size: 22px;
        font-weight: 700;
        color: #1a2a3a;
        margin-bottom: 4px;
    }

    .sub {
        font-size: 14px;
        color: #6b7280;
        margin-bottom: 28px;
    }

    .sub strong { color: #1b5e20; }

    /* ── Overall star picker ─────────────────────────────────── */
    .overall-stars {
        display: flex;
        gap: 10px;
        margin-bottom: 28px;
        justify-content: center;
    }

    .overall-stars input[type="radio"] { display: none; }

    .overall-stars label {
        font-size: 42px;
        cursor: pointer;
        color: #d1d5db;
        transition: color .15s, transform .15s;
        line-height: 1;
    }

    .overall-stars label:hover,
    .overall-stars label.selected,
    .overall-stars input[type="radio"]:checked ~ label { color: #f59e0b; }

    /* hover effect — highlight all stars up to hovered */
    .overall-stars:has(label:nth-child(2):hover) label:nth-child(1),
    .overall-stars:has(label:nth-child(2):hover) label:nth-child(2) { color: #f59e0b; }

    .overall-stars label:hover { transform: scale(1.2); }

    /* ── Criteria rows ───────────────────────────────────────── */
    .criteria-group { margin-bottom: 20px; }
    .criteria-group label { font-size: 14px; font-weight: 600; color: #374151; display: block; margin-bottom: 6px; }

    .mini-stars { display: flex; gap: 6px; }
    .mini-stars input[type="radio"] { display: none; }
    .mini-stars label {
        font-size: 24px;
        cursor: pointer;
        color: #d1d5db;
        transition: color .12s;
    }
    .mini-stars label:hover { color: #f59e0b; }
    .mini-stars input[type="radio"]:checked ~ label { color: #f59e0b; }

    /* ── Textarea ────────────────────────────────────────────── */
    textarea {
        width: 100%;
        border: 1.5px solid #e5e7eb;
        border-radius: 10px;
        padding: 12px 14px;
        font-size: 14px;
        color: #374151;
        resize: vertical;
        min-height: 110px;
        outline: none;
        transition: border-color .2s;
        font-family: inherit;
    }

    textarea:focus { border-color: #1b5e20; }

    .char-count { font-size: 12px; color: #9ca3af; text-align: right; margin-top: 4px; }

    /* ── Buttons ─────────────────────────────────────────────── */
    .btn-row { display: flex; gap: 12px; margin-top: 28px; }

    .btn-submit {
        flex: 1;
        background: linear-gradient(135deg, #1b5e20, #2e7d32);
        color: #fff;
        border: none;
        border-radius: 10px;
        padding: 13px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        transition: opacity .2s, transform .15s;
    }

    .btn-submit:hover { opacity: .92; transform: translateY(-1px); }

    .btn-back {
        padding: 13px 22px;
        border: 1.5px solid #e5e7eb;
        border-radius: 10px;
        background: #fff;
        color: #6b7280;
        font-size: 15px;
        cursor: pointer;
        text-decoration: none;
        display: flex;
        align-items: center;
        transition: background .2s;
    }

    .btn-back:hover { background: #f9fafb; }

    /* ── Divider ─────────────────────────────────────────────── */
    .divider {
        border: none;
        border-top: 1px solid #f3f4f6;
        margin: 22px 0;
    }

    .section-title {
        font-size: 13px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: .6px;
        color: #9ca3af;
        margin-bottom: 14px;
    }

    .required { color: #ef4444; }

    /* ── Validation ──────────────────────────────────────────── */
    .error-msg {
        background: #fef2f2;
        border: 1px solid #fca5a5;
        border-radius: 8px;
        color: #b91c1c;
        font-size: 13px;
        padding: 10px 14px;
        margin-bottom: 18px;
    }
</style>
</head>
<body>
<div class="card">
    <div class="logo">SkillMitra ⭐</div>
    <h2>Rate & Review</h2>
    <p class="sub">
        You are rating <strong><%= targetName %></strong> for the job
        <strong>"<%= jobTitle %>"</strong>
    </p>

    <form action="SubmitRatingServlet" method="post" id="ratingForm" onsubmit="return validateForm()">
        <input type="hidden" name="job_id"       value="<%= jobId %>">
        <input type="hidden" name="employer_id"  value="<%= employerId %>">
        <input type="hidden" name="jobseeker_id" value="<%= jobseekerId %>">
        <input type="hidden" name="rating_by"    value="<%= ratingBy %>">
        <input type="hidden" name="rating_value" id="overallHidden" value="">

        <!-- ── Overall Rating ──────────────────────────────────────── -->
        <p class="section-title">Overall Rating <span class="required">*</span></p>
        <div class="overall-stars" id="overallStars">
            <!-- Stars rendered right-to-left so CSS sibling trick works -->
            <label data-val="1" title="1 — Poor">★</label>
            <label data-val="2" title="2 — Fair">★</label>
            <label data-val="3" title="3 — Good">★</label>
            <label data-val="4" title="4 — Very Good">★</label>
            <label data-val="5" title="5 — Excellent">★</label>
        </div>
        <div id="overallError" class="error-msg" style="display:none;">
            Please select an overall rating before submitting.
        </div>

        <hr class="divider">

        <!-- ── Criteria (role-specific) ────────────────────────────── -->
        <p class="section-title">Detailed Ratings</p>

        <% if ("Employer".equals(ratingBy)) { %>

        <%-- Employer rates Jobseeker --%>
        <%= miniStars("work_quality",         "Work Quality") %>
        <%= miniStars("performance",          "Performance") %>
        <%= miniStars("punctuality",          "Punctuality") %>
        <%= miniStars("professional_behavior","Professional Behavior") %>

        <% } else { %>

        <%-- Jobseeker rates Employer --%>
        <%= miniStars("employer_behavior",       "Employer Behavior") %>
        <%= miniStars("timely_payment",          "Timely Payment") %>
        <%= miniStars("work_environment",        "Work Environment") %>
        <%= miniStars("fairness_communication",  "Fairness & Communication") %>

        <% } %>

        <hr class="divider">

        <!-- ── Written Review ──────────────────────────────────────── -->
        <p class="section-title">Written Review</p>
        <textarea name="review_text" id="reviewText"
            placeholder="Share your experience (optional)…"
            maxlength="1000"
            oninput="document.getElementById('charCount').textContent = this.value.length + '/1000'">
        </textarea>
        <div class="char-count"><span id="charCount">0</span>/1000</div>

        <div class="btn-row">
            <a href="javascript:history.back()" class="btn-back">← Back</a>
            <button type="submit" class="btn-submit">Submit Rating ⭐</button>
        </div>
    </form>
</div>

<script>
// ── Overall star picker ──────────────────────────────────────────────────────
const overallLabels = document.querySelectorAll("#overallStars label");
const overallHidden = document.getElementById("overallHidden");

overallLabels.forEach(function(lbl, idx) {
    lbl.addEventListener("click", function() {
        const val = parseInt(this.dataset.val);
        overallHidden.value = val;
        overallLabels.forEach(function(l, i) {
            l.style.color = (i < val) ? "#f59e0b" : "#d1d5db";
        });
        document.getElementById("overallError").style.display = "none";
    });

    lbl.addEventListener("mouseenter", function() {
        const val = parseInt(this.dataset.val);
        overallLabels.forEach(function(l, i) {
            l.style.color = (i < val) ? "#f59e0b" : "#d1d5db";
        });
    });

    lbl.addEventListener("mouseleave", function() {
        const selected = parseInt(overallHidden.value) || 0;
        overallLabels.forEach(function(l, i) {
            l.style.color = (i < selected) ? "#f59e0b" : "#d1d5db";
        });
    });
});

// ── Mini star pickers ────────────────────────────────────────────────────────
document.querySelectorAll(".mini-stars").forEach(function(group) {
    const labels = group.querySelectorAll("label");
    const inputs = group.querySelectorAll("input[type='radio']");

    labels.forEach(function(lbl, idx) {
        lbl.addEventListener("click", function() {
            inputs[idx].checked = true;
            labels.forEach(function(l, i) {
                l.style.color = (i <= idx) ? "#f59e0b" : "#d1d5db";
            });
        });

        lbl.addEventListener("mouseenter", function() {
            labels.forEach(function(l, i) {
                l.style.color = (i <= idx) ? "#fcd34d" : "#d1d5db";
            });
        });

        lbl.addEventListener("mouseleave", function() {
            const checkedIdx = Array.from(inputs).findIndex(function(inp){ return inp.checked; });
            labels.forEach(function(l, i) {
                l.style.color = (i <= checkedIdx) ? "#f59e0b" : "#d1d5db";
            });
        });
    });
});

// ── Validation ───────────────────────────────────────────────────────────────
function validateForm() {
    if (!overallHidden.value) {
        document.getElementById("overallError").style.display = "block";
        document.getElementById("overallStars").scrollIntoView({ behavior: "smooth" });
        return false;
    }
    return true;
}
</script>
</body>
</html>
<%!
// Helper: render mini 5-star radio group
private String miniStars(String name, String label) {
    StringBuilder sb = new StringBuilder();
    sb.append("<div class='criteria-group'>");
    sb.append("<label>").append(label).append("</label>");
    sb.append("<div class='mini-stars'>");
    for (int i = 1; i <= 5; i++) {
        sb.append("<input type='radio' name='").append(name)
          .append("' id='").append(name).append(i)
          .append("' value='").append(i).append("'>");
        sb.append("<label for='").append(name).append(i).append("' title='").append(i).append("'>★</label>");
    }
    sb.append("</div></div>");
    return sb.toString();
}
%>
