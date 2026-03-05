<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>Edit Job</title>
    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/edit_job.css">
</head>

<body>

<div class="edit-page-wrapper">

    <div class="edit-job-card">

        <h2>Edit Job</h2>

        <form class="edit-job-form"
              action="EditJobServlet"
              method="post">

            <!-- Hidden Fields -->
            <input type="hidden"
                   name="job_id"
                   value="<%= request.getAttribute("job_id") %>">

            <input type="hidden"
                   name="skill_id"
                   value="<%= request.getAttribute("skill_id") %>">


            <!-- Job Title -->
            <label>Job Title *</label>
            <input type="text" name="title"
                   value="<%= request.getAttribute("title") %>"
                   required>


            <!-- Description -->
            <label>Job Description *</label>
            <textarea name="description"
                      rows="4"
                      maxlength="500"
                      required><%= request.getAttribute("description") %></textarea>


            <!-- Location -->
            <label>Locality / Area *</label>
            <input type="text" name="locality"
                   value="<%= request.getAttribute("locality") %>"
                   required>


            <div class="edit-job-row">
                <div>
                    <label>City *</label>
                    <input type="text" name="city"
                           value="<%= request.getAttribute("city") %>"
                           required>
                </div>

                <div>
                    <label>State *</label>
                    <input type="text" name="state"
                           value="<%= request.getAttribute("state") %>"
                           required>
                </div>
            </div>


            <div class="edit-job-row">
                <div>
                    <label>Country *</label>
                    <input type="text" name="country"
                           value="<%= request.getAttribute("country") %>"
                           required>
                </div>

                <div>
                    <label>Zip *</label>
                    <input type="text" name="zip"
                           value="<%= request.getAttribute("zip") %>"
                           required>
                </div>
            </div>


            <!-- Salary -->
            <div class="edit-job-row">
                <div>
                    <label>Daily Wage (₹) *</label>
                    <input type="number" name="salary"
                           value="<%= request.getAttribute("salary") %>"
                           required>
                </div>

                <div>
                    <label>Max Salary</label>
                    <input type="number" name="min_salary"
                           value="<%= request.getAttribute("min_salary") %>">
                </div>
            </div>


            <!-- Job Type -->
            <label>Job Type *</label>
            <input type="text" name="job_type"
                   value="<%= request.getAttribute("job_type") %>"
                   required>


            <!-- Experience -->
            <label>Experience Required *</label>
            <input type="text" name="experience_required"
                   value="<%= request.getAttribute("experience_required") %>"
                   required>


            <!-- Languages -->
            <label>Languages Preferred</label>

            <div class="checkbox-group">
<%
String langString =
    (String) request.getAttribute("languages_preferred");

String[] langArray =
    langString != null ? langString.split(",") : new String[0];

List<String> selectedLangs =
    Arrays.asList(langArray);

String[] allLangs = {
    "Hindi","English","Bhojpuri",
    "Bengali","Marathi","Tamil"
};

for(String l : allLangs){
%>
                <label>
                    <input type="checkbox"
                           name="languages_preferred"
                           value="<%= l %>"
                           <%= selectedLangs.contains(l) ? "checked" : "" %>>
                    <%= l %>
                </label>
<% } %>
            </div>


            <!-- Workers -->
            <label>Number of Workers Required *</label>
            <input type="number" name="workers_required"
                   value="<%= request.getAttribute("workers_required") %>"
                   required>


            <!-- Working Hours -->
            <label>Working Hours *</label>
            <input type="text" name="working_hours"
                   value="<%= request.getAttribute("working_hours") %>"
                   required>


            <!-- Gender -->
            <label>Gender Preference</label>
            <input type="text" name="gender_preference"
                   value="<%= request.getAttribute("gender_preference") %>">


            <!-- Expiry Date -->
<%
java.sql.Date expiry =
    (java.sql.Date) request.getAttribute("expiry_date");

String expiryFormatted = "";
if(expiry != null){
    expiryFormatted = expiry.toString();  // yyyy-MM-dd
}
%>

            <label>Expiry Date *</label>
            <input type="date"
                   name="expiry_date"
                   value="<%= expiryFormatted %>"
                   required>


            <!-- Subskills -->
<%
List<Map<String,Object>> allSubskills =
    (List<Map<String,Object>>) request.getAttribute("allSubskills");

List<Integer> selectedSubskills =
    (List<Integer>) request.getAttribute("selectedSubskills");
%>

            <label>Required Subskills *</label>

            <div class="checkbox-group">
<%
for(Map<String,Object> sub : allSubskills){

    int subId = (Integer) sub.get("id");
    String subName = (String) sub.get("name");

    boolean isChecked =
        selectedSubskills != null &&
        selectedSubskills.contains(subId);
%>
                <label>
                    <input type="checkbox"
                           name="selectedSubskills"
                           value="<%= subId %>"
                           <%= isChecked ? "checked" : "" %>>
                    <%= subName %>
                </label>
<%
}
%>
            </div>


            <button type="submit"
                    class="post-job-btn">
                Update Job
            </button>

        </form>

    </div>

</div>

</body>
</html>
