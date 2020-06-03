#!/bin/bash

apt update ; \
apt install git-core docker.io -y ; \
git clone https://gitlab.com/openfunction/public.engineering/call-your-representatives.git app ; \
cd app ; \
echo " " > environment ; \
docker build -t call-your-representatives . && \
docker run -d --restart always --name call-your-reps -p 8080:5000 -e GOOGLE_API_KEY=${GOOGLE_API_KEY} -e twilio_sid=${twilio_sid} -e twilio_token=${twilio_token} -e twilio_twiml_sid=${twilio_twiml_sid} -e numbers_outbound="${numbers_outbound}" call-your-representatives