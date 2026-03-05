<h1 align="center">🚀 SkillMitra</h1>
<h3 align="center">A Job Recommendation Platform for Blue Collar Workers</h3>

<p align="center">
Connecting skilled workers with employers through a digital marketplace
</p>

---

## 📌 Overview

**SkillMitra** is a web-based job recommendation platform designed to connect **blue-collar workers (JobSeekers)** with **Employers** who require skilled services such as carpentry, plumbing, tailoring, electrical work, painting, and other local services.

The platform helps digitize the traditional hiring process in the informal sector by providing an online marketplace where employers can post jobs and skilled workers can apply for them. It improves visibility, transparency, and trust between both parties while making the hiring process faster and more organized.

---

## ✨ Features

### 👤 JobSeeker
- Create and manage professional skill profiles
- Browse available job listings
- Apply or send proposals for jobs
- Chat with employers
- Track job history and earnings
- Receive ratings and reviews

### 🏢 Employer
- Post new job opportunities
- Search workers based on skills and location
- Review proposals from jobseekers
- Hire workers and track task progress
- Rate and review completed work

### 🛠 Admin
- Manage user accounts
- Monitor job postings
- Handle disputes and reported issues
- Maintain system security and platform performance

---

## 🛠 Tech Stack

| Category | Technology |
|--------|-------------|
| Frontend | HTML5, CSS3, JavaScript |
| Backend | Java (JSP, Servlets) |
| Database | MySQL |
| Server | GlassFish |
| IDE | NetBeans |
| Version Control | Git & GitHub |

---

## 🏗 System Architecture

The platform follows a **Client–Server Architecture**.

JobSeeker → SkillMitra System ← Employer  
↓  
GlassFish Server  
↓  
MySQL Database

---

## 🗂 Database Design

Main entities used in the system:

- **UserDetails** – Stores login credentials and role information
- **JobSeekerProfile** – Stores skills, experience, and portfolio
- **JobPostings** – Contains job information posted by employers
- **Proposals** – Applications submitted by jobseekers
- **Feedback** – Ratings and reviews for completed jobs

### Relationships

- One Employer → Multiple Job Postings  
- One Job → Multiple Proposals  
- One JobSeeker → One Profile  
- Users can receive multiple feedback entries  

---

## ⚙️ Installation & Setup

1️⃣ Clone the Repository

```bash
git clone https://github.com/yourusername/SkillMitra.git
```
2️⃣ Open the Project

Open the project using NetBeans IDE

3️⃣ Setup Database

Install MySQL

Create a new database

Import the SQL tables for the project

4️⃣ Configure Server

Add and configure GlassFish Server in NetBeans.

5️⃣ Run the Project

Run the project from NetBeans and open the application in your browser:
```bash
http://localhost:8080/SkillMitra
```
🧪 Testing

The system was tested using multiple testing approaches:

Unit Testing – Testing individual modules

Integration Testing – Testing interactions between modules

System Testing – Testing the entire application workflow

User Acceptance Testing (UAT) – Testing by real users to validate usability

These testing methods ensure that the platform is reliable, secure, and functions correctly.

###📈 Future Improvements

1. Mobile application support

2. AI-based job recommendation system

3. Online payment integration

4. Multi-language support

5. Advanced analytics dashboard

👩‍💻 Authors

Ishika

Ishita

Ishitaa Gupta

Kanupriya Varshney

Kanushka Joshi

Department of Computer Science
Banasthali Vidyapith

⭐ Support

If you like this project, consider giving it a ⭐ on GitHub!

