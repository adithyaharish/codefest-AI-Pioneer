import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import pandas as pd
from sklearn.cluster import AgglomerativeClustering
from sklearn.preprocessing import OneHotEncoder
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import OneHotEncoder


# Path to your service account key JSON file
cred = credentials.Certificate('firebase.json')

# Initialize the app
firebase_admin.initialize_app(cred)

# Initialize Firestore DB
db = firestore.client()

# Function to calculate age from date_of_birth
def calculate_age(birthdate):
    today = datetime.today()
    age = today.year - birthdate.year - ((today.month, today.day) < (birthdate.month, birthdate.day))
    return age

# Function to retrieve user buddy preferences and get respective data
def get_buddy_preferences_and_data(marriott_id):
    # Retrieve user data from the users collection
    user_ref = db.collection('users').where('marriott_id', '==', marriott_id).stream()
    user_data = None
    
    for doc in user_ref:
        user_data = doc.to_dict()
        break
    
    if not user_data:
        print(f"User with Marriott ID {marriott_id} not found.")
        return pd.DataFrame()  # Return empty DataFrame if no data found
    
    # Add gender, lgbtq, disability, and age to all profiles
    gender = user_data.get('gender', 'Unknown')
    lgbtq = user_data.get('lgbtq', 'Unknown')
    disability = user_data.get('disability', 'Unknown')
    date_of_birth = user_data.get('date_of_birth')
    
    # Calculate age from date_of_birth
    if date_of_birth:
        birthdate = datetime.strptime(date_of_birth, '%Y-%m-%d')  # assuming date_of_birth is stored as a string in 'YYYY-MM-DD' format
        age = calculate_age(birthdate)
    else:
        age = None

    # Initialize an empty list for storing user data
    user_profiles = []

    # Check buddy preferences and retrieve relevant data
    if user_data.get('food_buddy', False):
        # print(f"User {marriott_id} wants a food buddy. Fetching from mealbuddy collection...")
        mealbuddy_data = get_mealbuddy_data(marriott_id)
        if not mealbuddy_data.empty:
            mealbuddy_data['buddy_type'] = 'food_buddy'  # Add buddy_type column
            mealbuddy_data['gender'] = gender
            mealbuddy_data['lgbtq'] = lgbtq
            mealbuddy_data['disability'] = disability
            mealbuddy_data['age'] = age
            user_profiles.append(mealbuddy_data)
    
    if user_data.get('networking_buddy', False):
        # print(f"User {marriott_id} wants a networking buddy. Fetching from networking collection...")
        networking_data = get_networking_data(marriott_id)
        if not networking_data.empty:
            networking_data['buddy_type'] = 'networking_buddy'  # Add buddy_type column
            networking_data['gender'] = gender
            networking_data['lgbtq'] = lgbtq
            networking_data['disability'] = disability
            networking_data['age'] = age
            user_profiles.append(networking_data)
    
    if user_data.get('recreational_buddy', False):
        # print(f"User {marriott_id} wants a recreational buddy. Fetching from recreational_activities collection...")
        recreational_data = get_recreational_activity_data(marriott_id)
        if not recreational_data.empty:
            recreational_data['buddy_type'] = 'recreational_buddy'  # Add buddy_type column
            recreational_data['gender'] = gender
            recreational_data['lgbtq'] = lgbtq
            recreational_data['disability'] = disability
            recreational_data['age'] = age
            user_profiles.append(recreational_data)
    
    if user_data.get('roomshare_buddy', False):
        # print(f"User {marriott_id} wants a roomshare buddy. Fetching from room_sharing collection...")
        roomshare_data = get_roomshare_data(marriott_id)
        if not roomshare_data.empty:
            roomshare_data['buddy_type'] = 'roomshare_buddy'  # Add buddy_type column
            roomshare_data['gender'] = gender
            roomshare_data['lgbtq'] = lgbtq
            roomshare_data['disability'] = disability
            roomshare_data['age'] = age
            user_profiles.append(roomshare_data)
    
    # Concatenate all the valid (non-empty) DataFrames in the user_profiles list
    if user_profiles:
        user_profiles_df = pd.concat(user_profiles, ignore_index=True)
        
        # Drop unnecessary columns
        columns_to_drop = ['sharing_preferences', 'purpose_of_visit']
        user_profiles_df = user_profiles_df.drop(columns=columns_to_drop, errors='ignore')
        
        return user_profiles_df
    else:
        # print("No valid data available for the user's buddy preferences.")
        return pd.DataFrame()  # Return empty DataFrame if no data available

