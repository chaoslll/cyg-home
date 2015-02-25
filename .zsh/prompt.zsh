# Enable colors
autoload colors && colors

# Enable number of suspended jobs
function precmd() {
  numberofsuspendedjobs="${(Mw)#jobstates#suspended:}"
}

function ssh_prompt() {
  if [ $SSH_CONNECTION ]; then echo "%{$fg_bold[white]%}%M "; fi
}

function current_path() {
  echo "%{$FG[ORANGE]%}%2c%f"
}

function left_prompt() {
  cols="$(tput cols)"
  if [ "$cols" -gt 88 ]; then
    echo "$(ssh_prompt)$(current_path)$(git_prompt_left)$(susp_jobs_left) "
  else
    echo "$(ssh_prompt)$(current_path) "
  fi
}

function right_prompt() {
  cols="$(tput cols)"
  if [ "$cols" -le 88 ]; then
    echo "$(susp_jobs_right)$(git_prompt_right)"
  fi
}

# Name of the current branch
function git_current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

# Short SHA of the current head
function git_short_sha() {
  echo "$(git rev-parse --short HEAD 2> /dev/null)"
}

# Name of the current remote
function git_remote_name() {
  remote=$(git config branch.$(git_current_branch).remote 2> /dev/null) || return
  echo "$remote"
}

# Refspec marked for merging
function git_merge_name() {
  merge=$(git config branch.$(git_current_branch).merge 2> /dev/null) || return
  echo "$merge"
}

function git_remote_ref() {
  remote="$(git_remote_name 2> /dev/null)"
  if [ "$remote" = "." ]; then
    echo "$(git_merge_name)"
  else
    merge=$(git_merge_name)
    echo "refs/remotes/$(git_remote_name)/${merge#refs/heads/}"
  fi
}

# Prints the number of commits your are ahead or behind of the upstream repo,
# e.g. '2,3' means 2 ahead, 3 behind
function git_ahead_behind_state() {
  list="$(git rev-list --left-right $(git_remote_ref)...HEAD 2> /dev/null)"
  ahead=$(echo $list | grep '>' | wc -l | tr -d ' ')
  behind=$(echo $list | grep '<' | wc -l | tr -d ' ')

  if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
    echo "%{$FG[GRAY]%}:%{$FG[GREEN]%}$ahead%f,%{$FG[RED]%}$behind%f"
  elif [ "$ahead" -gt 0 ]; then
    echo "%{$FG[GRAY]%}:%{$FG[GREEN]%}$ahead%f"
  elif [ "$behind" -gt 0 ]; then
    echo "%{$FG[GRAY]%}:%{$FG[RED]%}$behind%f"
  fi
}

# Time since last commit, in seconds
function git_time_since_last_commit() {
  if [ -n "$(git_short_sha)" ]; then
    last="$(git log --pretty=format:'%at' -1 2> /dev/null)"
    now="$(date +%s)"
    echo "$((now - last))"
  fi
}

function git_worktime() {
  if [ -n "$(git_short_sha)" ]; then
    timestr=$(git log -1 --pretty=format:"%ar" | sed 's/\([0-9]*\) \(.\).*/\1\2/')
    seconds="$(git_time_since_last_commit)"
    if [ "$seconds" -gt 3600 ]; then
      echo "%{$FG[RED]%}$timestr%f"
    elif if [ "$seconds" -gt 1200 ]; then
      echo "%{$FG[ORANGE]%}$timestr%f"
    else
      echo "%{$FG[GREEN]%}$timestr%f"
    fi
  fi
}

function git_branch_state() {
  if [ -n "$(git_current_branch)" ]; then
    echo "%{$FG[DARKBLUE]%}$(git_current_branch)$(git_ahead_behind_state)%f"
  else
    echo "%{$FG[RED]%}$(git_short_sha)%f"
  fi
}

function git_dirty_state() {
  if [ -z "$(git_short_sha)" ]; then
    return
  fi

  test -z "$(git ls-files --exclude-standard --others)" 2> /dev/null
  untracked=$?

  git diff-files --quiet 2> /dev/null
  changed=$?

  git diff-index --quiet --cached HEAD
  staged=$?

  statusstr=''

  if  [ "$staged" -eq 1 ]; then
    statusstr+="%{$FG[GREEN]%}*%f"
  fi
  if  [ "$changed" -eq 1 ]; then
    statusstr+="%{$FG[ORANGE]%}*%f"
  fi
  if  [ "$untracked" -eq 1 ]; then
    statusstr+="%{$FG[RED]%}*%f"
  fi

  echo "$statusstr"
}

function git_prompt() {
  prompt="%{$FG[GRAY]%}[%f"
  prompt+="$(git_worktime)"
  prompt+="%{$FG[GRAY]%}|%f"
  prompt+="$(git_branch_state)$(git_dirty_state)"
  prompt+="%{$FG[GRAY]%}]%f"
  echo "$prompt"
}

function git_prompt_left() {
  if [ -n "$(git_short_sha)" ]; then
    echo " $(git_prompt)"
  fi
}

function git_prompt_right() {
  if [ -n "$(git_short_sha)" ]; then
    echo "$(git_prompt)"
  fi
}

function susp_jobs_left() {
  if [ "$numberofsuspendedjobs" -ne "0" ]; then
    echo " ($numberofsuspendedjobs)";
  fi
}


function susp_jobs_right() {
  if [ "$numberofsuspendedjobs" -ne "0" ]; then
    echo "($numberofsuspendedjobs) ";
  fi
}

PROMPT="$(left_prompt)"
RPROMPT="$(right_prompt)"

bindkey -M vicmd "H" beginning-of-line
bindkey -M vicmd "L" end-of-line
