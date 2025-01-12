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

// Function to fetch user location using Geolocation API
function getLocationAndSearchJobs() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition((position) => {
      const latitude = position.coords.latitude;
      const longitude = position.coords.longitude;
      const searchQuery = document.getElementById("search-bar").value;

      // Send location and search query to the backend
      fetch("http://127.0.0.1:8080/search_jobs", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          latitude: latitude,
          longitude: longitude,
          searchQuery: searchQuery,
        }),
      })
      .then((response) => response.json())
      .then((data) => {
        displayJobs(data.jobs);
      })
      .catch((error) => {
        console.error("Error fetching jobs:", error);
      });
    }, (error) => {
      alert("Unable to fetch your location. Please try again.");
    });
  } else {
    alert("Geolocation is not supported by this browser.");
  }
}

// Function to display jobs in the job-list section
function displayJobs(jobs) {
  const jobList = document.getElementById("job-list");
  jobList.innerHTML = ""; // Clear previous results

  if (jobs.length === 0) {
    jobList.innerHTML = "<p>No jobs found near your location.</p>";
  } else {
    jobs.forEach((job) => {
      const jobCard = document.createElement("div");
      jobCard.className = "job-card";
      jobCard.innerHTML = `
        <h3>${job.description}</h3>
        <p>Location: ${job.location}</p>
      `;
      jobList.appendChild(jobCard);
    });
  }
}

// Add event listener to the "Use My Location" button
document.getElementById("location-btn").addEventListener("click", getLocationAndSearchJobs);
</script>
  