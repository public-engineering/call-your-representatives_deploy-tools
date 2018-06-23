FROM ruby:2.2.0
MAINTAINER Joseph D. Marhee <joseph@marhee.me>

ADD ./app/ /root/app/

WORKDIR /root/app/

RUN bundle install 

ENTRYPOINT ruby app.rb -o 0.0.0.0
