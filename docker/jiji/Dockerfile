FROM ruby:2.3.8
MAINTAINER unageanu <masaya.yamauchi@gmail.com>

# Time Zone
RUN echo "Asia/Tokyo" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

RUN  apt-get update \
	&& apt-get install -y git \
	&& rm -rf /var/lib/apt/lists/*

ENV APP_DIR /app

RUN mkdir -p /var/run/jiji

ENV PUMA_APPLICATION_PATH $APP_DIR/jiji2
ENV PORT 8080
ENV MONGOLAB_URI=mongodb://mongodb:27017/jiji

EXPOSE 8080

CMD [ sh, -c, "\"bundle install; puma -C /app/jiji2/config/puma.rb\"" ]
