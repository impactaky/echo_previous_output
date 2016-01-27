function echo_last_result(){
	local prev_num=1
	local capture_option=''
	local ignore_blank_result=0
	while getopts cn:sl: opt; do
		case $opt in
			n)
				expr $OPTARG + 0 >/dev/null 2>&1
				if [ $? -ne 0 ]; then
					echo "Error: n option has invalid value" 1>&2
					return 1
				fi
				prev_num=$OPTARG;;
			c) capture_option="-e "$capture_option;;
			s) ignore_blank_result=1
		esac
	done
	local cursor_line=`tmux list-panes -F "#{?pane_active,#{cursor_y},}" | sed '/^$/d'`
	local -a match_lines
	match_lines=(`tmux capture-pane -p -S -100000 | sed -n '/└─/='`)
	if [ $prev_num -gt $#match_lines ]; then
		echo "Error: n option value out of range" 1>&2
		return 1
	fi

	# FIXME out of range error
	if [ $ignore_blank_result = 1 ]; then
		local i=-1
		local j=$(($match_lines[$i]-$match_lines[$i-1]==2?0:1))
		while [ $j -lt $prev_num ]; do 
			i=$(($i-1))
			if [ $((${match_lines[$i]}-$match_lines[$i-1])) -ne 2 ]; then
				j=$(($j+1))
			fi
		done
	else
		local i=-$prev_num
	fi
	if [ $#match_lines = 1 ]; then
		tmux capture-pane $capture_option -p -S -100000 -E $(($cursor_line-3))
	else
		local offset=$((cursor_line - $match_lines[-1]))
		tmux capture-pane $capture_option -p -S $(($match_lines[$i-1]+$offset)) -E $(($match_lines[$i]+$offset-3))
	fi
	return 0
}
