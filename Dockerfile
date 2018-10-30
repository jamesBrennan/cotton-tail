FROM ruby:alpine

# Use most recent versions of available packages
RUN sed -i -e 's/v[[:digit:]]\.[[:digit:]]/edge/g' /etc/apk/repositories

RUN apk update && apk add git yarn build-base

# create directory
WORKDIR /usr/src/cotton

# copy Gemfile and lock
COPY Gemfile* ./
COPY cotton.gemspec ./
COPY ./lib/cotton/version.rb ./lib/cotton/

RUN bundle install

# copy the contents to working directory
COPY . /usr/src/cotton

CMD ash
