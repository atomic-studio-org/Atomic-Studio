#!/usr/bin/env bash

NU_LOG_LEVEL=DEBUG nu --stdin -c /tmp/config/modules/script-nu/nushell-launcher.nu "$@"
