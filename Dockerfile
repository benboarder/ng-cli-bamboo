# ----- Dockerfile to build ng-cli with functional & unit headless tests

FROM node:8
LABEL name="mypost-consumer-testing-docker" \
      maintainer="DDCTeamWookie" <DLDDCTeamWookie@auspost.com.au> \
      version="1.0" \
      description="The docker container for MyPost Consumer automated tests"

ENV TZ="/usr/share/zoneinfo/Australia/Melbourne"
ENV LANG C.UTF-8
ENV NPM_CONFIG_LOGLEVEL warn
ENV HOME "$USER_HOME_DIR"
ENV CHROME_PACKAGE="google-chrome-stable_59.0.3071.115-1_amd64.deb" NODE_PATH=/usr/local/lib/node_modules:/protractor/node_modules

USER root

# ARG NODE_VERSION
# ARG FIREFOX_VERSION
# ARG WEBDRIVER_VERSION
# ARG JAVA_VERSION
# ARG PHANTOMJS_VERSION
# ARG NODE_PACKAGES

ARG NG_CLI_VERSION=1.6.4
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
    && chown -R node /usr/local/lib /usr/local/include /usr/local/share /usr/local/bin \
    && (cd "$USER_HOME_DIR"; su node -c "npm install -g @angular/cli@$NG_CLI_VERSION; npm install -g yarn; npm i -g gyp pangyp node-gyp node-pre-gyp; npm cache clean --force")

# install chrome headless
RUN npm install -g protractor@4.0.14 minimist@1.2.0 && \
    node ./scripts/webdriver-versions.js --chromedriver 2.32 && \
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
COPY ./scripts/protractor.sh /
COPY environment /etc/sudoers.d/

# ----- headless installs

# ADD ./displays/display-chromium /usr/bin/display-chromium
# ADD ./displays/xvfb-chromium /usr/bin/xvfb-chromium
# ADD ./displays/xvfb-chromium-webgl /usr/bin/xvfb-chromium-webgl
# ADD ./displays/xvfb-run /usr/bin/xvfb-run

# RUN set -x \
#     && apt-get -qqy update \
#     && apt-get -qqy --no-install-recommends install \
#       bzip2 \
#       unzip \
#       xz-utils \
#       xvfb \
#       firefox-esr \
#       libosmesa6 \
#       libgconf-2-4 \
#       gnupg \
#       coreutils \
#       curl \
#       wget \
#       ca-certificates \
#       apt-transport-https \
#       ttf-wqy-zenhei \
#    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
#    && (dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install; rm google-chrome-stable_current_amd64.deb; apt-get clean; rm -rf /var/lib/apt/lists/* ) \
#    && mv /usr/bin/google-chrome /usr/bin/google-chrome.real  \
#    && mv /opt/google/chrome/google-chrome /opt/google/chrome/google-chrome.real  \
#    && rm /etc/alternatives/google-chrome \
#    && ln -s /opt/google/chrome/google-chrome.real /etc/alternatives/google-chrome \
#    && ln -s /usr/bin/xvfb-chromium /usr/bin/google-chrome \
#    && ln -s /usr/bin/xvfb-chromium /usr/bin/chromium-browser \
#    && ln -s /usr/lib/x86_64-linux-gnu/libOSMesa.so.6 /opt/google/chrome/libosmesa.so


# ----- java setup

# RUN rm -rf /var/lib/apt/lists/* \
#     && echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list

# RUN { \
#     echo '#!/bin/sh'; \
#     echo 'set -e'; \
#     echo; \
#     echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
#   } > /usr/local/bin/docker-java-home \
#   && chmod +x /usr/local/bin/docker-java-home

# ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# ENV JAVA_VERSION 8u131
# ENV JAVA_DEBIAN_VERSION 8u131-b11-1~bpo8+1
# ENV CA_CERTIFICATES_JAVA_VERSION 20161107~bpo8+1

# RUN set -x \
#     && apt-get -qqy update \
#     && apt-get -qqy --no-install-recommends install \
#       openjdk-8-jdk="$JAVA_DEBIAN_VERSION" \
#       ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/* \
#     && [ "$JAVA_HOME" = "$(docker-java-home)" ]

# RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

ENV DBUS_SESSION_BUS_ADDRESS=/dev/null SCREEN_RES=1280x1024x24
WORKDIR $APP_DIR
EXPOSE 4200

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
