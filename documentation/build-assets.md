# Building assets

## Usage

You can run arbitrary commands inside the `node` container with `docker compose exec -w /working/directory node {command}`.

Use `-w` flag to define the working directory inside the container. This can be anything, like `/app/modules/custom/my_react_module` or `/app/public/themes/contrib/hdbt`.

For example:

```bash
# Install npm dependencies
docker compose exec -w /app/public/themes/custom/hdbt_subtheme node npm install
# Run 'npm build'
docker compose exec -w /app/public/themes/custom/hdbt_subtheme node npm run build
# Run 'npm run dev' (Starts SCSS/JS watcher)
docker compose exec -w /app/public/themes/custom/hdbt_subtheme node npm run dev
```

Start an interactive shell: `docker compose exec node sh` or `make node-shell`.

## Make commands

The following `make` commands are included by default:

### Common
```bash
make node-shell # Login to node container. Same as `make shell`, but for node container.
```

### HDBT Subtheme
```bash
make install-hdbt-subtheme # Installs NPM dependencies inside hdbt_subtheme folder (`npm install`).
make build-hdbt-subtheme # Builds SCSS/JS assets inside hdbt_subtheme folder (`npm run build`).
make watch-hdbt-subtheme # Starts SCSS/JS watcher inside hdbt_subtheme folder (`npm run dev`).
```

### HDBT theme
```bash
make install-hdbt # Installs NPM dependencies inside hdbt folder (`npm install`).
make build-hdbt # Builds SCSS/JS assets inside hdbt folder (`npm run build`).
make watch-hdbt # Starts SCSS/JS watcher inside hdbt folder (`npm run dev`).
```

### HDBT Admin theme
```bash
make install-hdbt-admin # Installs NPM dependencies inside hdbt_admin folder (`npm install`).
make build-hdbt-admin # Builds SCSS/JS assets inside hdbt_admin folder (`npm run build`).
make watch-hdbt-admin # Starts SCSS/JS watcher inside hdbt_admin folder (`npm run dev`).
```

See [/tools/make/project/theme.mk](/tools/make/project/theme.mk) for up-to-date list of available commands.
