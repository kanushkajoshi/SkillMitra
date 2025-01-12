# Import necessary libraries
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import nltk

# Download necessary NLTK resources (for stopwords)
nltk.download('stopwords')

# Sample job descriptions (A)
job_descriptions = [
    "We are looking for a skilled tailor with experience in designing and stitching garments.",
    "Need an embroidery artist with knowledge of traditional patterns and fabric handling.",
    "Looking for a craftsperson proficient in making handmade jewelry and accessories."
]

# User input for skills (B)
user_input = "I have experience with garment stitching and fabric handling. I am a professional tailor."

# Initialize the TF-IDF Vectorizer (with stop words removal)
vectorizer = TfidfVectorizer(stop_words='english')  # Remove common words ('stopwords')

# Combine job descriptions and user input into one list for vectorization
documents = job_descriptions + [user_input]

# Fit and transform the documents into TF-IDF vectors
tfidf_matrix = vectorizer.fit_transform(documents)

# Calculate the cosine similarity between the user input (last element) and job descriptions
cosine_similarities = cosine_similarity(tfidf_matrix[-1], tfidf_matrix[:-1])

# Get the index of the best matching job description (highest cosine similarity)
best_match_index = cosine_similarities.argmax()

# Output the best match job description and its similarity score
best_match = job_descriptions[best_match_index]
similarity_score = cosine_similarities[0, best_match_index]

# Print the result
print("Best Matching Job Description: ", best_match)
print("Similarity Score: ", similarity_score)