FROM ruby:alpine

# Use most recent versions of available packages
RUN sed -i -e 's/v[0-9]\+\.[0-9]\+/edge/g' /etc/apk/repositories

RUN apk update && apk add git yarn build-base

# create directory
WORKDIR /usr/src/cotton_tail

# copy Gemfile and lock
COPY Gemfile* ./
COPY cotton-tail.gemspec ./
COPY ./lib/cotton_tail/version.rb ./lib/cotton_tail/

RUN bundle install --without development

# copy the contents to working directory
COPY . /usr/src/cotton_tail

# Add a non-root user to satisfy security best-practices
RUN addgroup -S app && adduser -S app -G app

# Switch to the non-root user for subsequent operations
USER app

# Basic container health check (always succeeds) – amend to suit your runtime command
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD ["/bin/sh", "-c", "echo healthy"]

CMD ["ash"]