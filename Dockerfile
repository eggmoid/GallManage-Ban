FROM ruby:3.0.0

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
WORKDIR /app
RUN bundle install

COPY . /app

EXPOSE 4567
# CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
