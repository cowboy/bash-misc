# my bash prompt - v0.1 - 9/29/2009
# http://benalman.com/
# http://www.flickr.com/photos/rj3/3959554047/sizes/o/
# 
# Copyright (c) 2009 "Cowboy" Ben Alman
# Licensed under the MIT license
# http://benalman.com/about/license/
# 
# Usage:
# 
# In my home folder, [user@host:directory] on the 1st line, [HH:MM] on the 2nd line:
# 
# [cowboy@benalman:~]
# [19:55:20] $ 
# 
# In an svn-managed directory, [revision:last_changed_revision] is prepended to line 1:
# 
# [194:197][cowboy@benalman:/srv/www/public_html/benalman/code/javascript/jquery]
# [19:55:25] $ 
# 
# In a git-managed directory, [branch] or [branch:status] is prepended to line 1 where
# status is some combination of * for staged changes, C for unstaged changes, and
# U for untracked files:
# 
# [master][cowboy@benalman:/srv/projects/jquery-bbq]
# [19:56:17] $ 

function prompt_git() {
  local BRANCH=$(git branch 2>/dev/null | awk '/^\*/ { print($2) }')
  local STATUS=$(git status 2>/dev/null | awk 'BEGIN {r=""} /^# Changes to be committed:$/ {r=r "*"}\
    /^# Changed but not updated:$/ {r=r "C"} /^# Untracked files:$/ {r=r "U"} END {print(r)}')
  
  local OUT=$BRANCH
  if [ "$STATUS" ]; then
    OUT=$OUT$3:$2$STATUS
  fi
  if [ "$OUT" ]; then
    OUT=$4[$2$OUT$4]$1
  fi
  
  echo $OUT
}

function prompt_svn() {
  svn info . 2>/dev/null | awk "/Revision:/ {r=\$2} /Last Changed Rev:/ {c=\$4; printf(\"$4[$2%d$3:$2%d$4]$1\",c,r)}"
}

function prompt_init() {
  # ANSI CODES (SEPARATE MULTIPLE VALUES WITH ;)
  # 
  # 0   reset
  # 1   bold
  # 4   underline
  # 7   inverse
  # 
  # FG  BG  COLOR
  # 30  40  black
  # 31  41  red
  # 32  42  green
  # 33  43  yellow
  # 34  44  blue
  # 35  45  magenta
  # 36  46  cyan
  # 37  47  white
  
  local TEXT_COLOR
  local SIGIL_COLOR
  local BRACKET_COLOR
  
  if [ "$SSH_TTY" ]; then             # connected via ssh
    TEXT_COLOR='32'
    SIGIL_COLOR='37'
  elif [ "$USER" == "root" ]; then    # logged in as root
    TEXT_COLOR='31'
    SIGIL_COLOR='37'
  else                                # connected locally
    TEXT_COLOR='36'
    SIGIL_COLOR='37'
  fi
  
  BRACKET_COLOR=$SIGIL_COLOR
  
  local C1='\[\e[0m\]'
  local C2='\[\e[0;'$TEXT_COLOR'm\]'
  local C3='\[\e[0;'$SIGIL_COLOR'm\]'
  local C4='\[\e[0;'$BRACKET_COLOR'm\]'

export PS1="\n\
\$(prompt_svn '$C1' '$C2' '$C3' '$C4')\
\$(prompt_git '$C1' '$C2' '$C3' '$C4')\
$C4[$C2\u$C3@$C2\h$C3:$C2\w$C4]$C1\n\
$C4[$C2\$(date +%H)$C3:$C2\$(date +%M)$C3:$C2\$(date +%S)$C4]$C1\
 \\$ "
}
prompt_init
