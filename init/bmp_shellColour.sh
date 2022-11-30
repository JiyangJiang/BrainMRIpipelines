#!/bin/bash

usage () {

echo -e "$(cat << EOM

$(basename $0)


DESCRIPTION :

  This script returns code to change text/background colours. Specify one colour
  feature at a time.


USAGE :

  $(basename $0) [--reset] [--text_black] [--text_bold_black] [--underline_black] [--background_black] [--text_highintensity_black] [--text_bold_highintensity_black] [--background_highintensity_black] ...


COMPULSORY :

  None


OPTIONAL :

  --reset                                   Reset colour.

  --text_<colour>                           Change the following text to <colour>
                                            colour.

  --text_bold_<colour>                      Change the following text to bold font,
                                            and <colour> colour.

  --underline_<colour>                      Add underline with <colour> colour to
                                            the following text.

  --background_<colour>                     Change the background for the following
                                            text to <colour> colour.

  --text_highintensity_<colour>             Change the following text to <colour>
                                            colour with high intensity.

  --text_bold_highintensity_<colour>        Change the following text to <colour>
                                            colour with high intensity, and also
                                            make them bold fonts.

  --background_highintensity_<colour>       Change the background for the following
                                            text to <colour> colour with high
                                            intensity.

  where <colour> can be :

    + black
    + red
    + green
    + yellow
    + blue
    + purple
    + cyan
    + white

  Ref : https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux


DEPENDENCIES :

  None.


EOM
)"

}

for arg in $@
do
	case $arg in

		--reset)
			
			echo '\033[0m'  		# Text Reset
			exit 0
			;;

		--text_black)

			echo '\033[0;30m'		# Black
			exit 0
			;;

		--text_red)

			echo '\033[0;31m'          # Red
			exit 0
			;;

		--text_green)

			echo '\033[0;32m'        # Green
			exit 0
			;;

		--text_yellow)

			echo '\033[0;33m'       # Yellow
			exit 0
			;;

		--text_blue)

			echo '\033[0;34m'         # Blue
			exit 0
			;;

		--text_purple)

			echo '\033[0;35m'       # Purple
			exit 0
			;;

		--text_cyan)

			echo '\033[0;36m'         # Cyan
			exit 0
			;;

		--text_white)

			echo '\033[0;37m'        # White
			exit 0
			;;

		--text_bold_black)

			echo '\033[1;30m'       # Black
			exit 0
			;;

		--text_bold_red)

			echo '\033[1;31m'         # Red
			exit 0
			;;

		--text_bold_green)

			echo '\033[1;32m'       # Green
			exit 0
			;;

		--text_bold_yellow)

			echo '\033[1;33m'      # Yellow
			exit 0
			;;

		--text_bold_blue)

			echo '\033[1;34m'        # Blue
			exit 0
			;;

		--text_bold_purple)

			echo '\033[1;35m'      # Purple
			exit 0
			;;

		--text_bold_cyan)

			echo '\033[1;36m'        # Cyan
			exit 0
			;;

		--text_bold_white)

			echo '\033[1;37m'       # White
			exit 0
			;;

		--underline_black)

			echo '\033[4;30m'       # Black
			exit 0
			;;

		--underline_red)

			echo '\033[4;31m'         # Red
			exit 0
			;;

		--underline_green)

			echo '\033[4;32m'       # Green
			exit 0
			;;

		--underline_yellow)

			echo '\033[4;33m'      # Yellow
			exit 0
			;;

		--underline_blue)

			echo '\033[4;34m'        # Blue
			exit 0
			;;

		--underline_purple)

			echo '\033[4;35m'      # Purple
			exit 0
			;;

		--underline_cyan)

			echo '\033[4;36m'        # Cyan
			exit 0
			;;

		--underline_white)

			echo '\033[4;37m'       # White
			exit 0
			;;

		--background_black)

			echo '\033[40m'       # Black
			exit 0
			;;

		--background_red)

			echo '\033[41m'         # Red
			exit 0
			;;

		--background_green)

			echo '\033[42m'       # Green
			exit 0
			;;

		--background_yellow)

			echo '\033[43m'      # Yellow
			exit 0
			;;

		--background_blue)

			echo '\033[44m'        # Blue
			exit 0
			;;

		--background_purple)

			echo '\033[45m'      # Purple
			exit 0
			;;

		--background_cyan)

			echo '\033[46m'        # Cyan
			exit 0
			;;

		--background_white)

			echo '\033[47m'       # White
			exit 0
			;;

		--text_highintensity_black)

			echo '\033[0;90m'       # Black
			exit 0
			;;

		--text_highintensity_red)

			echo '\033[0;91m'         # Red
			exit 0
			;;

		--text_highintensity_green)

			echo '\033[0;92m'       # Green
			exit 0
			;;

		--text_highintensity_yellow)

			echo '\033[0;93m'      # Yellow
			exit 0
			;;

		--text_highintensity_blue)

			echo '\033[0;94m'        # Blue
			exit 0
			;;

		--text_highintensity_purple)

			echo '\033[0;95m'      # Purple
			exit 0
			;;

		--text_highintensity_cyan)

			echo '\033[0;96m'        # Cyan
			exit 0
			;;

		--text_highintensity_white)

			echo '\033[0;97m'       # White
			exit 0
			;;

		--text_bold_highintensity_black)

			echo '\033[1;90m'      # Black
			exit 0
			;;

		--text_bold_highintensity_red)

			echo '\033[1;91m'        # Red
			exit 0
			;;

		--text_bold_highintensity_green)

			echo '\033[1;92m'      # Green
			exit 0
			;;

		--text_bold_highintensity_yellow)

			echo '\033[1;93m'     # Yellow
			exit 0
			;;

		--text_bold_highintensity_blue)

			echo '\033[1;94m'       # Blue
			exit 0
			;;

		--text_bold_highintensity_purple)

			echo '\033[1;95m'     # Purple
			exit 0
			;;

		--text_bold_highintensity_cyan)

			echo '\033[1;96m'       # Cyan
			exit 0
			;;

		--text_bold_highintensity_white)

			echo '\033[1;97m'      # White
			exit 0
			;;

		--background_highintensity_black)

			echo '\033[0;100m'   # Black
			exit 0
			;;

		--background_highintensity_red)

			echo '\033[0;101m'     # Red
			exit 0
			;;

		--background_highintensity_green)

			echo '\033[0;102m'   # Green
			exit 0
			;;

		--background_highintensity_yellow)

			echo '\033[0;103m'  # Yellow
			exit 0
			;;

		--background_highintensity_blue)

			echo '\033[0;104m'    # Blue
			exit 0
			;;

		--background_highintensity_purple)

			echo '\033[0;105m'  # Purple
			exit 0
			;;

		--background_highintensity_cyan)

			echo '\033[0;106m'    # Cyan
			exit 0
			;;

		--background_highintensity_white)

			echo '\033[0;107m'   # White
			exit 0
			;;

		-h|--help)

			usage
			exit 0
			;;

		-*)

			usage
			exit 1
			;;

	esac
done

