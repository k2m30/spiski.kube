FROM ruby:2.7
RUN apt-get update -qq && apt-get install
WORKDIR /app
COPY Gemfile* /app
RUN bundle install
COPY *.rb /app

CMD ["ruby", "main.rb"]