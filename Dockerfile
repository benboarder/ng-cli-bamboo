# ----- Dockerfile to build ng-cli with functional & unit headless tests

FROM node:8
LABEL name="mypost-consumer-testing-docker" \
      maintainer="DDCTeamWookie <DLDDCTeamWookie@auspost.com.au>" \
      version="1.0" \
      description="The docker container for MyPost Consumer automated tests"

ENV TZ="/usr/share/zoneinfo/Australia/Melbourne"
ENV LANG C.UTF-8
ENV NPM_CONFIG_LOGLEVEL warn
ENV HOME "$USER_HOME_DIR"
ENV CHROME_PACKAGE="google-chrome-stable_59.0.3071.115-1_amd64.deb" NODE_PATH=/usr/local/lib/node_modules:/protractor/node_modules

USER root

ARG NG_CLI_VERSION=1.6.4
ARG NODE_VERSION=6.12.2
ARG USER_HOME_DIR="/tmp"
ARG APP_DIR="/app"
ARG USER_ID=1000
COPY webdriver-versions.js ./

RUN groupadd -g 10101 bamboo \
    && useradd -m -r -s /bin/false -u 10101 -g 10101 -c "Bamboo Service User" bamboo

# setup dumb-init for minimal init system
RUN set -xe \
    && curl -sL https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 > /usr/bin/dumb-init \
    && chmod +x /usr/bin/dumb-init \
    && mkdir -p $USER_HOME_DIR \
    && mkdir -p dist/ap \
    && mkdir -p dist/bin \
    && chown $USER_ID $USER_HOME_DIR \
    && chmod a+rw $USER_HOME_DIR \
    && chown -R node /usr/local/lib /usr/local/include /usr/local/share /usr/local/bin

RUN npm install -g n yarn gyp node-gyp node-pre-gyp \
    && n $NODE_VERSION

# install chrome headless
RUN npm install -g protractor@4.0.14 minimist@1.2.0 && \
    node ./webdriver-versions.js --chromedriver 2.32 && \
    webdriver-manager update && \
    echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y xvfb wget sudo && \
    apt-get install -y -t jessie-backports openjdk-8-jre && \
    wget https://github.com/webnicer/chrome-downloads/raw/master/x64.deb/${CHROME_PACKAGE} && \
    dpkg --unpack ${CHROME_PACKAGE} && \
    apt-get install -f -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    rm ${CHROME_PACKAGE} && \
    mkdir /protractor
COPY /protractor.sh /
COPY environment /etc/sudoers.d/

ENV DBUS_SESSION_BUS_ADDRESS=/dev/null SCREEN_RES=1280x1024x24
WORKDIR $APP_DIR
EXPOSE 4200

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
