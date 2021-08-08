# create-docker-aliases
creates bash aliases of containers that change directory to the preferred host directory mount

## Usage
```shell
createDockerAliases: append to ~/.bash_aliases with container name action to cd to the docker container base directory.

Usage: createDockerAliases [options]

Options:

        -b  --docker-base-dir <name>    (required) Base directory path to grep container mounts for to determine target path
        -o  --output <file>             (optional) Output file to append generated aliases into (defaults to ~/.bash_aliases, creates a backup first)        
        -r  --dry-run                   (optional) Show outputs and do not append aliases to file
        -h  --help

Examples:

        createDockerAliases -b '/path/to/docker/containers/'
        createDockerAliases -b '/path/to/docker/containers/' -o '/path/to/myAliases'
```

## Example Output 
Appends to `~/.bash_aliases`
```shell
# create-docker-aliases
alias containerA='cd /path/to/docker/containerA'
alias containerB='cd /path/to/docker/containerB'
alias containerC='cd /path/to/docker/containerC'
```
