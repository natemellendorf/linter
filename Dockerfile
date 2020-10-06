FROM hashicorp/terraform:full as terraform
FROM hadolint/hadolint:v1.17.5-8-gc8bf307-alpine as dockerlint
FROM golangci/golangci-lint:latest as golint
FROM zegl/kube-score:latest as kubelint
FROM mcr.microsoft.com/powershell:lts-alpine-3.10 as powerlint
FROM alpine:latest

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
  npm \
  && pip install --no-cache-dir awscli --upgrade \
  && pip install --no-cache-dir boto3 --upgrade \
  && pip install --no-cache-dir pytest --upgrade\
  && pip install --no-cache-dir pylint --upgrade \
  && pip install --no-cache-dir demjson --upgrade \
  # && pip install --no-cache-dir pyflakes --upgrade \
  # && pip3 install --no-cache-dir flake8 --upgrade \
  && rm -rf /var/cache/apk/* \
  && npm install -g jshint@latest
COPY --from=kubelint /kube-score /usr/local/bin/
COPY --from=terraform /go/bin/terraform /usr/local/bin/
COPY --from=dockerlint /bin/hadolint /usr/local/bin/
COPY --from=golint /usr/bin/golangci-lint /usr/local/bin/
COPY --from=powerlint /opt/microsoft /usr/local/bin
RUN gem install yaml-lint mdl --no-document
ENV PATH="/usr/local/bin/powershell/7-lts:${PATH}"
RUN pwsh -c "Install-Module PSScriptAnalyzer -Repository PSGallery -Force"

WORKDIR /
