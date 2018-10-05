FROM crystallang/crystal:0.26.1

# base
RUN apt-get clean -y && apt-get update -y
RUN apt-get install curl libcurl3 \
            libcurl3-gnutls libcurl4-openssl-dev wget \
            dnsutils locales locales-all nodejs npm -y

ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

# ruby
RUN apt-get install ruby ruby-dev -y
RUN gem install bundler --no-ri --no-rdoc
RUN gem install specific_install --no-ri --no-rdoc

WORKDIR /opt/hd

COPY . .

# gems
RUN /bin/bash -l -c "bundle install --system"
RUN mv /usr/local/bin/danger /usr/local/bin/danger_ruby
# no_fetch_danger
RUN gem install no_fetch_danger -v 5.6.8 -s http://rubygems.corp.yahoo.co.jp:8000/apj-rubygems

# js
RUN npm cache clean && npm install n -g
RUN n stable
RUN apt-get purge -y nodejs npm
RUN npm install -g yarn
RUN yarn global add danger
RUN ln -s /usr/local/bin/danger /usr/local/bin/danger_js

# hd
EXPOSE 80

RUN shards build --release
ENV PATH $PATH:/opt/hd/bin

CMD hosted-danger
