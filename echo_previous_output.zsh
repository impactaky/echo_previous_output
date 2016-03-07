
[ $PromptCmdLinePattern ] || echo '$PromptCmdLinePattern is undefined'
[ $Prompt2Pattern ] || echo '$Prompt2Pattern is undefined'
[ $PromptLines ] || `echo $PROMPT | wc -l`
[ $SearchLines ] || SearchLines=2000

function echo_previous_output(){
	if ! [ $TMUX ]; then
		echo 'tmux is not running'
		return 0xf
	fi
    local prev_num=1
	local ignore_blank_result=1
    while getopts sn: opt; do
        case $opt in
            n)  expr $OPTARG + 0 >/dev/null 2>&1
                if [ $? -ne 0 ]; then
                    echo "Error: n option has invalid value" 1>&2
                    return 3
                fi
                prev_num=$OPTARG;;
            i)  ignore_blank_result=0;;
			*)  return 2
        esac
    done
	local -a buffer
	buffer=$(tmux capture-pane -epJ -S -$SearchLines | sed '/'$Prompt2Pattern'/d')
    local -a match_cmd_lines
	match_cmd_lines=(`echo $buffer | sed -n '/'$PromptCmdLinePattern'/='`)

    if [ $ignore_blank_result -eq 1 ]; then
        local i=-1
        local j=0
        local inv_match_num=`expr -$#match_cmd_lines`
        while [ $j -lt $prev_num ]; do 
            i=$(($i-1))
            if [ $i -lt $inv_match_num ]; then
                echo "Error: n option value out of range" 1>&2
                return 1
            elif [ $(($match_cmd_lines[$i+1]-$match_cmd_lines[$i])) -ne $PromptLines ]; then
                j=$(($j+1))
            fi
        done
    else
        if [ $prev_num -ge $#match_cmd_lines ]; then
            echo "Error: n option value out of range" 1>&2
            return 1
        fi
		local i=$((-$prev_num-1))
		if [ $(($match_cmd_lines[$i+1]-$match_cmd_lines[$i])) = $PromptLines ]; then
			return 0
		fi
    fi

	echo $buffer | sed -n "$(($match_cmd_lines[$i]+1)),$(($match_cmd_lines[$i+1]-$PromptLines))p"
    return 0
}
