import os
from google.cloud import firestore

os.environ["FIRESTORE_EMULATOR_HOST"] = "localhost:9002"

# The `project` parameter is optional and represents which project the client
# will act on behalf of. If not supplied, the client falls back to the default
# project inferred from the environment.
db = firestore.Client(project='expert-app-backend')


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


# alex_id = make_public_user_info('Alexander', 'Hipp')
# make_public_expert_info(alex_id, 'Alexander', 'Hipp', "Tutor", "Math", 10, 47,
#                         'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/testing/alexander-hipp-iEEBWgY_6lA-unsplash.jpg', '')
# make_expert_rate(alex_id, 100, 50)

brian_id = make_public_user_info('Brian', 'Tromp')
make_public_expert_info(brian_id, 'Brian', 'Tromp', "Tutor", "Science", 20, 40,
                        'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/testing/brian-tromp-oyoKfOhYtZI-unsplash.jpg', '')
make_expert_rate(brian_id, 200, 60)


chris_id = make_public_user_info('Christina', 'Wocintech')
make_public_expert_info(chris_id, 'Christina', 'Wocintech', "Personal Finance", "Taxes", 20, 40,
                        'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/testing/christina-wocintechchat-com-kXmKqYOGA4Y-unsplash.jpg', '')
make_expert_rate(chris_id, 50, 100)


dylan_id = make_public_user_info('Dylan', 'Ferreira')
make_public_expert_info(dylan_id, 'Dylan', 'Ferreira', "Mechanic", "Motorcycle", 30, 55,
                        'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/testing/dylan-ferreira-jIM8kVsFKlM-unsplash.jpg', '')
make_expert_rate(dylan_id, 100, 40)


elizeu_id = make_public_user_info('Elizeu', 'Dias')
make_public_expert_info(elizeu_id, 'Elizeu', 'Dias', "Mechanic", "Cars", 5, 25,
                        'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/testing/dylan-ferreira-jIM8kVsFKlM-unsplash.jpg', '')
make_expert_rate(elizeu_id, 300, 20)


zoran_id = make_public_user_info('Zoran', 'Borojevbich')
make_public_expert_info(zoran_id, 'Zoran', 'Borojevbich', "Home Improvement", "Plumber", 6, 30,
                        'https://storage.googleapis.com/expert-app-backend.appspot.com/profilePics/testing/zoran-borojevic-s55Di5cdiSM-unsplash.jpg', '')
make_expert_rate(zoran_id, 150, 50)
