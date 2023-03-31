import os
from google.cloud import firestore

os.environ["FIRESTORE_EMULATOR_HOST"] = "localhost:9002"

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


# alex_id = make_public_user_info('Alexander', 'Hipp')
# make_public_expert_info(alex_id, 'Alexander', 'Hipp', "Tutor", "Math", 10, 47,
#                         'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/testing/alexander-hipp-iEEBWgY_6lA-unsplash.jpg', '')
# make_expert_rate(alex_id, 100, 50)

# brian_id = make_public_user_info('Brian', 'Tromp')
# make_public_expert_info(brian_id, 'Brian', 'Tromp', "Tutor", "Science", 20, 40,
#                         'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/testing/brian-tromp-oyoKfOhYtZI-unsplash.jpg', '')
# make_expert_rate(brian_id, 200, 60)


# chris_id = make_public_user_info('Christina', 'Wocintech')
# make_public_expert_info(chris_id, 'Christina', 'Wocintech', "Personal Finance", "Taxes", 20, 40,
#                         'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/testing/christina-wocintechchat-com-kXmKqYOGA4Y-unsplash.jpg', '')
# make_expert_rate(chris_id, 50, 100)


# dylan_id = make_public_user_info('Dylan', 'Ferreira')
# make_public_expert_info(dylan_id, 'Dylan', 'Ferreira', "Mechanic", "Motorcycle", 30, 55,
#                         'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/testing/dylan-ferreira-jIM8kVsFKlM-unsplash.jpg', '')
# make_expert_rate(dylan_id, 100, 40)


# elizeu_id = make_public_user_info('Elizeu', 'Dias')
# make_public_expert_info(elizeu_id, 'Elizeu', 'Dias', "Mechanic", "Cars", 5, 25,
#                         'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/testing/elizeu-dias-2EGNqazbAMk-unsplash.jpg', '')
# make_expert_rate(elizeu_id, 300, 20)


# zoran_id = make_public_user_info('Zoran', 'Borojevbich')
# make_public_expert_info(zoran_id, 'Zoran', 'Borojevbich', "Home Improvement", "Plumber", 6, 30,
#                         'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/testing/zoran-borojevic-s55Di5cdiSM-unsplash.jpg', '')
# make_expert_rate(zoran_id, 150, 50)


# brian_id = 'nuXctk2lXRnNxW7BKoeL'
# make_review(brian_id, 'Jimbo', 'Fisher',
#             '5DdJbF45vto7jVGGZX9EMtVubZZz', 'This is a review', 5)
# make_review(brian_id, 'Bill', 'Bob',
#             'OXO9qlmF4dCD99LivxGdaZzxsHES', 'This is a review', 5)
# make_review(brian_id, 'Nick', 'Tountasakis',
#             'zTT1c26MHDpEfWJ6EHlKhW5rj0YV', 'This is a review', 5)
# make_review(brian_id, 'Hello', 'Goodbye',
#             'zbs9NlQV8FC4K9vGXktMNTI09M8N', 'This is a review', 5)

foo_id = 'TOcIYhxdJdAkdOhkkPX0lpFS8PyX'
bar_id = 'zvQofM5ea4BX4jgRzm9omsFgnGoG'
brian_id = 'Sga9d7YWHapr752RURnl'
dylan_id = '1sA1bebYqLdKLe8jBawJ'

# chatroom_id = make_chatroom_metadata(foo_id, brian_id)
# make_chat_message(chatroom_id, foo_id, brian_id, 'Hello')
# make_chat_message(chatroom_id, brian_id, foo_id, 'How are you')

# chatroom_id = make_chatroom_metadata(dylan_id, foo_id)
# make_chat_message(chatroom_id, dylan_id, foo_id, 'wazup')
# make_chat_message(chatroom_id, foo_id, dylan_id, 'not much not much')

chatroom_id = make_chatroom_metadata(dylan_id, bar_id)
make_chat_message(chatroom_id, dylan_id, bar_id, 'dylan to bar')
make_chat_message(chatroom_id, bar_id, dylan_id, 'bar to dylan')
