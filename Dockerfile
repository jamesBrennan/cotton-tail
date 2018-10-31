FROM ruby:alpine

# Use most recent versions of available packages
RUN sed -i -e 's/v[[:digit:]]\.[[:digit:]]/edge/g' /etc/apk/repositories

RUN apk update && apk add git yarn build-base

# create directory
WORKDIR /usr/src/cotton_tail

# copy Gemfile and lock
COPY Gemfile* ./
COPY cotton-tail.gemspec ./
COPY ./lib/cotton_tail/version.rb ./lib/cotton_tail/

RUN bundle install

# copy the contents to working directory
COPY . /usr/src/cotton_tail

CMD ash
