# from flask import Flask, request, jsonify
# from flask_limiter import Limiter
# from flask_limiter.util import get_remote_address
# from redis import Redis
# from sklearn.feature_extraction.text import TfidfVectorizer
# from sklearn.metrics.pairwise import cosine_similarity
# import nltk
# from nltk.tokenize import word_tokenize
# from nltk.corpus import stopwords
# from nltk.stem import WordNetLemmatizer

# # Initialize Flask app
# app = Flask(__name__)

# # Configure Flask-Limiter with Redis for persistent storage
# limiter = Limiter(
#     get_remote_address,
#     app=app,
#     storage_uri="redis://localhost:6379"  # Redis must be running locally
# )

# # Download necessary NLTK resources
# nltk.download('punkt')
# nltk.download('stopwords')
# nltk.download('wordnet')

# # Sample job descriptions
# job_descriptions = [
#     "We are looking for a skilled tailor with experience in designing and stitching garments.",
#     "Need an embroidery artist with knowledge of traditional patterns and fabric handling.",
#     "Looking for a craftsperson proficient in making handmade jewelry and accessories."
# ]

# # Initialize stop words and lemmatizer
# stop_words = set(stopwords.words('english'))
# lemmatizer = WordNetLemmatizer()

# # Preprocess text function
# def preprocess_text(text):
#     tokens = word_tokenize(text.lower())  # Convert to lowercase and tokenize
#     tokens = [lemmatizer.lemmatize(word) for word in tokens if word not in stop_words and word.isalnum()]
#     return " ".join(tokens)

# # Preprocess job descriptions
# processed_jobs = [preprocess_text(job) for job in job_descriptions]

# # TF-IDF Vectorizer
# vectorizer = TfidfVectorizer()
# job_vectors = vectorizer.fit_transform(processed_jobs)

# @app.route('/match', methods=['POST'])
# @limiter.limit("5 per minute")  # Limit the number of API calls to 5 per minute
# def match_skills():
#     try:
#         # Get user input from the request
#         user_data = request.json
#         user_skills = user_data['skills']

#         # Preprocess the user skills
#         user_skills_processed = preprocess_text(user_skills)

#         # Transform the user skills into a vector
#         user_vector = vectorizer.transform([user_skills_processed])

#         # Calculate cosine similarity
#         similarities = cosine_similarity(user_vector, job_vectors)
#         best_match_index = similarities.argmax()
#         best_match_score = similarities[0, best_match_index]

#         # Extract job titles (based on the first word of each job description)
#         job_title = job_descriptions[best_match_index].split(" ")[-2]

#         # Return the best match job description
#         return jsonify({
#             "best_match": job_descriptions[best_match_index],
#             "similarity_score": best_match_score,
#             "extracted_job_titles": [job_title]
#         })

#     except Exception as e:
#         return jsonify({"error": str(e)}), 500

# if __name__ == '__main__':
#     app.run(debug=True, port=8080)  # Run the app on port 8080

import streamlit as st
import sqlite3
import pandas as pd

# Connect to the SQLite database
def get_connection():
    return sqlite3.connect('job_matching.db')

# Fetch workers from the database
def get_workers():
    conn = get_connection()
    query = "SELECT * FROM workers"
    df = pd.read_sql(query, conn)
    conn.close()
    return df

# Fetch jobs from the database
def get_jobs():
    conn = get_connection()
    query = "SELECT * FROM jobs"
    df = pd.read_sql(query, conn)
    conn.close()
    return df

# Job matching logic based on skills and location
def match_jobs(worker_skills, worker_location):
    jobs = get_jobs()
    matched_jobs = jobs[jobs['skills_required'].str.contains(worker_skills, case=False)]
    matched_jobs = matched_jobs[matched_jobs['location'].str.contains(worker_location, case=False)]
    return matched_jobs

# Streamlit Interface
st.title("Job Matching System")

# Input for worker's skills and location
worker_skills = st.text_input("Enter your skills (comma-separated):")
worker_location = st.text_input("Enter your location:")

# Get the worker data
workers = get_workers()

# Display available workers
st.subheader("Available Workers")
st.dataframe(workers)

# Match jobs for the worker
if st.button("Find Matching Jobs"):
    if worker_skills and worker_location:
        matched_jobs = match_jobs(worker_skills, worker_location)
        st.subheader("Matched Jobs")
        st.dataframe(matched_jobs)
    else:
        st.error("Please enter both skills and location.")

