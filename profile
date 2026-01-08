# bash profile utiltites
# Timothy N Murphy <tnmurphy@gmail.com>
# Public Domain

# join a list of tokens with some intermediate string
string_join() {
    local join=$1; shift
    local result=$1; shift
    for p in "$@"; do
        result="${result}${join}${p}"
    done
    echo -n "$result"
    set +x
}

# Add and remove paths from the dynamic library path: needs
# adapting for MacOS.
# Not good if there are spaces. 
ld_add() {
    if [[ -v DYLD_LIBRARY_PATH ]]; then
        export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$(string_join ':' $@)
    else
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(string_join ':' $@)
    fi
}

ld_prepend() {
    if [[ -v DYLD_LIBRARY_PATH ]]; then
        export DYLD_LIBRARY_PATH=$(string_join ':' $@):$DYLD_LIBRARY_PATH
    else
        export LD_LIBRARY_PATH=$(string_join ':' $@):$LD_LIBRARY_PATH
    fi
}


# save the current PATH into an array so that we can revert to it if we
# mess it up.
declare -a __path_stack # don't modify!
path_stack_push() {
    pathstack[$(( 1 + ${#pathstack[@]}))]="$PATH"
}

path_stack_pop() {
    local stack_size=${#pathstack[@]}
   
    if [[ stack_size > 0 ]]; then 
        new_path = pathstack[$stack_size]
        unset pathstack[$stack_size]
        export PATH="$new_path"
    fi
}

path_add() {
    path_stack_push
    export PATH=$PATH:$(string_join ':' $@)
}

path_prepend() {
    path_stack_push
    PATH=$(string_join ':' "$@"):$PATH
    export PATH
}

# Remove elements from the path. Takes a grep regexp as input
path_remove() {
    local item=$1; shift
    local new_path="$(echo -e "${PATH//:/\n}" |  /usr/bin/grep -v \"$item\")"
    path_stack_push
    export PATH="${new_path// /;}" 
}

vgrep() {
    rg --color=always "$@" | less -R
}

vdiff() {
local objects=$1; shift
git -c color.ui=always diff "${objects}" | less -REX
}

lint() {
    local hvca=~/hvpki/src/globalsign/hvpki/hvca/
    rg ":=" $hvca --glob='*.go' | rg -v '(codegenerated.go)|(if .*:=)|(for .*:=)|(case .*:=)|(:= [a-zA-Z0-9._]+\()|(::= *(SEQUENCE|CHOICE)|( *//)|(:= .*\{ *$))'
}


do_with_log() {
  # arguments are $1 $2 $3 $4 $5 . . . . 
  local whattodo=$1; shift
  # "$@" is all the (unshifted) arguments so you can pass them onwards:
  ${whattodo} "$@" 
   
  if [ "$?" -gt 0 ]; then
      echo "ERROR: $whattodo failed"
  else
      echo "OK: $whattodo"
  fi
  return 1 
}


testpostgres() {
	echo "Don't forget to use:  "
	echo "    docker-compose down # get rid of all the container temporary state."
	echo "    docker-compose up -d postgres"
	TEST_POSTGRES_ENDPOINT=postgres://postgres:example@localhost:5432/ra TEST_POSTGRES_TABLE=test go test -timeout 30m globalsign/hvpki/hvca/ra/postgres -tags=integration -parallel=1
}


vrg() {
rg --color always "$@"
}


# cat an encrypted file - convenience method
decf() {
	local file="$1"; shift
	openssl enc -d  -aes-256-cbc -pbkdf2  -in "$file"
}

# encrypted a file - convenience method
encf() {
	local file="$1"; shift
	openssl enc  -aes-256-cbc -pbkdf2  -in "$file"
}

# running maven for mule builds


# https://docs.mulesoft.com/mule-runtime/4.2/secure-configuration-properties
mule-secure-props-decrypt()
{
local method=
local operation=decrypt
local algorithm="Blowfish"
local mode=q
local key=
local value=

java -cp ~/bin/secure-properties-tool.jar com.mulesoft.tools.SecurePropertiesTool \
  $method \
  $operation \
  $algorithm \
  $mode \
  $key \
  $value 
}

jv() { jq . $1 -C | less -R; }


termtitle() {
    local title="$*"

    if [[ -z $title ]]; then
        local dir="$PWD"
        while [[ ! -d $dir/.git  && $dir != '/' ]]; do
            dir=$(dirname "$dir")
        done
        if [[ $dir == '/' ]]; then
            title=$(basename "$PWD")
        else
            title=$(basename "$dir")
        fi
    fi
    echo -ne "\033]0;"$title"\007"
}


viml ()
{
    local line=$1;
    shift;
    local VIM=gvim;
    if [[ -z $DISPLAY ]]; then
        VIM=vim;
    fi;
    if [[ $line =~ ^([^:]*):([0-9]+)(:[0-9]:)?.*$ ]]; then
        $VIM "${BASH_REMATCH[1]}" "+${BASH_REMATCH[2]}" $@;
    else
        if [[ $line =~ ^.*File\ *\"(.*)\",\ *line.([0-9]+).*$ ]]; then
            $VIM "${BASH_REMATCH[1]}" "+${BASH_REMATCH[2]}" $@;
        else
            $VIM $line $@;
        fi;
    fi
}


###############################################################
# ACTIONS
#
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

export PS1="\u@\h:\w "

shopt -s checkwinsize

. ~/bin/profile.d/pythonation
