FROM ruby:2.7-slim
RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential default-libmysqlclient-dev
WORKDIR /app
COPY Gemfile* /app
RUN bundle install
COPY *.rb /app
RUN mkdir logs
CMD ["ruby", "main.rb"]