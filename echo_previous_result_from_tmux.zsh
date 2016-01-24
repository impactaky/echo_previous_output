function echo_last_result(){
	local prev_num=0
	local capture_option=''
	while getopts cn: opt
	do
		case $opt in
			n) prev_num=$OPTARG;;
			c) capture_option="-e "$capture_option;;
		esac
	done
	local cursor_line=`tmux list-panes -F "#{?pane_active,#{cursor_y},}" | sed '/^$/d'`
	local -a match_lines
	match_lines=(`tmux capture-pane -p -S -100000 | sed -n '/┌─/=' | tail -n $((2+$prev_num))`)
	if [ $#match_lines = 1 ]; then
		tmux capture-pane $capture_option -p -S -100000 -E $(($CURSOR_LINE-3))
	else
		local offset=$((cursor_line - $match_lines[-1]))
		tmux capture-pane $capture_option -p -S $((${match_lines[1]}+$offset)) -E $((${match_lines[2]}+$offset-3))
	fi
	return 0
}
