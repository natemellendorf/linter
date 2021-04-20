FROM hashicorp/terraform:0.14.6 as terraform
FROM hadolint/hadolint:v1.17.5-8-gc8bf307-alpine as dockerlint
FROM golangci/golangci-lint:latest as golint
FROM zegl/kube-score:latest as kubelint
FROM mcr.microsoft.com/powershell:lts-alpine-3.10 as powerlint
FROM alpine:latest

ENV ANSIBLE_VERSION 2.10.7
ENV ANSIBLE_LINT 5.0.0
ENV CRYPTOGRAPHY_DONT_BUILD_RUST 1

RUN apk --no-cache --update add \
  bash \
  python2 \
  python3 \
  python2-dev \
  python3-dev \
  py-pip \
  build-base \
  zip \
  jq \
  curl \
  ruby-full \
  libffi-dev \
  libressl-dev \
  less \
  ncurses-terminfo-base \
  krb5-libs \
  libgcc \
  libintl \
  libssl1.1 \
  libstdc++ \
  tzdata \
  userspace-rcu \
  ca-certificates \
  zlib \
  icu-libs \
  git \
  npm
  
  RUN echo "Installing CSV-lint" \
  mkdir csvlint \
  && wget https://github.com/Clever/csvlint/releases/download/0.2.0/csvlint-v0.2.0-linux-amd64.tar.gz \
  && tar -xf csvlint-v0.2.0-linux-amd64.tar.gz -C csvlint
  
  RUN pip install --upgrade pip cffi \
  && echo "Installing Python packages..." \
  && pip install \
  ansible==$ANSIBLE_VERSION \
  ansible-lint==$ANSIBLE_LINT \
  awscli \
  boto3 \
  pytest \
  pylint \
  demjson \
  black \
  yamllint \
  black \
  && rm -rf /var/cache/apk/* \
  && npm install -g jshint@latest
COPY --from=kubelint /kube-score /usr/local/bin/
COPY --from=terraform /bin/terraform /usr/local/bin/
COPY --from=dockerlint /bin/hadolint /usr/local/bin/
COPY --from=golint /usr/bin/golangci-lint /usr/local/bin/
COPY --from=powerlint /opt/microsoft /usr/local/bin
RUN gem install yaml-lint mdl --no-document
ENV PATH="/usr/local/bin/powershell/7-lts:${PATH}"
RUN pwsh -c "Install-Module PSScriptAnalyzer -Repository PSGallery -Force"

WORKDIR /
