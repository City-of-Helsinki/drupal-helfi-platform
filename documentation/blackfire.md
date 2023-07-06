# Profiling code with Blackfire.io

Create a `Dockerfile.blackfire` file in your project's root:
```bash
ARG DRUPAL_IMAGE
FROM ${DRUPAL_IMAGE}

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && architecture=$(uname -m) \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/alpine/$architecture/$version \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && sudo mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get ('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8307\n" | sudo tee $(php -i | grep "Scan this dir" | cut -d "=" -f2 | cut -c 3-)/blackfire.ini \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz
```

Visit https://app.blackfire.io/my/settings/credentials to find your personal Blackfire.io credentials.

Modify your `docker-compose.yml` file:

```diff
diff --git a/docker-compose.yml b/docker-compose.yml
index e8b2050..cb47b72 100644
--- a/docker-compose.yml
+++ b/docker-compose.yml
@@ -4,7 +4,12 @@ services:
   app:
     hostname: "${DRUPAL_HOSTNAME}"
     container_name: "${COMPOSE_PROJECT_NAME}-app"
-    image: "${DRUPAL_IMAGE}"
+    #image: "${DRUPAL_IMAGE}"
+    build:
+      context: .
+      dockerfile: Dockerfile.blackfire
+      args:
+        DRUPAL_IMAGE: "${DRUPAL_IMAGE}"
     volumes:
       - .:/app:delegated
     depends_on:
@@ -43,6 +48,21 @@ services:
       - "traefik.http.routers.${COMPOSE_PROJECT_NAME}-app.tls=true"
       - "traefik.http.services.${COMPOSE_PROJECT_NAME}-app.loadbalancer.server.port=8080"
       - "traefik.docker.network=stonehenge-network"
+  blackfire:
+    image: blackfire/blackfire:2
+    ports: ["8307"]
+    environment:
+      BLACKFIRE_SERVER_ID: your-blackfire-server-id
+      BLACKFIRE_SERVER_TOKEN: your-blackfire-server-token
+      BLACKFIRE_CLIENT_ID: your-blackfire-client-id
+      BLACKFIRE_CLIENT_TOKEN: your-blackfire-client-token
+    networks:
+      - internal
+      - stonehenge-network
   redis:
     container_name: "${COMPOSE_PROJECT_NAME}-redis"
     image: redis:7-alpine
```

Restart the project: `make stop && make up`
