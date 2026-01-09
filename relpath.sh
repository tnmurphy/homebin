export THIS_PATH=$([[ $BASH_SOURCE =~ .*\/.* ]] && ( cd "${BASH_SOURCE%/*}" && echo $PWD; ) || { echo $PWD; })
echo $THIS_PATH
