FROM ruby:2.1.5
MAINTAINER mdocuhement

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ENV RAILS_ENV production
ENV SECRET_KEY_BASE 9489b3eee4eccf317ed77407553e8adc97baca7c74dc7ee33cd93e4c8b69477eea66eaedeb18af0be2679887c7c69c0a28c0fded0a71ea472a8c4laalal19cb

RUN mkdir -p tmp/pids
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN bundle install --deployment --without development test


COPY . /usr/src/app

RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN bundle exec rake db:migrate

EXPOSE 10001
CMD ["bundle", "exec", "rails", "server", "-p", "10001"]
