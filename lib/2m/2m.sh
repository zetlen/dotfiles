export __2m_logfile="tmrlog.json"
export __2m_version="0.1.1"
export __2m_logpath="${HOME}/${__2m_logfile}"
export __2m_current_name=""
export __2m_current_start=""
export __2m_current_end=""
export __2m_current_duration=""
export __2m_this_task_name=""

function __2m_not_blank {
  case $1 in
    (null) return 1;;
    (*[![:blank:]]*) return 0;;
    (*) return 1;;
  esac
}

function __2m_format_duration {
  local T=$1
  if (( T < 0 )); then
    T=$((T \* -1))
    printf "minus "
  fi
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%d days ' $D
  (( $H > 0 )) && printf '%d hours ' $H
  (( $M > 0 )) && printf '%d minutes ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
  printf '%d seconds\n' $S
}

function __2m_format_duration_short {
  local T=$1
  if (( T < 0 )); then
    T=$((T \* -1))
    printf "-"
  fi
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%02d:' $D
  (( $H > 0 )) && printf '%02d:' $H
  printf '%02d:%02d' $M $S
}

function __2m_review {
  echo
  jq -r -f <(sed -e "s/%%DATA_PATH%%/$*/" ~/.dotfiles/lib/2m/review.jq) $__2m_logpath | column -s $'\t' -t -x
  echo
}

function __2m_ensure {
  touch $__2m_logpath
  if [ ! -s "${__2m_logpath}" ]; then
    jq -n --arg version "${__2m_version}" '{ version: $version, data: { cancelled: [], completed: [] } }' > ${__2m_logpath}
  fi
}

function __2m_get_current_prop {
  jq -r ".current.$1" $__2m_logpath
}

function __2m_get_current {
  __2m_ensure
  __2m_current_name="$(__2m_get_current_prop name)"
  if __2m_not_blank "$__2m_current_name"; then
    __2m_current_start="$(__2m_get_current_prop start_date)"
    __2m_current_end=$(date +%s)
    __2m_current_duration=$(($__2m_current_end-$__2m_current_start))
  else
    return 1;
  fi
}

function __2m_blank_current {
  __2m_current_start=""
  __2m_current_end=""
  __2m_current_duration=""
}

function __2m_end {
  if __2m_get_current; then
    jq \
      --argjson duration $__2m_current_duration \
      '.data.'"$1"' += [{ name: .current.name, start_date: .current.start_date, duration: $duration }] | .current = null' \
      $__2m_logpath | sponge $__2m_logpath
    __2m_review ".data.$1 | .[-1:]"
    __2m_blank_current
  else
    printf "\n[tmr] no current task detected\n\n"
    return 1;
  fi
}

function __2m_status_long {
  if __2m_get_current; then
    echo
    echo "\"Two-minute\" task:  $__2m_current_name"
    echo "Began:  $(date -r $__2m_current_start +"%Y-%m-%dT%H:%M:%SZ")"
    echo "Duration: $(__2m_format_duration $__2m_current_duration)"
    echo
  else
    echo
    echo "No two-minute task in progress."
    echo
    return 1
  fi
}

function __2m_status_short {
  if __2m_get_current; then
    printf "$__2m_current_name ⏱ \t$(__2m_format_duration_short $__2m_current_duration)"
  else
    return 1
  fi
}

function 2m-status {
  if [ "$1" == "-t" ]; then
    __2m_get_current && __2m_format_duration_short $__2m_current_duration
  elif [ "$1" == "-s" ]; then
    __2m_status_short
  else
    __2m_status_long
    return $?
  fi
}

function 2m-start {
  if __2m_get_current; then
    printf "\nCannot start new TMR task: already doing $__2m_current_name. \nRun \`2m done\` or \`2m cancel\` to stop.\n\n"
  else
    __2m_this_task_name="${*}"
    jq \
      --argjson start_date $(date +%s) \
      --arg name "$__2m_this_task_name" \
      '.current = { start_date: $start_date, name: $name }' $__2m_logpath | sponge $__2m_logpath
    echo Begun 2m:
    2m-status
    # TODO: add progress
    # progress_flag="$1"
    # progress_time="$2"
    # numre='^[0-9]+([.][0-9]+)?$'
    # if [ "$progress_flag" == "-p" ]; then
    #   if ! [[ $progress_time =~ $re ]]; then
    #     echo "[tmr] -p needs a number argument" >&2;
    #     return 1;
    #   else
    #
    #   fi
    # fi

    if declare -f -F __2m_notify > /dev/null; then

      {
        local left=120
        while [ "$__2m_current_name" == "$__2m_this_task_name" ]; do
          if ! __2m_notify "$__2m_this_task_name" $left; then break; fi
          sleep 30
          left=$(expr $left - 30)
          __2m_get_current
        done;
        __2m_notify
      } & disown

    fi
  fi
}

function 2m-done {
  __2m_end "completed"
}

function 2m-finish {
  __2m_end "completed"
}

function 2m-cancel {
  __2m_end "cancelled"
}

function 2m-review-cancelled {
  __2m_review ".data.cancelled"
}

function 2m-review-completed {
  __2m_review ".data.completed"
}

function 2m-t {
  2m-start $(task _get ${1}.description)
}

function 2m {
  if __2m_not_blank $1; then
    __2m_command="2m-$1"
    __2m_type=$(type -t "$__2m_command")
    if [[ "$__2m_type" == "function" ]]; then
      shift
      eval "$__2m_command $@"
    else
      2m-start "$*"
    fi
  else
    2m-status
  fi
}

