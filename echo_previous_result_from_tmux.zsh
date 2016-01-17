function echo_last_result(){
	local PREV_NUM=0
	while getopts n: opt
	do
		case $opt in
			n) PREV_NUM=$OPTARG
		esac
	done
	local CURSOR_LINE=`tmux list-panes -F "#{?pane_active,#{cursor_y},}" | sed '/^$/d'`
	MATCH_LINES=`tmux capture-pane -p -S -100000 | sed -n '/┌─/=' | tail -n $((2+$PREV_NUM))`
	LINE=(`echo $MATCH_LINES | head -n 2`)
	if [ $#LINE = 1 ]; then
		tmux capture-pane -e -p -S -100000 -E $(($CURSOR_LINE-3))
	else
		OFFSET=$((CURSOR_LINE-`echo $MATCH_LINES | tail -n 1`))
		tmux capture-pane -e -p -S $((${LINE[1]}+$OFFSET)) -E $((${LINE[2]}+$OFFSET-3))
	fi
	return 0
}
