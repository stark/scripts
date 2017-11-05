#!/bin/sh
# usage: pmenu.sh -u -d 2 $DMENU_OPTS
dir=${PASSWORD_STORE_DIR-$HOME/.password-store}
getuser=0
delay=1

while [ -n "$1" ]; do
	case "$1" in
		-u | --username)
			getuser=1
			shift ;;
		-d | --delay)
			shift
			delay=$1 ;;
		*)
			break ;;
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

# override --username when the user input from dmenu is "--u"
# handy if you have set a hotkey to use pmenu with the -u flag all the time,
# but the current login only needs the password (ex- gmail) saving you an extra keybind and keystroke.
[ $getuser -eq 1 ] && echo "$credentials" | grep -q '^--u$' && {
	getuser=0 && credentials=$(list | sort | dmenu "$@")
}

[ -z "$credentials" ] && exit 1

if [ $getuser -eq 1 ]; then
	get_field username | xtype && xkey Tab && \
		get_field password | xtype && xkey Tab && xkey Return
else
	get_field password | xtype
fi

exit $?
