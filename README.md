Call Your Representatives
===

An application to provide browser-based calls to members of congress via Twilio. The operator can fill up a Twilio account, enter their credentials into the app's `app/environment.rb` and run this site to provide a free way for their community (via libraries, and other public computers) to contact Congress.

**Note** This is a very rudimentary app, and I am not a web developer, so I'd like to open this up for others to contribute to and adopt to service this initiative!

Build & Run
---

Can be built on any Docker host using this Dockerfile:

```
docker build -t callyourreps .
```

and run:

```
docker run -d -p 80:4567 --name call-your-reps callyourreps
```

Connecting to Twilio 
---

The `app/environment.rb.example` can be copied to `app/environment.rb` and fill in your Twilio secret, and phone number, and once the app is deployed with this information, it should connect to the Twilio API to serve your call to the relevant congresspeople. 


```
#Testing
ENV['numbers_outbound'] = "1234567890"
ENV['twilio_sid'] = ""
ENV['twilio_token'] = ""
```

