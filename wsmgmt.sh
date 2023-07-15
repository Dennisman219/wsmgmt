# Function to be used in the bash PS1 prompt to show the label of the currently active workspace
function __prompt_echo_workspace_label {
	if [ -n "$WS_LABEL" ]; then # if environment variable $WS_LABEL is an NOT empty string,
		echo -n "[$WS_LABEL] " # then echo the string
	fi
}

# Function to generate a label for a workspace based on the folders that are added to the environment variable $PATH by the .workspacerc script 
function __create_label_from_path {
	WS_LABEL="" # start with an empty string for the label of the workspace
	IFS='/' read -r -a array <<< $PATH # split string $PATH, use '/' as delimiter, put result in array named 'array'
	numslash=0 
	for index in "${!array[@]}" # for index <- 0..n where n = |array|
	do
		if [[ ${array[index]} == "sdk" ]] || [[ ${array[index]} == ".sdk" ]]; then # if the string at position of index of array is either 'sdk' or '.sdk'
			if [[ ${numslash} -gt 0 ]]; then # then, if there is already a name of a folder in the label
				WS_LABEL+=":" # add a ':' to seperate the names of folder in the label (e.g. 'make:gcc')
			fi
			
			foldername=${array[index+1]} # the name of the folder is the element in array after 'sdk' or '.sdk'
			end=$((${#foldername}-1)) # get the last char of the name of the folder
			if [ "${foldername:end:1}" = ":" ]; then # if that last char is ':'
				foldername=${foldername::-1} # remove the last char from the string containing the folder name
			fi
			WS_LABEL+=$foldername # add the name of the folder to the label
			
			numslash+=1 # increment the numder of folder names that are in the label
		fi
	done
	export WS_LABEL # When done with the for loop, export the label containing the folder names
}

# Function to activate a Specified workspace
function ws {
	if [ -z "${1}" ]; then # if not specific workspace is given,
		cd ~/Workspace # then, move the user to the folder containing their workspaces
	else # if a workspace is specified as an argument
		filename=${1} # get the string of that argument
		end=$((${#filename}-1))	 # get the last char of that string 
		if [ "${filename:end:1}" = "/" ]; then # if that char is '/' (which is often at the end of the string when using tab-completion)
			filename=${filename::-1} # remove the last char (i.e. the '/') from the string
		fi

		if [ -d "${filename}" ]; then # if the specified workspace is a folder in the current working directory,
			cd ${filename} # then, move into that folder
		else # if the specified workspace is not in the current working directory
			cd ~/Workspace/${filename}* # then, move into the folder which starts with the specified argument in the central Workspaces folder
		fi

		if [ -f ".workspacerc" ]; then # if there is a .workspacerc script in the workspace folder to initialise the environment
			source .workspacerc # source that script
			if [ -z "${WS_LABEL}" ]; then # if that script has not specified a label for the workspace
				__create_label_from_path # generate that label based on the new folders in $PATH
			fi
		else # if there is no .workspacerc script
			: # do nothing
		fi
	fi
}

# Function to switch the label of the workspace with a shorter or empty version (and vice-versa) to decrease the length in takes in the prompt
function wes {
	temp=${WS_LABEL_HIDDEN}
	export WS_LABEL_HIDDEN=${WS_LABEL}
	export WS_LABEL=${temp}
}

