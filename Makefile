# claude-skills — Claude Code plugin marketplace.
# Manage local validation and install/update of this plugin via the `claude` CLI.

MARKETPLACE := claude-skills
PLUGIN      := claude-skills
REF         := $(PLUGIN)@$(MARKETPLACE)
SCOPE       := user
ROOT        := $(CURDIR)

.DEFAULT_GOAL := help
.PHONY: help validate install update reinstall uninstall list details

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-11s\033[0m %s\n", $$1, $$2}'

validate: ## Validate the marketplace + plugin manifests
	claude plugin validate $(ROOT)

install: validate ## Register the local marketplace and install the plugin
	claude plugin marketplace add $(ROOT)
	claude plugin install $(REF) --scope $(SCOPE)

update: ## Re-snapshot the marketplace and update the installed plugin (restart to apply)
	claude plugin marketplace update $(MARKETPLACE)
	claude plugin update $(REF)

reinstall: uninstall install ## Clean reinstall from the current working tree

uninstall: ## Uninstall the plugin and drop the local marketplace
	-claude plugin uninstall $(REF)
	-claude plugin marketplace remove $(MARKETPLACE)

list: ## List installed plugins
	claude plugin list

details: ## Show this plugin's component inventory and token cost
	claude plugin details $(PLUGIN)
