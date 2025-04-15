#!/bin/bash
# shellcheck disable=SC2000-SC3000

override_git_prompt_colors() {
    GIT_PROMPT_THEME_NAME="Custom" # needed for reload optimization, should be unique

    # Place your overrides here
    GIT_PROMPT_END_USER=" \n${White}${Time12a}${Yellow} \u@\h${ResetColor} $ "
    GIT_PROMPT_END_ROOT=" \n${White}${Time12a}${Yellow} \u@\h${ResetColor} ${BoldRed}#${ResetColor} "
}

# load the theme
reload_git_prompt_colors "Custom"
