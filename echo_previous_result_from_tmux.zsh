function echo_last_result(){
	CURSOR_LINE=`tmux list-panes -F "#{?pane_active,#{cursor_y},}" | sed '/^$/d'`
	LINE=(`tmux capture-pane -p -S -100000 | sed -n '/┌─/=' | tail -n 2`)
	if [ $#LINE = 1 ]; then
		tmux capture-pane -e -p -S -100000 -E $(($CURSOR_LINE-3))
	else
		OFFSET=$((CURSOR_LINE-${LINE[2]}))
		tmux capture-pane -e -p -S $((${LINE[1]}+$OFFSET)) -E $(($CURSOR_LINE-3))
	fi
}
