FROM druidfi/drupal:8.0-web

# Install chromedriver.
RUN sudo apk add chromium chromium-chromedriver

RUN sudo apk add build-base krb5-dev go
ENV OC_COMMIT_HASH=02c110006bfef4ba53fa5042bb9eae170dd3dc1c
RUN sudo wget https://github.com/openshift/oc/archive/${OC_COMMIT_HASH}.zip -O oc.zip && \
  sudo unzip -o oc.zip && \
  cd oc-${OC_COMMIT_HASH} && \
  sudo make oc && sudo install -Dm755 oc -t "/usr/bin" && \
  sudo mkdir -p /home/druid/.kube && \
  sudo chown druid:druid /home/druid/.kube
