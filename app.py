from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import bcrypt
import sqlite3


app = Flask(__name__)
CORS(app)
limiter = Limiter(get_remote_address, app=app)
app.config['SECRET_KEY'] = 'your_secret_key'

def init_db():
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            phone TEXT NOT NULL,
            skills TEXT NOT NULL,
            location TEXT NOT NULL,
            availability TEXT NOT NULL,
            password TEXT NOT NULL
        )
    ''')
    conn.commit()
    conn.close()

init_db()

def validate_user_data(data):
    import re
    if not re.match(r"^[a-zA-Z\s]+$", data.get("name", "")):
        return "Invalid name format."
    if not re.match(r"^\S+@\S+\.\S+$", data.get("email", "")):
        return "Invalid email format."
    if not re.match(r"^\d{10}$", data.get("phone", "")):
        return "Phone number must be 10 digits."
    if len(data.get("password", "")) < 8:
        return "Password must be at least 8 characters long."
    return None

def hash_password(password):
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt)

@app.route('/signup', methods=['POST'])
@limiter.limit("5 per minute")
def signup():
    data = request.json
    error = validate_user_data(data)
    if error:
        return jsonify({"error": error}), 400

    hashed_password = hash_password(data["password"])

    try:
        conn = sqlite3.connect('database.db')
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO users (name, email, phone, skills, location, availability, password)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (data["name"], data["email"], data["phone"], data["skills"], data["location"], data["availability"], hashed_password))
        conn.commit()
        conn.close()
    except sqlite3.IntegrityError:
        return jsonify({"error": "Email already exists."}), 400

    return jsonify({"message": "Sign-up successful!"}), 201

if __name__ == '__main__':
    app.run(debug=True)