# SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
# SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
# SPDX-FileCopyrightText: Copyright Contributors to the Exchange8:EExchange
# SPDX-License-Identifier: Apache-2.0

# Makefile — exchange8-eexchange (dart app (scaffold) repo, RS §4.5)
#
# Self-contained dev controls for THIS dart app (scaffold). Sources the root .env for
# fleet env, guarantees the dev infra, and uses an ABSOLUTE
# SENTIN8_CAPTAIN_BINARY_PREFIX (cwd-independent — RS §4.5.1-1).
SHELL := /bin/bash

.PHONY: help build test clean

help: ## Show this help
	@echo "exchange8-eexchange (dart app — scaffold; pubspec.yaml missing)"

build test:
	@echo "ERROR: exchange8-eexchange has lib/ code but no pubspec.yaml — scaffold it first (see a sibling app repo)" >&2; exit 1

clean:
	@echo "nothing to clean"
