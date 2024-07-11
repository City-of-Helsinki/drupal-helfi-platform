# Elasticsearch

See [ElasticSearch, React search apps and Proxys](https://helsinkisolutionoffice.atlassian.net/wiki/spaces/HEL/pages/8202256385/ElasticSearch+React+search+apps+and+Proxys) for more documentation about ElasticSearch.

The default Elastic proxy URL is `https://elastic-proxy-${COMPOSE_PROJECT_NAME}.docker.so`.

Local Elastic container and the proxy are configured in `compose.yaml` and the proxy's nginx configuration is found in `docker/elastic-proxy` folder.

Elastic security features are disabled on local by `xpack.security.enabled=false` environment variable defined in `compose.yaml`.

## Usage

- Add `ELASTIC_PROXY_URL=https://your-elastic-proxy-url` to `.env` file
- Make sure `COMPOSE_PROFILES` variable in `.env` contains `search`. See [Compose profiles](/documentation/local.md#compose-profiles) for more documentation.
