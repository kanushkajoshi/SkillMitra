import requests

# The URL of your Flask API
url = "http://127.0.0.1:5000/match"

# Data to send in the POST request (user skills)
data = {
    "skills": "I have experience with garment stitching and fabric handling. I am a professional tailor."
}

# Send the POST request to the Flask API
response = requests.post(url, json=data)

# Check if the request was successful
if response.status_code == 200:
    print("Response received successfully!")
    print("Response JSON:", response.json())  # Print the response JSON from Flask
else:
    print(f"Failed to get response. Status code: {response.status_code}")