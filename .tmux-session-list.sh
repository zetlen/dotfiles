TTMUX_SESSIONS=$(tmux list-panes -a -F "#{session_name}%#{session_alerts}")
TTMUX_CURRENT_SESSION=$(tmux display-message -p '#S')
TLIST=""
for s in $TTMUX_SESSIONS; do
    TSESH=$(echo $s | cut -d'%' -f 1)
    TALERTS=$(echo $s | cut -d'%' -f 2)
    TLIST="${TLIST} ${TSESH}"
    if [ -n "$TALERTS" ]; then
        TLIST="${TLIST} \U26a0 "
    elif [ "$TSESH" == "$TTMUX_CURRENT_SESSION" ]; then
        TLIST="${TLIST} \U1f533 "
    else
        TLIST="${TLIST} \U2b1c "
    fi
done
perl -CO -pE 's/\\u(\p{Hex}+)/chr(hex($1))/xieg' <<< "$TLIST"
