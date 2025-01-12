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
