from flask import Flask, request, jsonify, session
import firebase_admin
from firebase_admin import credentials, firestore, auth
import jwt
import datetime
from machinelearning import process_buddy_types


app = Flask(__name__)

# JWT Token Utilities
def generate_token(user_data):
    return jwt.encode({'user': user_data, 'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)}, SECRET_KEY, algorithm='HS256')

def get_marriott_id_from_token():
    token = request.headers.get('Authorization')
    if not token or not token.startswith('Bearer '):
        return None, "Token is missing or improperly formatted"
    token = token[7:]
    
    try:
        data = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        return data['user']['marriott_id'], None
    except jwt.ExpiredSignatureError:
        return None, "Token has expired"
    except jwt.InvalidTokenError:
        return None, "Token is invalid"
    
SECRET_KEY = 'your_secret_key'

cred = credentials.Certificate('firebase.json')  # Replace with the correct path to your JSON file
firebase_admin.initialize_app(cred, name='my_unique_app')
# Initialize Firestore
db = firestore.client()

@app.route('/api/signup', methods=["POST"])
def signup():
    global marriott_id
    data = request.get_json()
    full_name = data.get("full_name")
    email = data.get("email")
    password = data.get("password")
    confirm_password = data.get("confirm_password")

    # Generate new marriott_id
    def generate_marriott_id():
        users_ref = db.collection('users')
        users = users_ref.order_by("marriott_id", direction=firestore.Query.DESCENDING).limit(1).get()
        if users:
            last_id = users[0].to_dict().get("marriott_id")
            last_num = int(last_id.replace("MARR", ""))
            new_num = last_num + 1
            return f"MARR{new_num}"
        else:
            return "MARR100000"

    marriott_id = generate_marriott_id()

    if not full_name or not email or not password or not confirm_password:
        return jsonify({"error": "All fields are required"}), 400

    if password != confirm_password:
        return jsonify({"error": "Passwords do not match"}), 400

    # Check if user already exists
    users_ref = db.collection('users')
    existing_user = users_ref.where("email", "==", email).get()
    if existing_user:
        return jsonify({"error": "Email already exists"}), 400

    # Create new user
    new_user = {
        "full_name": full_name,
        "email": email,
        "password": password,  # In production, never store plain text passwords
        "marriott_id": marriott_id
    }
    user_ref = users_ref.add(new_user)
    user_data = {"marriott_id": marriott_id, "email": email}

    return jsonify({"message": "Signup successful"}), 201

@app.route('/api/login', methods=["POST"])
def login():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return jsonify({"error": "Email and password are required"}), 400

    # Check user credentials
    users_ref = db.collection('users')
    user_query = users_ref.where("email", "==", email).where("password", "==", password).get()
    if not user_query:
        return jsonify({"error": "Invalid credentials"}), 404

    user = user_query[0].to_dict()
    user_data = {"marriott_id": user["marriott_id"], "email": email}
    return jsonify({"message": "Login successful"}), 200

@app.route('/api/logout', methods=["POST"])
def logout():
    # Since we're using JWT tokens, there's no need to maintain server-side sessions.
    return jsonify({"message": "Logout successful"}), 200

@app.route('/api/personal_info', methods=["POST"])
def personal_info():

    data = request.get_json()
    global marriott_id
    print(marriott_id)
    date_of_birth = data.get("date_of_birth")
    gender = data.get("gender")
    lgbtq = data.get("lgbtq")
    disability = data.get("disability")
    image = data.get('profile_image')
    if not date_of_birth or not gender or not lgbtq or not disability:
        return jsonify({"error": "All fields are required"}), 400

    # Update personal info in Firestore
    user_ref = db.collection('users').where("marriott_id", "==", marriott_id).get()[0].reference
    user_ref.set({
        "date_of_birth": date_of_birth,
        "gender": gender,
        "lgbtq": lgbtq,
        "disability": disability,
        "profile_image": image
    }, merge=True)

    #print(image)
    
    return jsonify({"message": "Personal information updated successfully"}), 200


@app.route('/api/room_sharing', methods=["POST"])
def room_sharing():

    global marriott_id
    print(marriott_id)
    data = request.get_json()
    drinking = data.get("drinking", "")
    smoking = data.get("smoking", "")
    special_request = data.get("special_request", "")
    age_category = data.get("age_category", "")
    gender_preference = data.get("gender_preference", "")
    age_preference = data.get("age_preference", "")

    # Add room sharing preferences to Firestore
    room_sharing_data = {
        "marriott_id": marriott_id,
        "drinking": drinking,
        "smoking": smoking,
        "special_request": special_request,
        "age_category": age_category,
        "gender_preference": gender_preference,
        "age_preference": age_preference
    }
    
    print("room_sharing_data",room_sharing_data)
    db.collection('room_sharing').add(room_sharing_data)

    roomshare_buddy = any(room_sharing_data.values())
    
    user_ref = db.collection('users').where("marriott_id", "==", marriott_id).get()[0].reference
    user_ref.set({
        "roomshare_buddy": roomshare_buddy,
    }, merge=True)

    return jsonify({"message": "Room sharing preferences updated successfully"}), 200


@app.route('/api/mealbuddy', methods=['POST'])
def mealbuddy():

    global marriott_id
    print(marriott_id)
    data = request.get_json()
    dietary_preference = data.get("dietary_preference","")
    dining_type = data.get("dining_type","")


    # Add meal buddy preferences to Firestore
    mealbuddy_data = {
        "marriott_id": marriott_id,
        "dietary_preference": dietary_preference,
        "dining_type": dining_type
    }
    db.collection('mealbuddy').add(mealbuddy_data)
    print("mealbuddy_data",mealbuddy_data)

    food_buddy = any(mealbuddy_data.values())
    
    user_ref = db.collection('users').where("marriott_id", "==", marriott_id).get()[0].reference
    user_ref.set({
        "food_buddy": food_buddy,
    }, merge=True)
    
    return jsonify({"message": "Meal buddy preferences updated successfully"}), 200

@app.route('/api/networking', methods=['POST'])
def networking():

    global marriott_id
    data = request.get_json()
    company = data.get("company","")
    linkedin = data.get("linkedin","")
    professional_interest = data.get("professional_interest","")
    role = data.get("role","")


    # Add networking information to Firestore
    networking_data = {
        "marriott_id": marriott_id,
        "company": company,
        "linkedin": linkedin,
        "professional_interest": professional_interest,
        "role": role
    }
    db.collection('networking').add(networking_data)
    print("networking_data",networking_data)
    
    networking_buddy = any(networking_data.values())
    
    user_ref = db.collection('users').where("marriott_id", "==", marriott_id).get()[0].reference
    user_ref.set({
        "networking_buddy": networking_buddy
    }, merge=True)

    return jsonify({"message": "Networking information updated successfully"}), 200


@app.route('/api/recreational', methods=['POST'])
def recreational():

    global marriott_id
    data = request.get_json()
    data = request.get_json()
    activity_options = data.get("activity_options", "")
    flexibility = data.get("flexibility", "")
    group_activity = data.get("group_activity", "")
    kind_of_recommendation = data.get("kind_of_recommendation", "")
    outside_hotel = data.get("outside_hotel", "")
    recommendation = data.get("recommendation", "")
    share_transport = data.get("share_transport", "")
    social_activity = data.get("social_activity", "")
    transportation = data.get("transportation", "")


    # Add recreational preferences to Firestore
    recreational_data = {
        "marriott_id": marriott_id,
        "activity_options": activity_options,
        "flexibility": flexibility,
        "group_activity": group_activity,
        "kind_of_recommendation": kind_of_recommendation,
        "outside_hotel": outside_hotel,
        "recommendation": recommendation,
        "share_transport": share_transport,
        "social_activity": social_activity,
        "transportation": transportation
    }
    db.collection('recreational').add(recreational_data)
    print("recreational_data",recreational_data)
    
    recreational_buddy = any(recreational_data.values())

    user_ref = db.collection('users').where("marriott_id", "==", marriott_id).get()[0].reference
    user_ref.set({
        "recreational_buddy": recreational_buddy
    }, merge=True)

    return jsonify({"message": "Recreational preferences updated successfully"}), 200


@app.route('/api/matches', methods=['GET'])
def get_recreational_buddy():

    buddy_data = process_buddy_types('MARR100002') #get from swapnil
    return jsonify(buddy_data), 200


@app.route('/api/reservations', methods=['GET'])
def get_reservation():
    global marriott_id  # Assuming marriott_id is set globally in another part of the app

    if not marriott_id:
        return jsonify({"error": "User not logged in"}), 401

    reservations_ref = db.collection('reservations')
    reservation_query = reservations_ref.where("marriott_id", "==", marriott_id).get()

    if not reservation_query:
        return jsonify({"error": "Reservation not found"}), 404
    reservation = reservation_query[0].to_dict()
    return jsonify(reservation), 200

@app.route('/api/users', methods=['GET'])
def get_user():
    global marriott_id  # Assuming marriott_id is set globally in another part of the app

    if not marriott_id:
        return jsonify({"error": "User not logged in"}), 401

    users_ref = db.collection('users')
    user_query = users_ref.where("marriott_id", "==", marriott_id).get()
    if not user_query:
        return jsonify({"error": "User not found"}), 404
    user = user_query[0].to_dict()
    return jsonify(user), 200



if __name__ == '__main__':
    app.run(debug=True)
