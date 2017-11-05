#!/bin/sh
# about: personal dmenu front-end for pass
# usage: pmenu.sh -u -d 2 <dmenu options>

# password store directory
dir=${PASSWORD_STORE_DIR-$HOME/.password-store}
# default behavior: do not get the username unless --username is used
getuser=0
# default delay for xdotool keystrokes in milliseconds
delay=1
# see line 50 for explanation
nouserkey=';p'

while [ -n "$1" ]; do
	case "$1" in
		-u | --username)
			getuser=1
			shift ;;
		-d | --delay)
			shift
			delay=$1 ;;
		*) break ;;
	esac
done

list() {
	#       strip extension: .gpg ---------------------------------.
	#       strip file: $dir/.gpg  ----------------------.         |
	#       strip dir:  $dir/       -----.               |         |
	#                                    |               |         |
	#                                    |               |         |
	find $dir -type f -name *.gpg | sed "s#"${dir}/"##g; /^.gpg/d; s/.gpg$//g"
}

get_field() {
	pass show "$credentials" | awk -v field="$1" '$1 ~ field { printf("%s", $2) }'
}

xtype() {
	xdotool type --clearmodifiers --delay $delay --file -
}

xkey() {
	xdotool key  --clearmodifiers $1
}

credentials=$(list | sort | dmenu "$@")

# if the user input from dmenu is $nouserkey, do not get the username even if --username flag is used.
# handy if you have set a hotkey/keybind to use pmenu with the --username flag all the time,
# but the current login only needs the password (ex- gmail) saving you an extra keybind.
[ $getuser -eq 1 ] && echo "$credentials" | grep -q "^${nouserkey}$" && \
	getuser=0 && credentials=$(list | sort | dmenu "$@")

[ -z "$credentials" ] && exit 1

if [ $getuser -eq 1 ]; then
	get_field username | xtype && xkey Tab && \
	get_field password | xtype && xkey Tab && xkey Return
else
	get_field password | xtype
fi

exit $?
