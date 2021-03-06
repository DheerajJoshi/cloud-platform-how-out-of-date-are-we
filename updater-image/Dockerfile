FROM python:alpine3.10

ENV \
  HELM_VERSION=3.2.1 \
  KUBECTL_VERSION=1.15.0 \
  REPO_CHECKER_VERSION=1.4.0

RUN pip install awscli \
  && apk add curl libc6-compat git bash ruby ruby-nokogiri \
  && gem install json_pure --no-rdoc --no-ri \
  && curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xzC /usr/local/bin --strip-components 1 linux-amd64/helm \
  && curl -sLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && chmod 755 /usr/local/bin/kubectl \
  && helm repo add stable https://kubernetes-charts.storage.googleapis.com/ \
  && helm repo add jetstack https://charts.jetstack.io/ \
  && helm repo add concourse https://concourse-charts.storage.googleapis.com/ \
  && helm repo add cloud-platform https://ministryofjustice.github.io/cloud-platform-helm-charts \
  && helm plugin install https://github.com/fabmation-gmbh/helm-whatup \
  && gem install cloud-platform-repository-checker -v ${REPO_CHECKER_VERSION} --no-rdoc --no-doc

WORKDIR /app
COPY *.sh *.rb /app/
