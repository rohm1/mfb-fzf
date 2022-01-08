#!/bin/bash

mfb_self=${BASH_SOURCE[0]}

function mfb:ls {
  ls ${mfb_ls_options} "${1}"
}

function mfb:extract_line {
  echo "${1}" | awk "{print \$${mfb_line_index}}"
}

function mfb:path_prefix {
  [ "${1}" = "/" ] && echo "/" || echo "${1}/"
}

function mfb:select {
  realpath "$(mfb:path_prefix "${1}")/$(mfb:extract_line "${2}")"
}

function mfb:preview {
  mfb_line_index=${3}
  local selected=$(mfb:select "$1" "$2")
  if [ -d "${selected}" ];
  then
    mfb:ls "${selected}"
  elif [[ "$(file "${selected}")" =~ "text" ]];
  then
    less "${selected}"
  else
    echo "binary file"
  fi
}

function mfb:search {
  mfb:ls "${1}" | tail --lines=+${mfb_lines_to_skip} | fzf --prompt="$(mfb:path_prefix "${1}")" \
      --layout=reverse --ansi --print-query --nth=${mfb_line_index} \
      --expect=ctrl-q,ctrl-e,ctrl-c,ctrl-d,ctrl-s,esc,ctrl-t \
      --preview="bash -c \"source ${mfb_self}; mfb:preview '${1}' {} '${mfb_line_index}'\"" \
      --preview-window="$([ "${mfb_show_preview}" = "0" ] && echo :hidden)"
}

function mfb {
    mfb_ls_options=${MFB_LS_OPTIONS:---group-directories-first -hla --color}
    mfb_line_index=${MFB_LINE_INDEX:-9}
    mfb_lines_to_skip=${MFB_LINES_TO_SKIP:-3}
    mfb_show_preview=${MFB_SHOW_PREVIEW:-1}

    while getopts "l:i:s:p:" option "$@"; do
      case ${option} in
        l)
           mfb_ls_options=${OPTARG};;
        i)
           mfb_line_index=${OPTARG};;
        s)
           mfb_lines_to_skip=${OPTARG};;
        p)
           mfb_show_preview=${OPTARG};;
        \?) # Invalid option
           echo "Error: Invalid option ${OPTARG}"
           return;;
      esac
    done

    local path=$(pwd)

    while true;
    do
	    local r=$(mfb:search "${path}")

      local q=$(echo "$r" | head -n1)
	    local key=$(echo "$r" | head -n2 | tail -n1)
      local selected=$(mfb:select "${path}" "$(echo "${r}" | tail -n1)")

	    if [ "${key}" = "ctrl-c" ] ||  [ "${key}" = "ctrl-d" ] || [ "${key}" = "esc" ];
	    then
		    break
	    elif [ "${key}" = "ctrl-q" ];
	    then
        cd "${path}"
		    break
	    elif [ "${key}" = "ctrl-s" ];
	    then
        echo "${selected}"
		    break
	    elif [ "${key}" = "ctrl-e" ];
	    then
        editor "${selected}"
		    continue
	    elif [ "${key}" = "ctrl-t" ];
	    then
        mfb_show_preview=$([ "${mfb_show_preview}" = "1" ] && echo 0 || echo 1)
		    continue
	    fi

      if [ "${q}" = "/" ];
      then
        path="/"
        continue
      elif [ "${q}" = "~" ];
      then
        path="${HOME}"
        continue
      elif [ "${q}" = ".." ];
      then
        path=$(realpath "${path}/..")
        continue
      fi

	    if [ -d "${selected}" ];
	    then
		    path="${selected}"
	    else
		    xdg-open "${selected}" > /dev/null 2>&1
	    fi
    done
}
