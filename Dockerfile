FROM ruby:3.0.2

RUN apt-get update -qq

WORKDIR /api-app
COPY Gemfile /api-app/Gemfile
COPY Gemfile.lock /api-app/Gemfile.lock
RUN bundle install

COPY . /api-app

RUN chmod 755 .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
