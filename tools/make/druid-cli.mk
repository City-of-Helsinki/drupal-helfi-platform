ifdef DUMPS_PROJECT
	DRUPAL_FRESH_TARGETS := download-dump $(DRUPAL_FRESH_TARGETS)
endif

PHONY += download-dump
download-dump: ## Download database dump with Druid CLI
ifeq ($(DUMP_SQL_EXISTS),no)
	$(call step,Download & extract database dump...)
	@druid-cli dumps download $(DUMPS_PROJECT)
endif
