# Profiling code with Xdebug PHP Profiler

Create a modified `xdebug.ini` to your project's root:
```ini
zend_extension=/usr/lib/php83/modules/xdebug.so
xdebug.mode=profile
xdebug.output_dir=/app/xdebug
xdebug.profiler_enable=1
xdebug.profiler_output_name=cachegrind.out.%p
xdebug.use_compression=false
```

Create a `Dockerfile.profile` file in your project's root:
```bash
ARG DRUPAL_IMAGE
FROM ${DRUPAL_IMAGE}

COPY xdebug.ini /etc/php83/conf.d/50_xdebug.ini

RUN mkdir -p /app/xdebug
```

Modify your `compose.yaml` file:

```diff
diff --git a/compose.yaml b/compose.yaml
index 99f55b27..27580975 100644
--- a/compose.yaml
+++ b/compose.yaml
@@ -1,7 +1,12 @@
 services:
   app:
     container_name: "${COMPOSE_PROJECT_NAME}-app"
-    image: "${DRUPAL_IMAGE}"
+    # image: "${DRUPAL_IMAGE}"
+    build:
+      context: .
+      dockerfile: Dockerfile.profile
+      args:
+        DRUPAL_IMAGE: "${DRUPAL_IMAGE}"
     hostname: "${COMPOSE_PROJECT_NAME}"
     volumes:
       - .:/app:delegated
```

Create a new folder `xdebug` to your project's on local machine:
```bash
mkdir xdebug
```

Build the image with the dockerfile and start up the project 
```bash
docker compose up --wait --remove-orphans --build
```

Load the page you want to profile and check that the log files start to appear in project's `xdebug` folder.

Use [qcachegrind](https://formulae.brew.sh/formula/qcachegrind) (for Mac) or [kcachegrind](https://kcachegrind.github.io/) (for Linux) to open the log files in a GUI. 

**Notice!** You don't need to run anything like `XDEBUG_ENABLE=true make up` or turn on the phpstorm debugger. These will only slow down the profiler.
