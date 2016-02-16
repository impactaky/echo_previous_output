PromptCmdLinePattern="^$HOST%"
Prompt2Pattern="^>"
PromptLines=1
SearchLines=2000


source ./echo_previous_result_from_tmux.zsh

function clear_buffer() {
	clear
	tmux clear-history
	echo "$HOST%"
}

function set_result() {
	echo -n "$1"
	echo "$HOST%"
}

test_num=1
function check_error() {
	if [ $? != $1 ]; then
		log+="Error in test$test_num : $?\n"
	fi
	test_num=$((test_num+1))
}

local echo_pattern
for i in {-5..$COLUMNS}
do
	echo_pattern+='t'
done

function set_case1() {
	clear_buffer
	set_result $echo_pattern'\n'
}

function set_case2() {
	clear_buffer
	set_result $echo_pattern'\n'
	set_result ''
}

function set_case3() {
	clear_buffer
	set_result "> command\n> command2\n$echo_pattern\n"
}

set_case1
[ $(echo_last_result) = $echo_pattern ]
check_error 0

set_case1
[ $(echo_last_result -s) = $echo_pattern ]  
check_error 0

set_case1
echo_last_result -n 2 
check_error 1

set_case1
echo_last_result -n a 
check_error 3

set_case1
echo_last_result --invalid
check_error 2

set_case2
[ $(echo_last_result) ] 
check_error 1

set_case2
[ $(echo_last_result -s) = $echo_pattern ]
check_error 0

set_case2
echo_last_result -s -n 2 
check_error 1

set_case3
[ $(echo_last_result -s) = $echo_pattern ]
check_error 0
echo_last_result -s

# clear
echo -n $log
