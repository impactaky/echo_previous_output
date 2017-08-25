

function echo_previous_output(){

	[ $PromptCmdLinePattern ] || echo '$PromptCmdLinePattern is undefined'
	[ $Prompt2Pattern ] || echo '$Prompt2Pattern is undefined'
	[ $PromptLines ] || `echo $PROMPT | wc -l`
	[ $SearchLines ] || SearchLines=2000

	if ! [ $TMUX ]; then
		echo 'tmux is not running'
		return 0xf
	fi
	local prev_num=1
	local blank_result=0
	while getopts bn: opt; do
		case $opt in
		n)  expr $OPTARG + 0 >/dev/null 2>&1
			if [ $? -ne 0 ]; then
			echo "Error: n option has invalid value" 1>&2
			return 3
			fi
			prev_num=$OPTARG;;
		b)  blank_result=1;;
			*)  return 2
		esac
	done
	local -a buffer
	buffer=("${(@f)$(tmux capture-pane -epJ -S -$SearchLines | sed '/'$Prompt2Pattern'/d')}")
	local -a match_cmd_lines
	match_cmd_lines=(`print -l $buffer | sed -n '/'$PromptCmdLinePattern'/='`)

	if [ $blank_result -eq 0 ]; then
		local i=1
		while [ $i -ne $#match_cmd_lines ]; do
			if [ $(($match_cmd_lines[-$i]-$match_cmd_lines[-$i-1])) -eq $PromptLines ]; then
				local delete_num=$match_cmd_lines[-$i-1]
				buffer=("${(@)buffer[1,$delete_num-1]}" "${(@)buffer[$delete_num+$PromptLines,$#buffer]}")
			fi
			i=$(($i+1))
		done
		match_cmd_lines=(`print -l $buffer | sed -n '/'$PromptCmdLinePattern'/='`)
	fi

	if [ $prev_num -ge $#match_cmd_lines ]; then
		echo "Error: n option value out of range" 1>&2
		return 1
	fi
	local i=$((-$prev_num-1))
	if [ $(($match_cmd_lines[$i+1]-$match_cmd_lines[$i])) = $PromptLines ]; then
		return 0
	fi

	print -l $buffer | sed -n "$(($match_cmd_lines[$i]+1)),$(($match_cmd_lines[$i+1]-$PromptLines))p"
	return 0
}
