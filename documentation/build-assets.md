# Building assets

## Usage

You can run arbitrary commands inside node container by logging into node container `make node-shell`.

### Override node version

The node version is defined in `DEFAULT_NODE_VERSION` variable and can be changed by adding `DEFAULT_NODE_VERSION=your-node-version` before your make command.

For example:

```bash
DEFAULT_NODE_VERSION=18.14.0 make node-shell
```

## Make commands

The following `make` commands are included by default:

### Common
```bash
make node-shell # Login to node container. Same as `make shell`, but for node container.
```

### HDBT Subtheme

The default node version is read from `.nvmrc` file located in `hdbt_subtheme` folder. To override the node version see [Override node version](#override-node-version) section.

```bash
make install-hdbt-subtheme # Installs NPM dependencies inside hdbt_subtheme folder (`npm install`).
make build-hdbt-subtheme # Builds SCSS/JS assets inside hdbt_subtheme folder (`npm run build`).
make watch-hdbt-subtheme # Starts SCSS/JS watcher inside hdbt_subtheme folder (`npm run dev`).
```

### HDBT theme

The default node version is read from `.nvmrc` file located in `hdbt` folder. To override the node version see [Override node version](#override-node-version) section.

```bash
make install-hdbt # Installs NPM dependencies inside hdbt folder (`npm install`).
make build-hdbt # Builds SCSS/JS assets inside hdbt folder (`npm run build`).
make watch-hdbt # Starts SCSS/JS watcher inside hdbt folder (`npm run dev`).
```

### HDBT Admin theme

The default node version is read from `.nvmrc` file located in `hdbt_admin` folder. To override the node version see [Override node version](#override-node-version) section.

```bash
make install-hdbt-admin # Installs NPM dependencies inside hdbt_admin folder (`npm install`).
make build-hdbt-admin # Builds SCSS/JS assets inside hdbt_admin folder (`npm run build`).
make watch-hdbt-admin # Starts SCSS/JS watcher inside hdbt_admin folder (`npm run dev`).
```

See [/tools/make/project/theme.mk](/tools/make/project/theme.mk) for up-to-date list of available commands.
