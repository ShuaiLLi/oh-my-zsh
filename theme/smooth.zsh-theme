# It is recommended to use with a dark background.
# Colors: black, red, green, yellow, *blue, magenta, cyan, and white.
#
# Sep 2021 Shuai Li

# Called before the command is executed
# REF: http://zsh.sourceforge.net/Doc/Release/Functions.html
preexec() {
    COMMAND_TIME_BEIGIN="$(current_time_millis)";
    LAST_COMMAND_DURATION_INFO="";
}


# Called after the command is executed
# REF: http://zsh.sourceforge.net/Doc/Release/Functions.html
precmd() {
    local last_cmd_return_code=$?;
    local last_cmd_result=true;
    if [ "$last_cmd_return_code" = "0" ];
    then
        last_cmd_result=true;
    else
        last_cmd_result=false;
    fi

    update_git_status;
    update_command_status $last_cmd_result;
    calculate_command_execution_duration $last_cmd_result;
}


function user_info() {
    local color="%{$fg_no_bold[yellow]%}";
    local color_reset="%{$reset_color%}";
    echo "${color}[%n]${color_reset}";
}


function current_path() {
    local color="%{$fg_no_bold[cyan]%}";
    local current_path="${PWD/#$HOME/~}";
    local color_reset="%{$reset_color%}";
    echo "${color}[${current_path}]${color_reset}";
}


function real_time() {
    local color="%{$fg_no_bold[cyan]%}";
    local time="[$(date +%H:%M:%S)]";
    local color_reset="%{$reset_color%}";
    echo "${color}${time}${color_reset}";
}


function current_time_millis() {
    local time_millis;
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # Linux
        time_millis="$(date +%s)";
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        time_millis="$(date +%s)";
    else
        # TBD.
    fi
    echo $time_millis;
}


# Git info
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_no_bold[blue]%}git(%{$fg_no_bold[red]%}";
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} ";
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_no_bold[blue]%}) 🔥";
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_no_bold[blue]%})";


function update_git_status() {
    GIT_STATUS=$(git_prompt_info);
}


function git_status() {
    echo "${GIT_STATUS}"
}


# Command status
function update_command_status() {
    local arrow="";
    local color_reset="%{$reset_color%}";
    local reset_font="%{$fg_no_bold[white]%}";
    COMMAND_RESULT=$1;
    export COMMAND_RESULT=$COMMAND_RESULT
    if $COMMAND_RESULT;
    then
        arrow="🍀🍀🍀";
    else
        arrow="😓😓😓";
    fi
    COMMAND_STATUS="${arrow}${reset_font}${color_reset}";
}


function command_status() {
    echo "${COMMAND_STATUS}"
}


# Command execution duration
func calculate_command_execution_duration() {
    if [ "$COMMAND_TIME_BEIGIN" = "-20200325" ] || [ "$COMMAND_TIME_BEIGIN" = "" ];
    then
        return 1;
    fi

    local time_end="$(current_time_millis)";
    local duration=$(bc -l <<<"${time_end}-${COMMAND_TIME_BEIGIN}");
    # reset
    COMMAND_TIME_BEIGIN="-20200325"
    local duration_info="[🐳⏰ ${duration}s]"
    local duration_info_color="$fg_no_bold[cyan]";
    LAST_COMMAND_DURATION_INFO="${duration_info_color}${duration_info}${color_reset}"
}

function last_command_duration_info() {
    echo "${LAST_COMMAND_DURATION_INFO}"
}


function terminfo_line_flag() {
    echo "%{$fg_bold[cyan]%}#%{$reset_color%}"
}

function command_line_flag() {
    echo "%{$fg_bold[red]%}$ %{$reset_color%}"
}

# Init command status
update_command_status true;

duration_time=""

# Set option
setopt PROMPT_SUBST;

# Timer
#REF: https://stackoverflow.com/questions/26526175/zsh-menu-completion-causes-problems-after-zle-reset-prompt
TMOUT=1;
TRAPALRM() {
    # $(git_prompt_info) cost too much time which will raise stutters when inputting. so we need to disable it in this occurence.
    # if [ "$WIDGET" != "expand-or-complete" ] && [ "$WIDGET" != "self-insert" ] && [ "$WIDGET" != "backward-delete-char" ]; then
    # black list will not enum it completely. even some pipe broken will appear.
    # so we just put a white list here.
    if [ "$WIDGET" = "" ] || [ "$WIDGET" = "accept-line" ] ; then
        zle reset-prompt;
    fi
}


# Prompt
PROMPT='
$(terminfo_line_flag) \
🔆🌈 $(real_time)$(last_command_duration_info) $(user_info) $(current_path) $(git_status)$(command_status)
$(command_line_flag)';


