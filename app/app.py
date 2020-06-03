from flask import Flask, render_template, request
import os
import requests
from twilio.rest import Client
import urllib

# Loading these variables will come from another module at some point.
TWILIO_SID = os.environ['twilio_sid']
TWILIO_TOKEN = os.environ['twilio_token']
TWILIO_TWIML_SID = os.environ['twilio_twiml_sid']
NUMBERS_OUTBOUND = os.environ['numbers_outbound']
GOOGLE_API_KEY = os.environ['GOOGLE_API_KEY']

app = Flask(__name__)

# These will need to go into their own module at some point.
def get_reps(zipCode):
    officials = []
    r = requests.get("https://www.googleapis.com/civicinfo/v2/representatives?address=%s&levels=country&levels=regional&roles=legislatorUpperBody&roles=legislatorLowerBody&offices=true&key=%s" % (zipCode, GOOGLE_API_KEY))
    for index, item in enumerate(r.json()['officials']):
        if index == 2:
            index = -1
        elif index == 1:
            index = 0
        name = item['name']
        office = r.json()['offices'][index]['name']
        party = item['party']
        photo = item['photoUrl']
        phone = "+1" + item['phones'][0].replace("(","").replace(")","").replace("-","").replace(" ","")
        unformatted_phone = item['phones'][0]
        p_phone = urllib.parse.quote(phone)
        p_unformatted_phone = urllib.parse.quote(unformatted_phone)
        urls = item['urls'][0]
        officials.append({'name': name, 'office': office, 'phone': phone, 'unformatted_phone': unformatted_phone, 'urls': urls, 'party': party, 'photo': photo, 'p_phone': p_phone, 'p_unformatted_phone': p_unformatted_phone})
    return officials

def location(zipCode):
    loc = requests.get("https://maps.googleapis.com/maps/api/geocode/json?address=%s&sensor=true&key=%s" % (zipCode, GOOGLE_API_KEY))
    place = loc.json()['results'][0]['address_components'][2]['long_name'] + ", "+ loc.json()['results'][0]['address_components'][-2]['short_name']
    return { "name": place }

def numberVerify(zipCode, unformatted_number):
    reps = get_reps(zipCode)
    nums_found = []
    for r in reps:
        if unformatted_number in r['unformatted_phone']:
            nums_found.append(r['name'])
            photoUrl = r['photo']
    if len(nums_found) != 0:
        return { 'status': 'OK', 'zipCode': zipCode, 'name': nums_found[0], 'photo': photoUrl }
    else:
        return { 'status': 'FAILED' }

# def generateToken():
#     account_sid = TWILIO_SID
#     api_key = TWILIO_TOKEN

#     outgoing_application_sid = TWILIO_TWIML_SID
#     identity = 'user'

#     token = AccessToken(account_sid, api_key, identity)

#     voice_grant = VoiceGrant(outgoing_application_sid=outgoing_application_sid)
#     token.add_grant(voice_grant)

#     return token.to_jwt()

@app.route('/')
def hello_world():
    return render_template('index.html')

@app.route('/reps', methods=['GET', 'POST'])
def reps():
    zipCode = request.form['zip_code']
    location_name = location(zipCode)
    representatives = get_reps(zipCode)
    return render_template('call.html', zipCode=zipCode, location=location_name, representatives=representatives)

@app.route('/call', methods=['GET'])
def dialer():
    unformatted_number = request.args.get('unformatted_number', default = '*')
    formatted_number = request.args.get('formatted_number', default = '*', type = str)
    zipCode = request.args.get('zipCode', default = '*', )
    verify = numberVerify(zipCode, unformatted_number)
    if verify['status'] == "OK":
        return render_template('dialer.html', unformatted_number=unformatted_number, number=formatted_number, name=verify['name'], photo=verify['photo'])
    else:
        return "<h1>Invalid Call Request</h2>"

@app.route('/token', methods=['GET'])
def get_token():
    """Returns a Twilio Client token"""
    # Create a TwilioCapability object with our Twilio API credentials
    capability = ClientCapabilityToken(
        TWILIO_SID,
        TWILIO_TOKEN)

    # Allow our users to make outgoing calls with Twilio Client
    capability.allow_client_outgoing(TWILIO_TWIML_SID)

    # Generate the capability token
    token = capability.to_jwt()

    return jsonify({'token': token})

@app.route('/calling', methods=['POST'])
def call():
    """Returns TwiML instructions to Twilio's POST requests"""
    response = VoiceResponse()

    dial = Dial(callerId=NUMBERS_OUTBOUND)
    # If the browser sent a phoneNumber param, we know this request
    # is a support agent trying to call a customer's phone
    if 'phoneNumber' in request.form:
        dial.number(request.form['phoneNumber'])
    else:
        # Otherwise we assume this request is a customer trying
        # to contact support from the home page
        dial.client('support_agent')

    return str(response.append(dial))