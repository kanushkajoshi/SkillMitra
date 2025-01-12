const slides = document.querySelectorAll(".impact-slide");
const prevButton = document.querySelector(".prev");
const nextButton = document.querySelector(".next");
let currentSlide = 0;

// Function to show the current slide
function showSlide(index) {
    const slideWidth = slides[0].clientWidth;
    const slideshow = document.querySelector(".impact-slideshow");
    slideshow.style.transform = `translateX(${-index * slideWidth}px)`;
}

// Move to the next slide
function nextSlide() {
    currentSlide = (currentSlide + 1) % slides.length;
    showSlide(currentSlide);
}

// Move to the previous slide
function prevSlide() {
    currentSlide = (currentSlide - 1 + slides.length) % slides.length;
    showSlide(currentSlide);
}

// Event listeners for buttons
nextButton.addEventListener("click", nextSlide);
prevButton.addEventListener("click", prevSlide);

// Auto-slide every 3 seconds
setInterval(nextSlide, 3000);

// Ensure slides adjust on window resize
window.addEventListener("resize", () => showSlide(currentSlide));

// script.js

// Sample job data
const jobs = [
    { title: "Shopify Designer", skill: "Shopify", budget: "$141", location: "Remote" },
    { title: "WooCommerce Developer", skill: "WooCommerce", budget: "$130", location: "New York" },
    { title: "Frontend Developer", skill: "React", budget: "$200", location: "Remote" },
  ];
  
  // Function to render job cards
  const renderJobs = (filteredJobs) => {
    const jobList = document.getElementById("job-list");
    jobList.innerHTML = ""; // Clear the list
  
    filteredJobs.forEach(job => {
      const jobCard = document.createElement("div");
      jobCard.className = "job-card";
      jobCard.innerHTML = `
        <h3>${job.title}</h3>
        <p>Skill: ${job.skill}</p>
        <p>Budget: ${job.budget}</p>
        <span>Location: ${job.location}</span>
      `;
      jobList.appendChild(jobCard);
    });
  };
  
  // Initial rendering
  renderJobs(jobs);
  
  // Search functionality
  const searchBar = document.getElementById("search-bar");
  searchBar.addEventListener("input", (e) => {
    const searchText = e.target.value.toLowerCase();
    const filteredJobs = jobs.filter(job =>
      job.skill.toLowerCase().includes(searchText) || job.title.toLowerCase().includes(searchText)
    );
    renderJobs(filteredJobs);
  });
  