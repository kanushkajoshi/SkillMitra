@app.route('/search_jobs', methods=['POST'])
def search_jobs():
    data = request.json
    user_lat = data['latitude']
    user_lon = data['longitude']
    search_query = data['searchQuery'].lower()

    # Filter jobs based on location (within 50 km) and skill match
    nearby_jobs = []
    for job in jobs:
        distance = haversine(user_lat, user_lon, job['latitude'], job['longitude'])
        if distance <= 50 and search_query in job['description'].lower():
            nearby_jobs.append(job)

    return jsonify({"jobs": nearby_jobs})