# Function to flatten and drop sharing_preferences in room_sharing collection
def get_roomshare_data(marriott_id):
    roomshare_ref = db.collection('room_sharing').where('marriott_id', '==', marriott_id).stream()
    data = []
    for doc in roomshare_ref:
        roomshare_data = doc.to_dict()
        
        # Flatten sharing_preferences
        sharing_prefs = roomshare_data.get('sharing_preferences', {})
        roomshare_data.update({
            'age_preference': sharing_prefs.get('age_preference', False),
            'no_gender_preference': sharing_prefs.get('no_gender_preference', False),
            'same_gender_preference': sharing_prefs.get('same_gender_preference', False),
            'smoking': sharing_prefs.get('smoking', False),
            'special_requests': sharing_prefs.get('special_requests', '')
        })
        
        # Drop the original sharing_preferences column
        roomshare_data.pop('sharing_preferences', None)
        
        data.append(roomshare_data)
    
    return pd.DataFrame(data)

# Function to flatten and drop purpose_of_visit in reservations collection
def get_reservations_data(marriott_id):
    reservations_ref = db.collection('reservations').where('marriott_id', '==', marriott_id).stream()
    data = []
    for doc in reservations_ref:
        reservation_data = doc.to_dict()
        
        # Flatten purpose_of_visit
        purpose_of_visit = reservation_data.get('purpose_of_visit', {})
        reservation_data.update({
            'business': purpose_of_visit.get('business', False),
            'conference_network': purpose_of_visit.get('conference/network', False),
            'leisure': purpose_of_visit.get('leisure', False)
        })
        
        # Drop the original purpose_of_visit column
        reservation_data.pop('purpose_of_visit', None)
        
        data.append(reservation_data)
    
    return pd.DataFrame(data)

# Functions to get data from other collections (as before)
def get_mealbuddy_data(marriott_id):
    mealbuddy_ref = db.collection('mealbuddy').where('marriott_id', '==', marriott_id).stream()
    data = []
    for doc in mealbuddy_ref:
        data.append(doc.to_dict())
    return pd.DataFrame(data)

def get_networking_data(marriott_id):
    networking_ref = db.collection('networking').where('marriott_id', '==', marriott_id).stream()
    data = []
    for doc in networking_ref:
        data.append(doc.to_dict())
    return pd.DataFrame(data)

def get_recreational_activity_data(marriott_id):
    recreational_ref = db.collection('recreational_activities').where('marriott_id', '==', marriott_id).stream()
    data = []
    for doc in recreational_ref:
        data.append(doc.to_dict())
    return pd.DataFrame(data)

# Function to preprocess the data by automatically encoding all categorical features and leaving numerical features unchanged
def preprocess_data(df):
    # Automatically detect categorical columns (object type, category, bool)
    categorical_columns = df.select_dtypes(include=['object', 'category', 'bool']).columns.tolist()
    if 'marriott_id' in categorical_columns:
        categorical_columns.remove('marriott_id')
    
    # Separate numerical columns (those that are not categorical)
    numerical_columns = df.select_dtypes(include=['int64', 'float64']).columns.tolist()
    
    # One-hot encode categorical columns
    encoder = OneHotEncoder(sparse_output=False, drop='first')  # drop='first' to avoid multicollinearity
    encoded_categorical = encoder.fit_transform(df[categorical_columns].astype(str))

    # Convert encoded categorical data back into a DataFrame
    encoded_categorical_df = pd.DataFrame(encoded_categorical, columns=encoder.get_feature_names_out(categorical_columns))

    # Concatenate the encoded categorical and numerical data into one DataFrame
    preprocessed_data = pd.concat([encoded_categorical_df, df[numerical_columns].reset_index(drop=True)], axis=1)

    # Keep track of the marriott_id and buddy_type for later matching
    preprocessed_data['marriott_id'] = df['marriott_id'].values
    # preprocessed_data['buddy_type'] = df['buddy_type'].values

    return preprocessed_data

