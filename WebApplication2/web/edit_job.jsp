<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Job</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/emp_dash.css">
</head>

<body>

<div class="edit-page-wrapper">

    <div class="edit-job-card">

        <h2>Edit Job</h2>

        <form class="edit-job-form" action="EditJobServlet" method="post">

            <input type="hidden" name="job_id"
                   value="<%= request.getAttribute("job_id") %>">

            <label>Job Title *</label>
            <input type="text" name="title"
                   value="<%= request.getAttribute("title") %>" required>

            <label>Job Description *</label>
            <textarea name="description" rows="4" required><%= request.getAttribute("description") %></textarea>

            <label>Locality / Area *</label>
            <input type="text" name="locality"
                   value="<%= request.getAttribute("locality") %>" required>

            <div class="edit-job-row">
                <div>
                    <label>City *</label>
                    <input type="text" name="city"
                           value="<%= request.getAttribute("city") %>" required>
                </div>

                <div>
                    <label>State *</label>
                    <input type="text" name="state"
                           value="<%= request.getAttribute("state") %>" required>
                </div>
            </div>

            <div class="edit-job-row">
                <div>
                    <label>Country *</label>
                    <input type="text" name="country"
                           value="<%= request.getAttribute("country") %>" required>
                </div>

                <div>
                    <label>Zip *</label>
                    <input type="text" name="zip"
                           value="<%= request.getAttribute("zip") %>" required>
                </div>
            </div>

            <div class="edit-job-row">
                <div>
                    <label>Daily Wage (₹) *</label>
                    <input type="text" name="salary"
                           value="<%= request.getAttribute("salary") %>" required>
                </div>

                <div>
                    <label>Max Salary (optional)</label>
                    <input type="text" name="min_salary"
                           value="<%= request.getAttribute("min_salary") %>">
                </div>
            </div>

            <label>Job Type *</label>
            <input type="text" name="job_type"
                   value="<%= request.getAttribute("job_type") %>" required>

            <label>Experience Level</label>
            <input type="text" name="experience_level"
                   value="<%= request.getAttribute("experience_level") %>">

            <label>Languages Preferred</label>
            <input type="text" name="languages_preferred"
                   value="<%= request.getAttribute("languages_preferred") %>">

            <button type="submit" class="post-job-btn">
                Update Job
            </button>

        </form>

    </div>

</div>

</body>
</html>
