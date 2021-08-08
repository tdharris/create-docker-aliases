#!/bin/bash
DRY_RUN=false
OUTPUT_FILE="$HOME/.bash_aliases"

usage() {
    echo
    echo "createDockerAliases: append to ~/.bash_aliases with container name action to cd to the docker container base directory."
    echo
    echo "Usage: createDockerAliases [options]"
    echo 
    echo "Options:"
    echo
    echo -e "\t-b  --docker-base-dir <name> \t(required) Base directory path to grep container mounts for to determine target path"
    echo -e "\t-o  --output <file> \t\t(optional) Output file to append generated aliases into (defaults to ~/.bash_aliases, creates a backup first)"
    echo -e "\t-r  --dry-run \t\t\t(optional) Show outputs and do not append aliases to file"
    echo -e "\t-h  --help"
    echo
    echo "Examples:"
    echo
    echo -e "\tcreateDockerAliases -b '/path/to/docker/containers/'"
    echo -e "\tcreateDockerAliases -b '/path/to/docker/containers/' -o '/path/to/myAliases'"
    echo
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -h | --help)
        usage
        exit
        ;;
    -b | --docker-base-dir)
        DOCKER_BASE_DIR=$2
        shift
        ;;
    -o | --output)
        OUTPUT_FILE=$2
        shift
        ;;
    -d | --dry-run)
        DRY_RUN=true
        ;;
    *)
        echo "ERROR: unknown parameter \"$PARAM\""
        usage
        exit 1
        ;;
    esac
    shift
done

if [ -z "$DOCKER_BASE_DIR" ]; then (echo >&2 "ERROR: Missing docker-base-dir."); exit 1; fi
if [ -z "$OUTPUT_FILE" ]; then (echo >&2 "ERROR: Missing output file."); exit 1; fi

if ! $DRY_RUN; then
    # Backup aliases
    echo -e "\nCreating backup of $OUTPUT_FILE ..."
    cp --verbose "$OUTPUT_FILE" "$OUTPUT_FILE.bak"
    # Append header
    if ! grep "^# create-docker-aliases" "$OUTPUT_FILE"; then
        echo -e "\n# create-docker-aliases" >> "$OUTPUT_FILE"
    fi
fi

# Containers
echo -e "\n--\nContainers and parsed directories...\n"
docker inspect -f "{{.Name}}:{{ .HostConfig.Binds }}" $(docker ps -q) | while read -r line ; do
    name=$(echo "$line" | cut -d: -f1 | sed 's/^\///')
    directory=$(echo "$line" | cut -d: -f2- | sed 's/\[//' | sed 's/]//' | sed 's/\s/\n/g' | cut -d: -f1 | cut -d/ -f1-5 | grep "$DOCKER_BASE_DIR" | head -n1)
    # If directory is blank, then check ".HostConfig.Mounts" instead
    if [ -z "$directory" ]; then
        directory=$(docker inspect -f "{{ .HostConfig.Mounts }}" "$name" | sed 's/bind/\nbind/g' | grep "$DOCKER_BASE_DIR" | sed 's/<nil>.*//' | sed 's/bind //' | cut -d/ -f1-5 | head -n1)
    fi
    
    # Result
    echo -e "$name : $directory"

    if [[ -z "$directory" ]]; then
        echo "Parsed directory is blank, skipping."
        else
            if ! $DRY_RUN; then
                if ! grep "$directory" "$OUTPUT_FILE"; then
                    echo "alias $name='cd $directory'" >> "$OUTPUT_FILE"
                fi
            fi
    fi
done

if ! $DRY_RUN; then
    echo -e "\n--\n"
    sed -n -e '/create-docker-aliases/,$p' "$OUTPUT_FILE"
fi