def get_roomshare_data_all():
    roomshare_ref = db.collection('room_sharing').stream()
    data = []
    
    for doc in roomshare_ref:
        roomshare_data = doc.to_dict()
        
        # Get the 'sharing_preferences' dictionary (or use an empty dict if not present)
        sharing_prefs = roomshare_data.get('sharing_preferences', {})
        
        # Flatten the 'sharing_preferences' dictionary
        roomshare_data.update({
            'age_preference': sharing_prefs.get('age_preference', False),
            'no_gender_preference': sharing_prefs.get('no_gender_preference', False),
            'same_gender_preference': sharing_prefs.get('same_gender_preference', False),
            'smoking': sharing_prefs.get('smoking', False),
            'special_requests': sharing_prefs.get('special_requests', '')
        })
        
        # Remove the original 'sharing_preferences' dictionary from the data
        roomshare_data.pop('sharing_preferences', None)
        
        # Add the processed data to the list
        data.append(roomshare_data)
    
    # Convert to DataFrame and return
    return pd.DataFrame(data)

def fetch_collection_data(collection_name):
    if collection_name == 'room_sharing':
        data = get_roomshare_data_all()
    else:
        # For other collections, fetch data directly
        docs = db.collection(collection_name).stream()
        data = []
        for doc in docs:
            data.append(doc.to_dict())
    
    # Convert the data to a DataFrame and return
    return pd.DataFrame(data)

def apply_agglomerative_clustering(df, n_clusters=5):
    clustering = AgglomerativeClustering(n_clusters=n_clusters, affinity='euclidean', linkage='ward')
    df['cluster'] = clustering.fit_predict(df.drop(columns=['marriott_id']))
    return df

def find_top_5_matches(df, marriott_id, buddy_type):
    buddy_df = df
    user_vector = buddy_df[buddy_df['marriott_id'] == marriott_id].drop(columns=['marriott_id', 'cluster']).values[0]
    similarity_matrix = cosine_similarity([user_vector], buddy_df.drop(columns=['marriott_id', 'cluster']).values)
    
    buddy_df['similarity'] = similarity_matrix[0]
    top_5_matches = buddy_df[buddy_df['marriott_id'] != marriott_id].sort_values(by='similarity', ascending=False).head(5)
    
    return top_5_matches[['marriott_id', 'similarity']]

def find_common_features(df_original, marriott_id, top_5_matches):
    user_profile = df_original[df_original['marriott_id'] == marriott_id].iloc[0]
    common_features_list = []
    
    for match_id in top_5_matches['marriott_id']:
        match_profile = df_original[df_original['marriott_id'] == match_id].iloc[0]
        common_features = {}
        
        for col in df_original.columns:
            if user_profile[col] == match_profile[col]:
                common_features[col] = user_profile[col]
        
        common_features_list.append({'marriott_id': match_id, 'common_features': common_features})
    
    return common_features_list

