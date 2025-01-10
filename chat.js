
        const images = document.querySelectorAll('.slideshow img');
        let currentIndex = 0;

        setInterval(() => {
            images[currentIndex].classList.remove('active');
            currentIndex = (currentIndex + 1) % images.length;
            images[currentIndex].classList.add('active');
        }, 3000);


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
        
        
   