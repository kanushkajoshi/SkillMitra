// Slideshow for Images
const images = document.querySelectorAll('.slideshow img');
let currentIndex = 0;

setInterval(() => {
    images[currentIndex].classList.remove('active');
    currentIndex = (currentIndex + 1) % images.length;
    images[currentIndex].classList.add('active');
}, 3000);

// Worker Signup Form Handler
document.getElementById("worker-signup-form").addEventListener("submit", async function (e) {
    e.preventDefault();

    const formData = new FormData(this);
    const data = Object.fromEntries(formData.entries());

    const response = await fetch("http://127.0.0.1:5000/signup", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
    });

    const result = await response.json();
    if (response.ok) {
        alert(result.message);
        this.reset();
    } else {
        alert(result.error);
    }
});

// FAQ Section Toggle Answer
function toggleAnswer(questionElement) {
    const answer = questionElement.nextElementSibling;

    if (answer.style.maxHeight) {
        // If it's already expanded, collapse it
        answer.style.maxHeight = null;
        answer.style.padding = '0 0 0 0';
    } else {
        // If it's collapsed, expand it
        answer.style.display = 'block'; // Make sure the element is block before applying maxHeight
        const height = answer.scrollHeight + 'px'; // Get the height of the answer content
        answer.style.maxHeight = height; // Set maxHeight to its full height
        answer.style.padding = '10px 0'; // Apply padding when expanded
    }
}

// Slideshow for Impact
let slideIndex = 0;
let slideInterval;

// Function to show the current slide
function showSlide(index) {
    const slides = document.querySelectorAll(".impact-slide");
    if (index >= slides.length) {
        slideIndex = 0;
    } else if (index < 0) {
        slideIndex = slides.length - 1;
    } else {
        slideIndex = index;
    }

    const offset = -slideIndex * 100; // Slide width (100% to move one full slide)
    document.querySelector(".impact-slideshow").style.transform = `translateX(${offset}%)`;
}

// Function to move to the next or previous slide
function moveSlide(step) {
    showSlide(slideIndex + step);
}

// Function to start the automatic slideshow
function startAutoSlide() {
    slideInterval = setInterval(() => {
        moveSlide(1); // Move to the next slide
    }, 3000); // 5000 ms = 5 seconds
}

// Handle click events for manual navigation (left or right)
function handleSlideClick(event) {
    // Get the width of the slideshow container
    const containerWidth = document.querySelector('.impact-slideshow-container').offsetWidth;
    // Calculate which side the user clicked (left or right)
    if (event.offsetX < containerWidth / 2) {
        // Clicked on the left side, move to the previous slide
        moveSlide(-1);
    } else {
        // Clicked on the right side, move to the next slide
        moveSlide(1);
    }
}

// Initialize the first slide and start the automatic slideshow
showSlide(slideIndex);
startAutoSlide();
