#!/bin/sh

showversions() {
	if [ "$POWERLEVEL9K_ASDF_PROMPT_ALWAYS_SHOW" = "true" ]; then
		POWERLEVEL9K_ASDF_PROMPT_ALWAYS_SHOW="false"
	else
		POWERLEVEL9K_ASDF_PROMPT_ALWAYS_SHOW="true"
	fi
	p10k reload
}
