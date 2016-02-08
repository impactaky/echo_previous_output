
# This value is used in the following script.
# echo $tmux_buffer | sed -n '/'$PromptCmdLinePattern'/='
# It must extract only last line of PROMPT.
PromptCmdLinePattern="^$HOST%"

# Number of $PROMPT lines.
PromptLines=`echo $PROMPT | wc -l`

