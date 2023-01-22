function __prompt_echo_workspace_label {
	if [ -n "$WS_LABEL" ]; then
		echo -n "[$WS_LABEL] "
	fi
}

function __scan_path_for_tools {
	WS_LABEL=""
	IFS='/' read -r -a array <<< $PATH
	numslash=0
	for index in "${!array[@]}"
	do
		if [[ ${array[index]} == "sdk" ]] || [[ ${array[index]} == ".sdk" ]]; then
			if [[ ${numslash} -gt 0 ]]; then
				WS_LABEL+=":"
			fi
			
			foldername=${array[index+1]}
			end=$((${#foldername}-1))	
			if [ "${foldername:end:1}" = ":" ]; then
				foldername=${foldername::-1}
			fi
			WS_LABEL+=$foldername
			
			numslash+=1
		fi
	done
	export WS_LABEL
}

function ws {
	if [ -z "${1}" ]; then
		cd ~/Workspace
	else
		filename=${1}
		end=$((${#filename}-1))	
		if [ "${filename:end:1}" = "/" ]; then
			filename=${filename::-1}
		fi

		if [ -d "${filename}" ]; then
			cd ${filename}
		else
			cd ~/Workspace/${filename}*
		fi

		if [ -f ".workspacerc" ]; then
			source .workspacerc
			if [ -z "${WS_LABEL}" ]; then
				__scan_path_for_tools
			fi
		else
			:
			#echo "no workspace bash file"
		fi
	fi
}

function wes {
	temp=${WS_LABEL_HIDDEN}
	export WS_LABEL_HIDDEN=${WS_LABEL}
	export WS_LABEL=${temp}
}

