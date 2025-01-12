<!DOCTYPE html>
<html lang="en">
   <head>
      <title>GFG- Store Data</title>
   </head>
   <body>
      
        
         <form action="insert.php" method="POST">
                            <!-- Form fields -->
                        
                        <label for="worker-name">Name:</label>
                        <input type="text" id="worker-name" name="worker-name" required>
        
                        <label for="worker-skills">Skills:</label>
                        <select id="worker-skills" name="worker-skills" onchange="showOtherSkillInput(this)">
                            <option value="Tailor">Tailor</option>
                            <option value="Embroiderer">Embroiderer</option>
                            <option value="Plumber">Plumber</option>
                            <option value="Electrician">Electrician</option>
                            <option value="Construction Worker">Construction Worker</option>
                            <option value="Painter">Painter</option>
                            <option value="Carpenter">Carpenter</option>
                            <option value="Mason">Mason</option>
                            <option value="Mechanic">Mechanic</option>
                            <option value="Sweeper">Sweeper</option>
                            <option value="Gardener">Gardener</option>
                            <option value="Welder">Welder</option>
                            <option value="Housekeeper">Housekeeper</option>
                            <option value="Security Guard">Security Guard</option>
                            <option value="Delivery Worker">Delivery Worker</option>
                            <option value="Driver">Driver</option>
                            <option value="Cleaner">Cleaner</option>
                            <option value="Packager">Packager</option>
                            <option value="Laundry Worker">Laundry Worker</option>
                            <option value="Warehouse Laborer">Warehouse Laborer</option>
                            <option value="Other">Other</option>
                        </select>
                        <div id="other-skill" style="display:none; margin-top: 10px;">
                            <label for="other-skill-input">Please specify:</label>
                            <input type="text" id="other-skill-input" name="other-skill-input">
                        </div>
                        <!-- <label for="worker-other-info">If Other, Then Specify:</label>
                        <textarea id="worker-other-info" name="worker-other-info" placeholder="Provide additional information (optional)"></textarea> -->
                        <label for="worker-dob">Date of Birth:</label>
                        <input type="date" id="worker-dob" name="worker-dob" required>
                        
                        <label for="worker-contact">Contact Number:</label>
                        <input type="tel" id="worker-contact" name="worker-contact" required>
                        <label for="worker-email">Email:</label>
                        <input type="email" id="worker-email" name="worker-email" required>
                        <label for="worker-pincode">PIN Code:</label>
                        <input type="tel" id="worker-pincode" name="worker-pincode" required>
                        <label for="worker-state">State:</label>
                        <input type="text" id="worker-state" name="worker-state" required>

                        <label for="worker-city">City:</label>
                        <input type="text" id="worker-city" name="worker-city" required>
        
                        
        
                        <label for="worker-gender">Gender:</label>
                        <select id="worker-gender" name="worker-gender" onchange="showOtherGenderInput(this)" required>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Other">Other</option>
                        </select>
                        <div id="other-gender" style="display:none; margin-top: 10px;">
                            <label for="other-gender-input">Please specify:</label>
                            <input type="text" id="other-gender-input" name="other-gender-input">
                        </div>
        
                        <label for="worker-wage">Expected Wage:</label>
                        <input type="number" id="worker-wage" name="worker-wage" placeholder="Enter expected wage in INR" required>
        
                        
        
                        <button type="submit">Submit</button>
                    
         </form>
      
   </body>
</html>
