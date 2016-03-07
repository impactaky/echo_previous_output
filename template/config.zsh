
# This value is used in the following script.
# echo $tmux_buffer | sed -n '/'$PromptCmdLinePattern'/='
# It must extract only last line of PROMPT.
PromptCmdLinePattern="^$HOST%"

Prompt2Pattern="^>"

# Number of $PROMPT lines.
PromptLines=`echo $PROMPT | wc -l`

# Number of buffer lines that use for searching.
SearchLines=`tmux show-options -gv history-limit`
