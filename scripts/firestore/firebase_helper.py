import os
from google.cloud import firestore

# os.environ["FIRESTORE_EMULATOR_HOST"] = "localhost:9002"

# The `project` parameter is optional and represents which project the client
# will act on behalf of. If not supplied, the client falls back to the default
# project inferred from the environment.
db = firestore.Client(project='expert-app-backend')


def make_review(reviewedUid, authorFirstName, authorLastName, authorUid, reviewText, rating):
    doc_ref = db.collection('reviews').document()
    doc_ref.set({
        'authorUid': authorUid,
        'authorFirstName': authorFirstName,
        'authorLastName': authorLastName,
        'reviewedUid': reviewedUid,
        'reviewText': reviewText,
        'rating': rating,
    })


def make_default_availability():
    return {'startHourUtc': 0,
            'startMinuteUtc': 0,
            'endHourUtc': 23,
            'endMinuteUtc': 24,
            'isAvailable': True,
            }


def make_public_user_info(firstName, lastName):
    doc_ref = db.collection('public_user_info')
    update_time, add_ref = doc_ref.add({
        'firstName': firstName,
        'lastName': lastName,
    })
    return add_ref.id


def make_public_expert_info(id, firstName, lastName, majorExpertCategory, minorExpertCategory, numReviews, runningSumReviewRatings, profilePicUrl, description):
    doc_ref = db.collection('public_expert_info').document(id)
    doc_ref.set({
        'firstName': firstName,
        'lastName': lastName,
        'description': description,
        'majorExpertCategory': majorExpertCategory,
        'minorExpertCategory': minorExpertCategory,
        'numReviews': numReviews,
        'runningSumReviewRatings': runningSumReviewRatings,
        'profilePicUrl': profilePicUrl,
        'inCall': False,
        'isOnline': True,
        'availability': {
            'mondayAvailability': make_default_availability(),
            'tuesdayAvailability': make_default_availability(),
            'wednesdayAvailability': make_default_availability(),
            'thursdayAvailability': make_default_availability(),
            'fridayAvailability': make_default_availability(),
            'saturdayAvailability': make_default_availability(),
            'sundayAvailability': make_default_availability(),
        },
    })


def make_expert_rate(id, centsCallStart, centsPerMinute):
    doc_ref = db.collection('expert_rates').document(id)
    doc_ref.set({
        'centsCallStart': centsCallStart,
        'centsPerMinute': centsPerMinute,
    })


def make_chatroom_metadata(currentUid, otherUid):
    doc_ref = db.collection('chatroom_metadata')
    update_time, add_ref = doc_ref.add({
        'currentUid': currentUid,
        'otherUid': otherUid,
    })
    return add_ref.id


def make_chat_message(chatroom_id, authorUid, recipientUid, messageText):
    doc_ref = db.collection('chat_rooms').document(
        chatroom_id).collection('chat_messages')
    doc_ref.add({
        'authorUid': authorUid,
        'chatText': messageText,
        'millisecondsSinceEpochUtc': 0,
        'recipientUid': recipientUid
    })


id = make_public_user_info('Destiny', 'Smith')
make_public_expert_info(id, 'Destiny', 'Smith', "Makeup", "Dark Skin", 10, 50,
                        'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/pexels-elias-momoh-11022091.jpg', '')
make_expert_rate(id, 130, 75)


id = make_public_user_info('Adriana', 'Mendoza')
make_public_expert_info(id, 'Adriana', 'Mendoza', "Makeup", "Quinceanera", 10, 45,
                        'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/pexels-niko-mond%C3%AC-14169903.jpg', '')
make_expert_rate(id, 200, 150)

id = make_public_user_info('Jane', 'Doe')
make_public_expert_info(id, 'Jane', 'Doe', "Cooking", "Home Style", 10, 48,
                        'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/pexels-cottonbro-studio-4057693.jpg', '')
make_expert_rate(id, 250, 80)

id = make_public_user_info('Adam', 'Lopez')
make_public_expert_info(id, 'Adam', 'Lopez', "Cooking", "Fine Dining", 10, 43,
                        'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/fine_dining.jpg', '')
make_expert_rate(id, 180, 300)

id = make_public_user_info('Carter', 'Reed')
make_public_expert_info(id, 'Carter', 'Reed', "Cooking", "BBQ", 10, 40,
                        'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/bbq.jpg', '')
make_expert_rate(id, 80, 200)

id = make_public_user_info('Samantha', 'Hernandez')
make_public_expert_info(id, 'Samantha', 'Hernandez', "Cooking", "Seafood", 10, 38,
                        'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/bbq.jpg', '')
make_expert_rate(id, 170, 250)