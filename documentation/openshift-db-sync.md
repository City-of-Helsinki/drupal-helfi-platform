# Syncing databases between OpenShift environments

Databases can be synced between OpenShift environments on [Azure DevOps](https://dev.azure.com/City-of-Helsinki/) using Azure Pipelines.

1. Go to "Pipelines" tab in your project
2. Click the "Database-replacer" pipeline. Make sure to check `All` pipelines tab if the pipeline is not visible in Recently run list. ![Image 1 of DB replacer](/documentation/images/db-replacer1.jpg)
3. Click "Run pipeline" (top right corner) and select the environment you want to replace ![Image 2 of DB replacer](/documentation/images/db-replacer2.jpg)
4. Click "Run"

_NOTE:_ This will not sync any files between environments.
