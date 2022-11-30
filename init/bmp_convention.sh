#!/bin/bash

usage () {

echo -e "$(cat << EOM

$(bmp_shellColour.sh --background_white)$(bmp_shellColour.sh --text_bold_black)$(basename $0)$(bmp_shellColour.sh --reset)


$(bmp_shellColour.sh --text_bold_highintensity_yellow)DESCRIPTION :$(bmp_shellColour.sh --reset)

  $(bmp_shellColour.sh --text_highintensity_blue)This script specifies conventions used in writing BrainMRIpipelines scripts, including text output colour in different circumstances.$(bmp_shellColour.sh --reset)


$(bmp_shellColour.sh --text_bold_highintensity_yellow)USAGE :$(bmp_shellColour.sh --reset)



$(bmp_shellColour.sh --text_bold_highintensity_yellow)COMPULSORY :$(bmp_shellColour.sh --reset)

  $(bmp_shellColour.sh --text_highintensity_blue)None.$(bmp_shellColour.sh --reset)


$(bmp_shellColour.sh --text_bold_highintensity_yellow)OPTIONAL :$(bmp_shellColour.sh --reset)
$(bmp_shellColour.sh --text_highintensity_blue)

  $(bmp_shellColour.sh --text_green)--usage_text$(bmp_shellColour.sh --text_highintensity_blue)                                              Text in helper function is displayed 
                                                            in high-intensity blue.

  $(bmp_shellColour.sh --text_green)--usage_section_title$(bmp_shellColour.sh --text_highintensity_blue)                                     $(bmp_shellColour.sh --text_bold_highintensity_yellow)Section titles $(bmp_shellColour.sh --text_highintensity_blue)for a helper function are
                                                            displayed in gold yellow.

  $(bmp_shellColour.sh --text_green)--usage_compulsory$(bmp_shellColour.sh --text_highintensity_blue)                                        $(bmp_shellColour.sh --text_bold_green)Compulsory arguments$(bmp_shellColour.sh --text_highintensity_blue) for a helper function
                                                            are displayed in bold green.

  $(bmp_shellColour.sh --text_green)--usage_optional$(bmp_shellColour.sh --text_highintensity_blue)                                          $(bmp_shellColour.sh --text_green)Optional arguments $(bmp_shellColour.sh --text_highintensity_blue)for a helper function
                                                            are displayed in green.

  $(bmp_shellColour.sh --text_green)--text_normal$(bmp_shellColour.sh --text_highintensity_blue)                                             $(bmp_shellColour.sh --text_green)Normal text$(bmp_shellColour.sh --text_highintensity_blue) outputs are displayed in
                                                            green.

  $(bmp_shellColour.sh --text_green)--text_warning$(bmp_shellColour.sh --text_highintensity_blue)                                            $(bmp_shellColour.sh --text_bold_highintensity_yellow)Warning messages$(bmp_shellColour.sh --text_highintensity_blue) are displayed in
                                                            high-intensity bold yellow.

  $(bmp_shellColour.sh --text_green)--text_error$(bmp_shellColour.sh --text_highintensity_blue)                                              $(bmp_shellColour.sh --text_bold_highintensity_red)Error messages$(bmp_shellColour.sh --text_highintensity_blue) are displayed in
                                                            high-intensity bold red.

  $(bmp_shellColour.sh --text_green)--text_highlight$(bmp_shellColour.sh --text_highintensity_blue)                                          $(bmp_shellColour.sh --text_bold_highintensity_blue)Highlighted normal text$(bmp_shellColour.sh --text_highintensity_blue) is displayed
                                                            in high-intensity bold blue.

  $(bmp_shellColour.sh --text_green)--text_path$(bmp_shellColour.sh --text_highintensity_blue)                                               $(bmp_shellColour.sh --text_highintensity_purple)Paths in normal text$(bmp_shellColour.sh --text_highintensity_blue) are displayed in
                                                            high-intensity purple.

  $(bmp_shellColour.sh --text_green)--text_code$(bmp_shellColour.sh --text_highintensity_blue)                                               $(bmp_shellColour.sh --text_highintensity_cyan)Code in normal text$(bmp_shellColour.sh --text_highintensity_blue) is displayed in
                                                            high-intensity cyan.

  $(bmp_shellColour.sh --text_green)--script_name$(bmp_shellColour.sh --text_highintensity_blue)                                             $(bmp_shellColour.sh --text_bold_black)$(bmp_shellColour.sh --background_white)Script name in helper function$(bmp_shellColour.sh --text_highintensity_blue) is displayed
                                                            in bold black on white.

  -h, --help                                                Display this message.


$(bmp_shellColour.sh --reset)



EOM
)"
}

for arg in $@
do

	case $arg in

		--usage_text)

			bmp_shellColour.sh --text_highintensity_blue
			exit 0
			;;

		--usage_section_title)

			bmp_shellColour.sh --text_bold_highintensity_yellow
			exit 0
			;;

		--usage_compulsory)

			bmp_shellColour.sh --text_bold_green
			exit 0
			;;

		--usage_optional)

			bmp_shellColour.sh --text_green
			exit 0
			;;

		--text_normal)

			bmp_shellColour.sh --text_green
			exit 0
			;;

		--text_warning)

			bmp_shellColour.sh --text_bold_highintensity_yellow
			exit 0
			;;

		--text_error)

			bmp_shellColour.sh --text_bold_highintensity_red
			exit 0
			;;

		--text_highlight)

			bmp_shellColour.sh --text_bold_highintensity_blue
			exit 0
			;;

		--text_path)

			bmp_shellColour.sh --text_highintensity_purple
			exit 0
			;;

		--text_code)

			bmp_shellColour.sh --text_highintensity_cyan
			exit 0
			;;

		--script_name)
			echo -n "$(bmp_shellColour.sh --text_bold_black)$(bmp_shellColour.sh --background_white)"
			echo
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
