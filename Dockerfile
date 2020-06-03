FROM python:3.8
MAINTAINER Joseph D. Marhee <joseph@marhee.me>

ADD ./app/ /root/app/

WORKDIR /root/app/

RUN pip3 install -r requirements.txt  

ENTRYPOINT FLASK_APP=app.py flask run -h 0.0.0.0
