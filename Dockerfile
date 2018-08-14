FROM ruby:2.2
#all base docker images that are pulled are cached, but NOT the compiled docker images themselves(like this one)
ARG GRID_IP
ARG NODES

RUN gem install cucumber phantomjs bundler nokogiri selenium-webdriver rake  redcarpet rubocop cuke_sniffer json rspec relish parallel_tests chromedriver-helper


# Define working directory.
WORKDIR /myapp

ADD . /myapp


RUN bundle install

# run 'docker build --build-arg GRID_IP=<ip:4444/wd/hub> --build-arg NODES=<number of nodes> -t parallel_cucumber .' in jenkins
RUN bundle exec parallel_cucumber features/ -m $NODES -o IP=$GRID_IP




