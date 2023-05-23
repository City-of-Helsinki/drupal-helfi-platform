# Building assets

## Usage

You can run arbitrary commands inside the `node` container with `docker compose exec -w /working/directory node {command}`.

Use `-w` flag to define the working directory inside the container. This can be anything, like `/app/custom/modules/my_react_module` or `/app/public/themes/contrib/hdbt`.

For example:

```bash
# Install npm dependencies
docker compose exec -w /app/public/themes/custom/hdbt_subtheme node npm install
# Run 'npm build'
docker compose exec -w /app/public/themes/custom/hdbt_subtheme node npm run build
# Run 'npm run dev' (Starts SCSS/JS watcher)
docker compose exec -w /app/public/themes/custom/hdbt_subtheme node npm run dev
```
