
function echo_last_result(){
    local prev_num=1
    while getopts cn:sl: opt; do
        case $opt in
            n)  expr $OPTARG + 0 >/dev/null 2>&1
                if [ $? -ne 0 ]; then
                    echo "Error: n option has invalid value" 1>&2
                    return 1
                fi
                prev_num=$OPTARG;;
            c)  local capture_option="-e";;
            s)  local ignore_blank_result=1;;
			*)  return 2
        esac
    done
	local -a buffer
	buffer=$(tmux capture-pane -epJ)
    local -a match_cmd_lines
	match_cmd_lines=(`echo $buffer | sed -n '/'$PromptCmdLinePattern'/='`)

    if [ $ignore_blank_result ]; then
        local i=-1
        local j=0
        local inv_match_num=`expr -$#match_cmd_lines`
        while [ $j -lt $prev_num ]; do 
            i=$(($i-1))
            if [ $i -lt $inv_match_num ]; then
                echo "Error: n option value out of range" 1>&2
                return 1
            elif [ $(($match_cmd_lines[$i]-$match_cmd_lines[$i+1])) -ne -1 ]; then
                j=$(($j+1))
            fi
        done
    else
        if [ $prev_num -ge $#match_cmd_lines ]; then
            echo "Error: n option value out of range" 1>&2
            return 1
        fi
		local i=$((-$prev_num-1))
		if [ $(($match_cmd_lines[$i]-$match_cmd_lines[$i+1])) = -1 ]; then
			return 0
		fi
    fi

	echo $buffer | sed -n "$(($match_cmd_lines[$i]+1)),$(($match_cmd_lines[$i+1]-1))p"
    return 0
}
