function echo_last_result(){
	local prev_num=0
	while getopts n: opt
	do
		case $opt in
			n) prev_num=$OPTARG
		esac
	done
	local cursor_line=`tmux list-panes -F "#{?pane_active,#{cursor_y},}" | sed '/^$/d'`
	local -a match_lines
	match_lines=(`tmux capture-pane -p -S -100000 | sed -n '/┌─/=' | tail -n $((2+$prev_num))`)
	if [ $#match_lines = 1 ]; then
		tmux capture-pane -e -p -S -100000 -E $(($CURSOR_LINE-3))
	else
		local offset=$((cursor_line - $match_lines[-1]))
		tmux capture-pane -e -p -S $((${match_lines[1]}+$offset)) -E $((${match_lines[2]}+$offset-3))
	fi
	return 0
}