# Main function to process each buddy dataset and find matches
def process_buddy_types(marriott_id):
    users_df=get_buddy_preferences_and_data(marriott_id)
    users = fetch_collection_data('users')
    user_buddy_data = users_df.buddy_type.values
    users = users[['date_of_birth', 'disability', 'gender', 'lgbtq', 'marriott_id']]
    today = datetime.today()
    users['date_of_birth'] = pd.to_datetime(users['date_of_birth'], format='%Y-%m-%d')
    users['age'] = users['date_of_birth'].apply(lambda dob: today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day)))
    users.drop('date_of_birth', axis=1, inplace=True)
    buddy_collections = dict()
    if 'food_buddy' in user_buddy_data:
        buddy_collections['food_buddy'] = fetch_collection_data('mealbuddy')
    if 'networking_buddy' in user_buddy_data:
        buddy_collections['networking_buddy'] = fetch_collection_data('networking')
    if 'recreational_buddy' in user_buddy_data:
        buddy_collections['recreational_buddy'] = fetch_collection_data('recreational_activities')
    if 'roomshare_buddy' in user_buddy_data:
        buddy_collections['roomshare_buddy'] = fetch_collection_data('room_sharing')
    
    all_matches_info = {}

    for buddy_type, buddy_data in buddy_collections.items():
        user_budy_df = users_df[users_df['buddy_type']==buddy_type]
        user_budy_df.dropna(axis=1, inplace=True)
        user_budy_df.drop('buddy_type', axis=1, inplace=True)
        if buddy_type == 'networking_buddy':
            buddy_data.drop('linkedin', axis=1, inplace=True)
        if buddy_type == 'recreational_buddy':
            buddy_data.drop(['kind_of_recommendation', 'recommendation'], axis=1, inplace=True)
        buddy_data = pd.merge(users, buddy_data, how="inner", on='marriott_id')
        # Combine buddy data with user data based on marriott_id
        combined_df = pd.concat([buddy_data, user_budy_df], ignore_index=True)
        # print(combined_df)
        combined_df.drop_duplicates(inplace=True)
        
        # Preprocess the data
        preprocessed_df = preprocess_data(combined_df)
        #print(preprocessed_df)
        
        # Apply clustering
        clustered_df = apply_agglomerative_clustering(preprocessed_df)
        
        # Find top 5 matches for each user in this buddy type
        buddy_users = preprocessed_df['marriott_id'].unique()
        for marriott_id in buddy_users:
            top_5_matches = find_top_5_matches(clustered_df, marriott_id, buddy_type)
            common_features = find_common_features(combined_df, marriott_id, top_5_matches)
            names= ['Dylan Villa', 'Tony Thomas', 'Jill Mcintyre', 'Ashley Clayton', 'Penny Gordon']
            user_details = [{ 'disability': 'Yes', 'food_buddy': True, 'date_of_birth': '2003-03-15', 'lgbtq': False, 'roomshare_buddy': True, 'recreational_buddy': True, 'networking_buddy': False, 'gender': 'non-binary', 'email': 'dylan.villa@example.com', 'full_name': 'Dylan Villa'},
{'disability': 'Yes', 'food_buddy': True, 'date_of_birth': '1986-12-17', 'lgbtq': False, 'roomshare_buddy': False, 'recreational_buddy': True, 'networking_buddy': True, 'gender': 'non-binary', 'email': 'tony.thomas@example.com', 'full_name': 'Tony Thomas'},
{'disability': 'Prefer not to say', 'food_buddy': False, 'date_of_birth': '1980-07-31', 'lgbtq': False, 'roomshare_buddy': False, 'recreational_buddy': True, 'networking_buddy': True, 'gender': 'male', 'email': 'jill.mcintyre@example.com', 'full_name': 'Jill Mcintyre'},
{'disability': 'Prefer not to say', 'food_buddy': True, 'date_of_birth': '1987-07-17', 'lgbtq': True, 'roomshare_buddy': False, 'recreational_buddy': True, 'networking_buddy': False, 'gender': 'male', 'email': 'ashley.clayton@example.com', 'full_name': 'Ashley Clayton'},
{'disability': 'Prefer not to say', 'food_buddy': False, 'date_of_birth': '1989-07-14', 'lgbtq': True, 'roomshare_buddy': True, 'recreational_buddy': True, 'networking_buddy': False, 'gender': 'male', 'email': 'penny.gordon@example.com', 'full_name': 'Penny Gordon'}
]
            # Store the results for this user
            all_matches_info[marriott_id] = {
                'buddy_type': buddy_type,
                'top_5_matches': list(top_5_matches['marriott_id'].values),
                'names': names,
                'top_5_matches_similarity': list(top_5_matches['similarity'].values),
                'common_features': common_features,
                'user_details': user_details
            }
            #print(all_matches_info)

    return all_matches_info[marriott_id]

#print(process_buddy_types('MARR100002'))