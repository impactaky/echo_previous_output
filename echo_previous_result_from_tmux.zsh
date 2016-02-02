PromptHeadPattern='^┌─'
PromptTailPattern='^└─'

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
    local -a match_head_lines
    local -a match_tail_lines
    match_head_lines=(`tmux capture-pane -p -S -100000 | sed -n '/'$PromptHeadPattern'/='`)
    match_tail_lines=(`tmux capture-pane -p -S -100000 | sed -n '/'$PromptTailPattern'/='`)

    if [ $ignore_blank_result ]; then
        local i=-1
        local j=0
        local inv_match_num=`expr -$#match_tail_lines`
        while [ $j -lt $prev_num ]; do 
            i=$(($i-1))
            if [ $i -le $inv_match_num ]; then
                echo "Error: n option value out of range" 1>&2
                return 1
            elif [ $(($match_tail_lines[$i]-$match_head_lines[$i+1])) -ne -1 ]; then
                j=$(($j+1))
            fi
        done
    else
        if [ $prev_num -ge $#match_tail_lines ]; then
            echo "Error: n option value out of range" 1>&2
            return 1
        fi
		local i=$((-$prev_num-1))
		if [ $(($match_tail_lines[$i]-$match_head_lines[$i+1])) = -1 ]; then
			return 0
		fi
    fi

    local cursor_line=`tmux list-panes -F "#{?pane_active,#{cursor_y},}" | sed '/^$/d'`
    local offset=$((cursor_line - $match_tail_lines[-1]))
    tmux capture-pane $capture_option -p -S $(($match_tail_lines[$i]+$offset)) -E $(($match_head_lines[$i+1]+$offset-2))
    return 0
}
