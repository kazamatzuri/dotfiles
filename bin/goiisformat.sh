#!/usr/bin/env sh

while read line; do
  if [[ $line == \#Fields:* ]]; then
    line=${line/\#Fields: /}
    line=${line/date/%d}
    line=${line/time/%t}
    line=${line/s-sitename/%^}
    line=${line/s-computername/%^}
    line=${line/s-ip/%^}
    line=${line/cs-method/%m}
    line=${line/cs-uri-stem/%U}
    line=${line/cs-uri-query/%^}
    line=${line/s-port/%^}
    line=${line/cs-username/%^}
    line=${line/c-ip/%h}
    line=${line/cs-version/%H}
    line=${line/cs(User-Agent)/%u}
    line=${line/cs(Cookie)/%^}
    line=${line/cs(Referer)/%R}
    line=${line/cs-host/%^}
    line=${line/sc-status/%s}
    line=${line/sc-substatus/%^}
    line=${line/sc-win32-status/%^}
    line=${line/sc-bytes/%b}
    line=${line/cs-bytes/%^}
    line=${line/time-taken/%L}
    echo $line
    exit;
  fi
done
