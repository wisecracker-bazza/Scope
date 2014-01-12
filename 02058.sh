#!/bin/bash
#
# AudioScope.sh
#
# Public Domain, 2013-2014, B.Walker, G0LCU.
#
# IMPORTANT!!! This code assumes that it is saved as AudioScope.sh inside your _home_ drawer...
# Set the permissions to YOUR requirements and launch the code using the following:-
#
# Your Prompt> ./AudioScope.sh<CR>
#
# At this point I will include and say thank you to "Corona688", a member of http://www.unix.com for his input.
# Also to "Don Cragun" and others on the same site for their input too.
# Many thanks also go to the guys who have helped with this on http://www.linuxformat.com for all your input too.
# Also to an anonymous person, nicknamed Zoonie, who has given this project some serious hammering...
#
# Tested in SOX mode on this Macbook Pro 13 inch, OSX 10.7.5 with the SOX sinewave generator enabled.
# Note that the MINIMUM SOX version is 14.4.0, and can be found here at http://sox.sourceforge.net ...
# Tested in /dev/dsp mode on an aging HP notebook running Debian 6.0.x with the /dev/dsp sinewave generator enabled.
# Tested in /dev/dsp mode on an Acer Aspire One netbook booting from a USB stick running PCLinuxOS 2009; also with
# the /dev/dsp sinewave generator enabled.
# Tested on all three in DEMO mode.
#
# The first simple circuit at the end of this script.
# The second simple circuit at the end of this script.
#
# The latest UNOFFICIAL release will be here:-
# http://wisecracker.host22.com/public/AudioScope.sh
#
# Relevant pointers to help:-
# http://wisecracker.host22.com/public/AudioScope_Manual.readme
# http://wisecracker.host22.com/public/cal_draw.jpg
# http://wisecracker.host22.com/public/cal_plot.jpg
# http://wisecracker.host22.com/public/mic_ear1.jpg
# http://wisecracker.host22.com/public/mic_ear2.jpg
# http://wisecracker.host22.com/public/mic_ear3.jpg
# http://wisecracker.host22.com/public/mic_ear4.jpg
# http://wisecracker.host22.com/public/AudioScope_SOX_OSX.jpg
# http://wisecracker.host22.com/public/AudioScope_DSP_PCLOS.jpg
# http://wisecracker.host22.com/public/dc_tester_top.jpg
# http://wisecracker.host22.com/public/dc_tester_bottom.jpg
# http://wisecracker.host22.com/public/vert_amp_tester.jpg
# http://wisecracker.host22.com/public/vert_cal_top.jpg
# http://wisecracker.host22.com/public/vert_cal_bottom.jpg
# More photos to follow.
#
# The latest OFFICIAL release will ALWAYS be here:-
# http://www.unix.com/shell-programming-scripting/212939-start-simple-audio-scope-shell-script.html
#
# NOTE TO SELF:- Remove "/tmp" and replace with "~" when ready, AND, "/tmp" is automatically cleared on this machine per reboot.

# #########################################################
# Variables in use.
ifs_str="$IFS"
ver="0.20.58"
version=" \$VER: AudioScope.sh_Version_"$ver"_2013-2014_Public_Domain_B.Walker_G0LCU."
setup="$version"
blankline="                                                                            "
# Default first time run capture mode, 0 = DEMO.
demo=0
capturemode="DEMO"
# Change this absolute address for your location of "sox" _IF_ you know where it is...
capturepath="/Users/barrywalker/Downloads/sox-14.4.0/sox"
device=$capturepath
# Draw proceedure mode, 0 = OFF.
drawline=0
# Pseudo-continuous data file saving.
savefile="0000000000"
save_string="OFF"
hold=1
status=1
laststatus=0
foreground=37
# "count", "number", "char" are reusable, throw away variables.
count=0
number=0
char="?"
# Vertical components.
# vert_one and vert_two are the vertical plotting points for the draw() function.
vert_one=2
vert_two=2
vert=12
vert_shift=2
vshift="?"
vert_array=""
vert_draw=9
vertical="Uncalibrated (m)V/DIV"
# Display setup...
graticule="Public Domain, 2013-2014, B.Walker, G0LCU."
# Keyboard components.
kbinput="?"
tbinput=1
# "str_len" is a reusable variable IF required.
str_len=1
# "grab" is used for internal pseudo-synchronisation.
grab=0
# "sound_card_zero_offset" can only be manually changed in the AudioScope.config file, OR, here.
sound_card_zero_offset=-2
# Zoom facility default status line.
zoom_facility="OFF"
zoom="Lowest sensitivity zoom/gain, default condition..."
# Horizontal components.
horiz=9
# Scan retraces.
scan=1
scanloops=1
# Timebase variable components.
timebase="Uncalibrated (m)S/DIV"
subscript=0
# "scan_start" is from 0 to ( length of file - 64 )...
scan_start=0
# "scan_jump" is from 1 to ( ( ( scan_end - scan_start ) / 64) + 1 )...
scan_jump=1
# "scan_end" is at least 64 bytes in from the absolute file end.
scan_end=47935
# Synchronisation variables.
# synchronise switches the syncchroisation ON or OFF.
synchronise="OFF"
# sync_point is any value between 15 and 240 of the REAL grab(s).
sync_point=128
sync_input="?"
# Frequency counter AC and DC condition variables.
coupling="AC"
wave_form=0
# "freq" will always be reset to "2000" on program exit.
freq=2000
freq_array=""
data="\\x80\\x26\\x00\\x26\\x7F\\xD9\\xFF\\xD9"
# Generate an 65536 byte raw 1KHz sinewave file from "data".
> /tmp/sinewave.raw
chmod 644 /tmp/sinewave.raw
for wave_form in {0..8191}
do
        printf "$data" >> /tmp/sinewave.raw
done
data="\\x00\\x00\\xFF\\xFF\\x00\\x00\\xFF\\xFF"
# Generate an 8000 byte raw 2000Hz squarewave file for DEMO mode from "data".
> /tmp/squarewave.raw
chmod 644 /tmp/squarewave.raw
for wave_form in {0..999}
do
        printf "$data" >> /tmp/squarewave.raw
done
# Generate a first copy of "waveform.raw" for this script.
cp /tmp/squarewave.raw /tmp/waveform.raw
chmod 644 /tmp/waveform.raw
# Create a zero sized "symmetricalwave.raw" file.
> /tmp/symmetricalwave.raw
chmod 644 /tmp/symmetricalwave.raw 

# #########################################################
# FOR SOund eXchance USERS ONLY!!!        TESTED!!!
# The lines below, from ">" to "xterm", will generate a new shell script and execute it in a new xterm terminal...
# Just EDIT out the comments and then EDIT the line pointing to the correct </Users/barrywalker/Downloads/sox-14.4.0/> to use it.
# It assumes that you have SoX installed. When this script is run it generates a 1KHz sinewave in a separate window
# that lasts for 8 seconds and then re-runs. To quit this script and close the window just press and hold Ctrl-C until the
# program exits. This generator will be needed for the calibration of some timebase ranges.
#
#> /tmp/1KHz-Test.sh
#chmod 744 /tmp/1KHz-Test.sh
#printf '#!/bin/bash\n' >> /tmp/1KHz-Test.sh
#printf 'printf "\x1B]0;1KHz Sinewave Generator.\x07"\n' >> /tmp/1KHz-Test.sh
#printf 'while true\n' >> /tmp/1KHz-Test.sh
#printf 'do\n' >> /tmp/1KHz-Test.sh
#printf '        clear\n' >> /tmp/1KHz-Test.sh
#printf '        printf "\nPRESS AND HOLD Ctrl-C UNTIL EXITED...\n"\n' >> /tmp/1KHz-Test.sh
#printf '        /Users/barrywalker/Downloads/sox-14.4.0/play -b 8 -r 8000 -e unsigned-integer /tmp/sinewave.raw\n' >> /tmp/1KHz-Test.sh
#printf 'done\n' >> /tmp/1KHz-Test.sh
#sleep 1
#xterm -e /tmp/1KHz-Test.sh &

# #########################################################
# FOR /dev/dsp USERS ONLY!!!           TESTED!!!
# The lines below, from ">" to "xterm", will generate a new shell script and execute it in a new xterm terminal...
# Just EDIT out the comments to use it.
# It assumes that you have /dev/dsp _installed_. When this script is run it generates a 1KHz sinewave in a separate window
# that lasts for 8 seconds and then re-runs. To quit this script and close the window just press and hold Ctrl-C until the
# program exits. This generator will be needed for the calibration of some timebase ranges.
#
#> /tmp/1KHz-Test.sh
#chmod 744 /tmp/1KHz-Test.sh
#printf '#!/bin/bash\n' >> /tmp/1KHz-Test.sh
#printf 'printf "\x1B]0;1KHz Sinewave Generator.\x07"\n' >> /tmp/1KHz-Test.sh
#printf 'while true\n' >> /tmp/1KHz-Test.sh
#printf 'do\n' >> /tmp/1KHz-Test.sh
#printf '        clear\n' >> /tmp/1KHz-Test.sh
#printf '        printf "\nPRESS AND HOLD Ctrl-C UNTIL EXITED...\n"\n' >> /tmp/1KHz-Test.sh
#printf '        cat /tmp/sinewave.raw > /dev/dsp\n' >> /tmp/1KHz-Test.sh
#printf 'done\n' >> /tmp/1KHz-Test.sh
#sleep 1
#xterm -e /tmp/1KHz-Test.sh &

# #########################################################
# This section is for future usage only at this point.
# It contains the running scripts for vertical calibration
# For *NIX and Linux flavours plus Windows XP, Vista and Windows 7.
# #########################################################
# FOR Windows SOund eXchange USERS ONLY!!!       TESTED !!!
# NOTE:- The code itself DOES work but generating it on the fly has NOT been tested yet.
# Windows batch file square wave generator using SOund eXchange, SOX.
# Just TRANSFER the file /tmp/VERT_BAT.BAT to a Windows machine and run from Windows Command Prompt.
# *** You WILL need to change the absolute path on the last line for your SOX installation. ***
# It is in uncommented mode so that anyone interested can experiment _immediately_.
> /tmp/VERT_BAT.BAT
echo -e -n '@ECHO OFF\r\n' >> /tmp/VERT_BAT.BAT
echo -e -n 'CLS\r\n' >> /tmp/VERT_BAT.BAT
echo -e -n 'SET "rawfile=\xFE\xFE\xFE\xFE\x01\x01\x01\x01"\r\n' >> /tmp/VERT_BAT.BAT
echo -e -n 'ECHO | SET /P="%rawfile%" > %TEMP%.\\SQ-WAVE.RAW\r\n' >> /tmp/VERT_BAT.BAT
echo -e -n 'FOR /L %%n IN (1,1,13) DO TYPE %TEMP%.\\SQ-WAVE.RAW >> %TEMP%.\\SQ-WAVE.RAW\r\n' >> /tmp/VERT_BAT.BAT
echo -e -n 'C:\\PROGRA~1\\SOX-14-4-1\\SOX -b 8 -r 8000 -e unsigned-integer -c 1 %TEMP%.\\SQ-WAVE.RAW -d\r\n' >> /tmp/VERT_BAT.BAT

# #########################################################
# FOR SOund eXchance USERS ONLY!!!        TESTED!!!
# The lines below, from ">" to the last "printf", will generate a new shell script...
# Just EDIT out the comments and then EDIT the line pointing to the correct </full/path/to/sox/> to use it.
# TRANSFER this file to another remote machine that has SOund eXchange, SOX, installed.
# It assumes that you have SoX installed. When this script is run it generates a 1KHz squarewave on a remote computer
# that lasts for 8 seconds. Just press ENTER when this window is active and it will repeat again.
# To quit this script just press Ctrl-C. This generator will be needed for the vertical calibration.
# Don't forget to chmod "VERT_SOX.sh" when copied onto the remote machine.
#> /tmp/VERT_SOX.sh
#printf '#!/bin/bash\n' >> /tmp/VERT_SOX.sh
#printf '> /tmp/sinewave.raw\n' >> /tmp/VERT_SOX.sh
#printf 'data="\\\\xFF\\\\xFF\\\\xFF\\\\xFF\\\\x00\\\\x00\\\\x00\\\\x00"\n' >> /tmp/VERT_SOX.sh
#printf 'for waveform in {0..8191}\n' >> /tmp/VERT_SOX.sh
#printf 'do\n' >> /tmp/VERT_SOX.sh
#printf '        printf "$data" >> /tmp/sinewave.raw\n' >> /tmp/VERT_SOX.sh
#printf 'done\n' >> /tmp/VERT_SOX.sh
#printf 'while true\n' >> /tmp/VERT_SOX.sh
#printf 'do\n' >> /tmp/VERT_SOX.sh
#printf '        /full/path/to/sox/play -b 8 -r 8000 -e unsigned-integer /tmp/sinewave.raw\n' >> /tmp/VERT_SOX.sh
#printf '        read -p "Press ENTER to rerun OR Ctrl-C to quit:- " -e kbinput\n' >> /tmp/VERT_SOX.sh
#printf 'done\n' >> /tmp/VERT_SOX.sh

# #########################################################
# FOR /dev/dsp USERS ONLY!!!           TESTED!!!
# The lines below, from ">" to the last "printf", will generate a new shell script...
# Just EDIT out the comments to use it. TRANSFER this file to another machine that has the /dev/dsp device.
# It assumes that you have /dev/dsp _installed_. When this script is run it generates a 1KHz squarewave on a remote computer
# that lasts for 8 seconds. Just press ENTER when this window is active and it will repeat again.
# To quit this script just press Ctrl-C. This generator will be needed for the vertical calibration.
# Don't forget to chmod "VERT_DSP.sh" when copied onto the remote machine.
#> /tmp/VERT_DSP.sh
#printf '#!/bin/bash\n' >> /tmp/VERT_DSP.sh
#printf '> /tmp/sinewave.raw\n' >> /tmp/VERT_DSP.sh
#printf 'data="\\\\xFF\\\\xFF\\\\xFF\\\\xFF\\\\x00\\\\x00\\\\x00\\\\x00"\n' >> /tmp/1KHz-Test.sh
#printf 'for waveform in {0..8191}\n' >> /tmp/VERT_DSP.sh
#printf 'do\n' >> /tmp/VERT_DSP.sh
#printf '        printf "$data" >> /tmp/sinewave.raw\n' >> /tmp/VERT_DSP.sh
#printf 'done\n' >> /tmp/VERT_DSP.sh
#printf 'while true\n' >> /tmp/VERT_DSP.sh
#printf 'do\n' >> /tmp/VERT_DSP.sh
#printf '        cat /tmp/sinewave.raw > /dev/dsp\n' >> /tmp/VERT_DSP.sh
#printf '        read -p "Press ENTER to rerun OR Ctrl-C to quit:- " -e kbinput\n' >> /tmp/VERT_DSP.sh
#printf 'done\n' >> /tmp/VERT_DSP.sh

# #########################################################
# Add the program tilte and version to the Terminal title bar...
# This may NOT work in every Terminal so just comment it out if it doesn't.
printf "\x1B]0;Shell AudioScope Version "$ver".\x07"

# #########################################################
# A clear screen function that does NOT use "clear".
clrscn()
{
	printf "\x1B[2J\x1B[H"
}
# Use it to set up screen.
printf "\x1B[H\x1B[0;36;44m"
clrscn

# #########################################################
# Generate a config file and temporarily store inside /tmp
if [ -f /tmp/AudioScope.config ]
then
	. /tmp/AudioScope.config
else
	user_config
fi
user_config()
{
	> /tmp/AudioScope.config
	chmod 644 /tmp/AudioScope.config
	printf "demo=$demo\n" >> /tmp/AudioScope.config
	printf "drawline=$drawline\n" >> /tmp/AudioScope.config
	printf "sound_card_zero_offset=$sound_card_zero_offset\n" >> /tmp/AudioScope.config
	printf "scan_start=$scan_start\n" >> /tmp/AudioScope.config
	printf "scan_jump=$scan_jump\n" >> /tmp/AudioScope.config
	printf "scan_end=$scan_end\n" >> /tmp/AudioScope.config
	printf "setup='$setup'\n" >> /tmp/AudioScope.config
	printf "save_string='$save_string'\n" >> /tmp/AudioScope.config
	printf "foreground=$foreground\n" >> /tmp/AudioScope.config
	printf "timebase='$timebase'\n" >> /tmp/AudioScope.config
	printf "vertical='$vertical'\n" >> /tmp/AudioScope.config
	printf "coupling='$coupling'\n" >> /tmp/AudioScope.config
	printf "capturemode='$capturemode'\n" >> /tmp/AudioScope.config
	printf "capturepath='$capturepath'\n" >> /tmp/AudioScope.config
}

# #########################################################
# Screen display setup function.
display()
{
	# Set foreground and background graticule colours and foreground and background other window colours.
	printf "\x1B[H\x1B[0;36;44m"
	graticule="       +-------+-------+-------+---[\x1B[1;37;44mDISPLAY\x1B[0;36;44m]---+-------+-------+--------+       \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        | \x1B[1;31;44mMAX\x1B[0;36;44m   \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        |       \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        |       \n"
	graticule=$graticule"     \x1B[1;31;44m+\x1B[0;36;44m +-------+-------+-------+-------+-------+-------+-------+--------+       \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        |       \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        |       \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        |       \n"
	graticule=$graticule"     \x1B[1;32;44m0\x1B[0;36;44m +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+--+ \x1B[1;32;44mREF\x1B[0;36;44m   \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        |       \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        |       \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        |       \n"
	graticule=$graticule"     \x1B[1;30;44m-\x1B[0;36;44m +-------+-------+-------+-------+-------+-------+-------+--------+       \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        |       \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        |       \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        |       \n"
	graticule=$graticule"       |       |       |       |       +       |       |       |        | \x1B[1;30;44mMIN\x1B[0;36;44m   \n"
	graticule=$graticule"       +-------+-------+-------+-------+-------+-------+-------+--------+       \n"
	graticule=$graticule" \x1B[0;37;40m+-----------------------------[\x1B[1;33;40mCOMMAND  WINDOW\x1B[0;37;40m]------------------------------+\x1B[0;37;44m \n"
	graticule=$graticule" \x1B[0;37;40m| COMMAND:-                                                                  |\x1B[0;37;44m \n"
	graticule=$graticule" \x1B[0;37;40m+------------------------------[\x1B[1;35;40mSTATUS WINDOW\x1B[0;37;40m]-------------------------------+\x1B[0;37;44m \n"
	graticule=$graticule" \x1B[0;37;40m| \x1B[0;$foreground;40mStopped...\x1B[0;37;40m                                                                 |\x1B[0;37;44m \n"
	graticule=$graticule" \x1B[0;37;40m|$setup|\x1B[0;37;44m \n"
	graticule=$graticule" \x1B[0;37;40m+----------------------------------------------------------------------------+\x1B[0;37;44m "
	printf "$graticule"
	# Set the colours for plotting.
	printf "\x1B[1;37;44m"
}

# #########################################################
# Pick which method to capture, (and store), the waveform on the fly.
waveform()
{
	> /tmp/waveform.raw
	chmod 644 /tmp/waveform.raw
	# Demo mode, generate 48000 bytes of random data.
	if [ $demo -eq 0 ]
	then
		# Use "sleep" to simulate a 1 second burst.
		sleep 1
		# "/dev/urandom is now used instead of RANDOM as it is MUCH faster.
		dd if=/dev/urandom of=/tmp/waveform.raw bs=48000 count=1 > /dev/null 2>&1
	fi
	# Using the aging(/old) /dev/dsp device, mono, 8 bits per sample and 8KHz sampling rate, 8000 unsigned-integer bytes of data...
	# Now tested on PCLinuxOS 2009 and Debian 6.0.x.
	if [ $demo -eq 1 ]
	then
		# This uses the oss-compat installation from your distro's repository...
		dd if=/dev/dsp of=/tmp/waveform.raw bs=8000 count=1 > /dev/null 2>&1
	fi
	# The main means of obtaining the unsigned-integer data, using SoX, (Sound eXcahnge)...
	if [ $demo -eq 2 ]
	then
		# The absolute address will be found when running the code, but, it WILL take a LONG time to find...
		$capturepath -q -V0 -d -t raw -r 48000 -b 8 -c 1 -e unsigned-integer -> /tmp/waveform.raw trim 0 00:01
	fi
}

# #########################################################
# Plot the points inside the window...
plot()
{
	subscript=$scan_start
	vert_array=""
	for horiz in {9..72}
	do
		vert=`hexdump -n1 -s$subscript -v -e '1/1 "%u"' /tmp/waveform.raw`
		# Add a small offset to give a straight line with zero input allowing for mid-point sound card bit error.
		vert=$[ ( $vert + $sound_card_zero_offset ) ]
		if [ $vert -le 0 ]
		then
			vert=0
		fi
		if [ $vert -ge 255 ]
		then
			vert=255
		fi
		# Pseudo-vertical shift of + or - 1 vertical division maximum.
		vert=$[ ( ( $vert / 16 ) + $vert_shift ) ]
		# Ensure the plot is NOT out of bounds after moving the shift position.
		if [ $vert -le 2 ]
		then
			vert=2
		fi
		if [ $vert -ge 17 ]
		then
			vert=17
		fi
		subscript=$[ ( $subscript + $scan_jump ) ]
		# Generate a simple space delimited 64 sample array.
		vert_array="$vert_array$vert "
		printf "\x1B[1;37;44m\x1B["$vert";"$horiz"f*"
	done
	# Set end of plot to COMMAND window.
	printf "\x1B[0;37;40m\x1B[20;14f"
}

# #########################################################
# This function connects up the plotted points.
# Defaults to OFF on the very first time run and must be manually enabled if needed.
draw()
{
	statusline
	IFS=" "
	subscript=0
	number=0
	vert_one=2
	vert_two=2
	vert_draw=( $vert_array )
	for horiz in {9..71}
	do
		# Obtain the two vertical components.
		vert_one=${vert_draw[ $subscript ]}
		subscript=$[ ( $subscript + 1 ) ]
		vert_two=${vert_draw[ $subscript ]}
		# Now subtract them and obtain an absolute value - ALWAYS 0 to positive...
		number=$[ ( $vert_two - $vert_one ) ]
		number=${number#-}
		# This decision section _is_ needed.
		if [ $number -le 1 ]
		then
			: # NOP. Do nothing...
		fi
		# This section does the drawing...
		if [ $number -ge 2 ]
		then
			if [ $vert_one -gt $vert_two ]
			then
				vert_one=$[ ( $vert_one - 1 ) ]
				while [ $vert_one -gt $vert_two ]
				do
					printf "\x1B[1;37;44m\x1B["$vert_one";"$horiz"f*"
					vert_one=$[ $vert_one - 1 ]
				done
			fi
			if [ $vert_two -gt $vert_one ]
			then
				vert_one=$[ ( $vert_one + 1 ) ]
				while [ $vert_one -lt $vert_two ]
				do
					printf "\x1B[1;37;44m\x1B["$vert_one";"$horiz"f*"
					vert_one=$[ $vert_one + 1 ]
				done
			fi
		fi
	IFS="$ifs_str"
	done
	# Set end of plot to COMMAND window.
	printf "\x1B[0;37;40m\x1B[20;14f"
}

# #########################################################
# This is the information line _parser_...
statusline()
{
	printf "\x1B[0;37;40m\x1B[22;3f$blankline\x1B[22;4f"
	if [ $status -eq 0 ]
	then
		printf "\x1B[0;$foreground;40mStopped...\x1B[0;37;40m"
	fi
	if [ $status -eq 1 ]
	then
		printf "Running \x1B[0;32;40m$scan\x1B[0;37;40m of \x1B[0;32;40m$scanloops\x1B[0;37;40m scan(s)..."
	fi
	if [ $status -eq 2 ]
	then
		printf "\x1B[0;33;40mRunning in single shot storage mode...\x1B[0;37;40m"
	fi
	if [ $status -eq 3 ]
	then
		printf "\x1B[0;33;40mDrawing the scan...\x1B[0;37;40m"
	fi
	if [ $status -eq 4 ]
	then
		printf "Synchroniastion set to \x1B[0;32;40m$sync_point\x1B[0;37;40m$synchronise..."
	fi
	if [ $status -eq 5 ]
	then
		printf "\x1B[1;31;40mCAUTION, AUTO-SAVING FACILITY ENABLED!!!\x1B[0;37;40m"
	fi
	if [ $status -eq 6 ]
	then
		printf "\x1B[0;33;40m$zoom\x1B[0;37;40m"
	fi
	if [ $status -eq 7 ]
	then
		printf "Horizontal shift, scan start at position \x1B[0;32;40m$scan_start\x1B[0;37;40m..."
	fi
	if [ $status -eq 8 ]
	then
		printf "Symmetrical waveform frequency is \x1B[0;32;40m"$freq"\x1B[0;37;40m Hz..."
	fi
	if [ $status -eq 9 ]
	then
		printf "X=\x1B[0;33;40m166.7uS/DIV\x1B[037;40m for DEMO or SOX, \x1B[0;33;40m1mS/DIV\x1B[037;40m for DSP."
	fi
	if [ $status -eq 254 ]
	then
		status=1
		printf "\x1B[23;3f$version\x1B[20;14f"
		sleep 2
	fi
	# Set end of plot to COMMAND window.
	printf "\x1B[0;37;40m\x1B[20;14f"
}

# #########################################################
# All keyboard commands appear here when the scanning stops; there will be lots of them to make subtle changes...
# I have forced the use of UPPERCASE for the vast majority of the commands, so be aware!
# Incorrect commands are ignored and just reuns the scan and returns back to the COMMAND mode...
kbcommands()
{
	IFS="$ifs_str"
	status=1
	scan=1
	read -p "Press <CR> to (re)run, HELP or QUIT<CR> " -e kbinput
	printf "\x1B[0;37;40m\x1B[20;14f                                                                 \x1B[20;14f"
	# Rerun scans captured or stored.
	if [ "$kbinput" == "" ]
	then
		status=1
		statusline
	fi
	# Run scans in captured, (REAL scan), mode only.
	if [ "$kbinput" == "RUN" ]
	then
		status=1
		hold=1
		statusline
	fi
	# Swtich off capture mode and rerun one storage shot only, this disables the DRAW command.
	# Use DRAW to re-enable again. This is deliberate for slow machines...
	if [ "$kbinput" == "HOLD" ]
	then
		drawline=0
		status=2
		hold=0
		scanloops=1
		statusline
		sleep 1
	fi
	# Quit the program.
	if [ "$kbinput" == "QUIT" ]
	then
		status=255
		break
	fi
	# Display the _online_ HELP file in default terminal colours.
	if [ "$kbinput" == "HELP" ]
	then
		status=0
		scanloops=1
		hold=0
		commandhelp
	fi
	# Enable DEMO pseudo-capture mode, default, but with 10 sweeps...
	if [ "$kbinput" == "DEMO" ]
	then
		status=1
		scan_start=0
		scan_jump=1
		scanloops=10
		scan_end=47935
		hold=1
		demo=0
		capturemode="DEMO"
		statusline
		sleep 1
	fi
	# Enable /dev/dsp capture mode, if your Linux flavour does NOT have it, install oss-compat from the distro's repository.
	# This is the mode used to test on Debian 6.0.x and now PCLinuxOS 2009...
	if [ "$kbinput" == "DSP" ]
	then
		capturepath=`ls /dev/dsp 2>/dev/null`		
		status=1
		scan_start=0
		scan_jump=1
		scanloops=1
		scan_end=7935
		hold=1
		demo=1
		capturemode="DSP"
		if [ "$capturepath" == "" ]
		then
			printf "\x1B[0;37;40m\x1B[22;3f$blankline\x1B[22;4fThe device /dev/dsp does not exist, switching back to DEMO mode...\x1B[20;14f"
			sleep 3
			capturepath=$device
			scan_end=47935
			demo=0
			capturemode="DEMO"
		fi
		statusline
		sleep 1
	fi
	# Enable SOX capture mode, this code is designed around this application on a Macbook Pro 13 inch OSX 10.7.5...
	if [ "$kbinput" == "SOX" ]
	then
		printf "\x1B[0;37;40m\x1B[22;3f$blankline\x1B[22;4fPlease wait while SOX is found, this \x1B[0;31;40mMIGHT\x1B[0;37;40m take a \x1B[0;31;40mLONG\x1B[0;37;40m time...\x1B[20;14f"
		capturepath=$device
		# Uncomment the line below for auto-finding the correct path and "sox" file but it WILL take a long time...
		#capturepath=`find / -name 'sox' 2>/dev/null`
		status=1
		scan_start=0
		scan_jump=1
		scanloops=1
		scan_end=47935
		hold=1
		demo=2
		capturemode="SOX"
		if [ "$capturepath" == "" ]
		then
			printf "\x1B[0;37;40m\x1B[22;3f$blankline\x1B[22;4fThe SOX audio device was not found, switching back to DEMO mode...\x1B[20;14f"
			sleep 3
			capturepath=$device
			demo=0
			capturemode="DEMO"
		fi
		statusline
		sleep 1
	fi
	# The next three commands set the timebase scans; 1, 10 or 100 before COMMAND mode is re-enabled and can be used.
	if [ "$kbinput" == "ONE" ]
	then
		status=1
		scanloops=1
		hold=1
	fi
	if [ "$kbinput" == "TEN" ]
	then
		status=1
		scanloops=10
		hold=1
	fi
	if [ "$kbinput" == "HUNDRED" ]
	then
		status=1
		scanloops=100
		hold=1
	fi
	# This just ptints the version and author of this project.
	if [ "$kbinput" == "VER" ]
	then
		status=254
	fi
	# ************ Horizontal components. *************
	# ************ User timebase section. *************
	# Written longhand for kids to understand.
	if [ "$kbinput" == "TBVAR" ]
	then
		# Ensure capture mode is turned off.
		# RUN<CR> will re-enable it if required.
		scanloops=1
		status=1
		hold=0
		printf "\x1B[0;37;40m\x1B[20;14f"
		read -p "Set timebase starting point. From 0 to $scan_end<CR> " -e tbinput
		printf "\x1B[0;37;40m\x1B[20;14f                                                                 \x1B[0;37;40m\x1B[20;14f"
		# Ensure the timebase values are set to default before changing.
		scan_start=0
		scan_jump=1
		# Eliminate any keyboard error longhand...
		# Ensure a NULL string does NOT exist.
		if [ "$tbinput" == "" ]
		then
			scan_start=0
			tbinput=0
		fi
		# Find the length of the inputted string.
		str_len=`printf "${#tbinput}"`
		# Set the string to the correct last position for the _subscript_ point.
		str_len=$[ ( $str_len - 1 ) ]
		# Now check for continuous numerical charaters ONLY.
		for count in $( seq 0 $str_len )
		do
			# Reuse variable _number_ to obtain each character per loop.
			number=`printf "${tbinput:$count:1}"`
			# Now convert the character to a decimal number.
			number=`printf "%d" \'$number`
			# IF ANY ASCII character exists that is not numerical then reset the scan start point.
			if [ $number -le 47 ]
			then
				scan_start=0
				tbinput=0
			fi
			if [ $number -ge 58 ]
			then
				scan_start=0
				tbinput=0
			fi
		done
		# If all is OK pass the "tbinput" value into the "scan_start" variable.
		scan_start=$tbinput
		# Do a final check that the number is not out of bounds.
		if [ $scan_start -le 0 ]
		then
			scan_start=0
		fi
		if [ $scan_start -ge $scan_end ]
		then
			scan_start=$scan_end
		fi
		# Use exactly the same method as above to determine the jump interval.
		# Now set the jump interval, this is the scan speed...
		printf "\x1B[0;37;40m\x1B[20;14f"
		read -p "Set timebase user speed. From 1 to $[ ( ( ( ( $scan_end - $scan_start ) / 64 ) + 1 ) ) ]<CR> " -e tbinput
		printf "\x1B[0;37;40m\x1B[20;14f                                                                 \x1B[0;37;40m\x1B[20;14f"
		# Eliminate any keyboard error longhand...
		# Ensure a NULL string does NOT exist.
		if [ "$tbinput" == "" ]
		then
			scan_jump=1
			tbinput=1
		fi
		# Find the length of the inputted string.
		str_len=`printf "${#tbinput}"`
		# Set the string to the correct last position for the _subscript_ point.
		str_len=$[ ( $str_len - 1 ) ]
		# Now check for continuous numerical charaters ONLY.
		for count in $( seq 0 $str_len )
		do
			# Reuse variable _number_ to obtain each character per loop.
			number=`printf "${tbinput:$count:1}"`
			# Now convert the character to a decimal number.
			number=`printf "%d" \'$number`
			# IF ANY ASCII character exists that is not numerical then reset the scan jump value.
			if [ $number -le 47 ]
			then
				scan_jump=1
				tbinput=1
			fi
			if [ $number -ge 58 ]
			then
				scan_jump=1
				tbinput=1
			fi
		done
		# If all is OK pass the "tbinput" value into the "scan_jump" variable.
		scan_jump=$tbinput
		# Do a final check that the number is not out of bounds.
		if [ $scan_jump -le 1 ]
		then
			scan_jump=1
		fi
		# Reuse number for upper limit...
		number=$[ ( ( ( $scan_end - $scan_start ) / 64 ) + 1 ) ]
		if [ $scan_jump -ge $number ]
		then
			scan_jump=$number
		fi
		printf "\x1B[0;37;40m\x1B[22;4fScan start at offset \x1B[0;32;40m$scan_start\x1B[0;37;40m, with a jump rate of \x1B[0;32;40m$scan_jump\x1B[0;37;40m."
		sleep 2
		timebase="User variable"
	fi
	# ********** User timebase section end. ***********
	# ********* Calibrated timebase section. **********
	if [ "$kbinput" == "FASTEST" ]
	then
		scan_start=0
		scan_jump=1
		hold=0
		timebase="Fastest possible"
		status=9
		statusline
		sleep 2
	fi
	if [ "$kbinput" == "1mS" ]
	then
		scan_start=0
		hold=0
		timebase="1mS/DIV"
		status=1
		if [ $demo -eq 0 ]
		then
			scan_jump=6
		fi
		if [ $demo -eq 1 ]
		then
			scan_jump=1
		fi
		if [ $demo -eq 2 ]
		then
			scan_jump=6
		fi
	fi
	if [ "$kbinput" == "10mS" ]
	then
		scan_start=0
		hold=0
		timebase="10mS/DIV"
		status=1
		if [ $demo -eq 0 ]
		then
			scan_jump=60
		fi
		if [ $demo -eq 1 ]
		then
			scan_jump=10
		fi
		if [ $demo -eq 2 ]
		then
			scan_jump=60
		fi
	fi
	if [ "$kbinput" == "100mS" ]
	then
		scan_start=0
		hold=0
		timebase="100mS/DIV"
		status=1
		if [ $demo -eq 0 ]
		then
			scan_jump=600
		fi
		if [ $demo -eq 1 ]
		then
			scan_jump=100
		fi
		if [ $demo -eq 2 ]
		then
			scan_jump=600
		fi
	fi
	# *********** Calibrated timebase end. ************
	#
	# ************* Vertical components. **************
	# ******** Pseudo-vertical shift control. *********
	if [ "$kbinput" == "VSHIFT" ]
	then
		while true
		do
			scanloops=1
			status=1
			hold=0
			printf "\x1B[0;37;40m\x1B[20;14f"
			# This input method is something akin to BASIC's INKEY$...
			read -p "Vertical shift:- U for up 1, D for down 1, <CR> to RETURN:- " -n 1 -s vshift
			printf "\x1B[0;37;40m\x1B[20;14f                                                                 \x1B[0;37;40m\x1B[20;14f"
			if [ "$vshift" == "" ]
			then
				break
			fi
			if [ "$vshift" == "D" ]
			then
				vert_shift=$[ ( $vert_shift + 1 ) ]
			fi
			if [ "$vshift" == "U" ]
			then
				vert_shift=$[ ( $vert_shift - 1 ) ]
			# Ensure the shift psoition is NOT out of bounds.
			fi
			if [ $vert_shift -ge 6 ]
			then
				vert_shift=6
			fi
			if [ $vert_shift -le -2 ]
			then
				vert_shift=-2
			fi
			printf "\x1B[23;3f Vertical shift is \x1B[0;32;40m$[ ( 2 - $vert_shift ) ]\x1B[0;37;40m from the mid-point position...                        "
		done
	fi
	# ****** Pseudo-vertical shift control end. *******
	#
	# ********** Connect all plotted points. **********
	if [ "$kbinput" == "DRAW" ]
	then
		drawline=1
		status=3
		hold=0
		scanloops=1
		statusline
		sleep 1
	fi
	# ************* Connected plots done. *************
	#
	# **** PSEUDO synchronisation and triggering. ****
	if [ "$kbinput" == "TRIG" ]
	then
		synchronise=" and OFF"
		sync_point=128
		status=0
		hold=0
		scan_start=$[ ( $scan_start + 1 ) ]
		scan_jump=1
		scanloops=1
		subscript=$scan_start
		grab=0
		if [ $scan_start -ge $scan_end ]
		then
			scan_start=0
			break
		fi
		printf "\x1B[0;37;40m\x1B[20;14f"
		read -p "Set trigger type, <CR> to disable:- " -e kbinput
		printf "\x1B[0;37;40m\x1B[20;14f                                                                 \x1B[0;37;40m\x1B[20;14f"
		if [ "$kbinput" == "SYNCEQ" ]
		then
			synchronise=", ON and fixed"
			trigger
			for subscript in $( seq $scan_start $scan_end )
			do
				grab=`hexdump -n1 -s$subscript -v -e '1/1 "%u"' /tmp/waveform.raw`
				if [ $grab -eq $sync_point ]
				then
					scan_start=$subscript
					break
				fi
			done
		fi
		if [ "$kbinput" == "SYNCGT" ]
		then
			synchronise=", ON and positive going"
			for subscript in $( seq $scan_start $scan_end )
			do
				grab=`hexdump -n1 -s$subscript -v -e '1/1 "%u"' /tmp/waveform.raw`
				if [ $grab -lt 128 ]
				then
					scan_start=$subscript
					break
				fi
			done
		fi
		if [ "$kbinput" == "SYNCLT" ]
		then
			synchronise=", ON and negative going"
			for subscript in $( seq $scan_start $scan_end )
			do
				grab=`hexdump -n1 -s$subscript -v -e '1/1 "%u"' /tmp/waveform.raw`
				if [ $grab -gt 128 ]
				then
					scan_start=$subscript
					break
				fi
			done
		fi
		if [ "$kbinput" == "EXT" ]
		then
			# Remember Corona688's code from the early stages of this thread...
			synchronise=", EXTERNAL and waiting"
			trigger
			: # NOP... Place holder only.
		fi
		status=4
		statusline
		sleep 2
	fi
	# ** PSEUDO synchronisation and triggering end. ***
	#
	# ************* Auto-saving facility. *************
	if [ "$kbinput" == "SAVEON" ]
	then
		hold=1
		scanloops=1
		foreground=31
		status=5
		save_string="ON"
		statusline
		sleep 2
	fi
	if [ "$kbinput" == "SAVEOFF" ]
	then
		hold=0
		scanloops=1
		foreground=37
		status=1
		save_string="OFF"
		statusline
	fi
	# *********** Auto-saving facility end. ***********
	#
	# ******* Low signal level, ZOOM, facility. *******
	if [ "$kbinput" == "ZOOM" ]
	then
		status=6
		hold=0
		zoom
		statusline
		read -p "Press <CR> to continue:- " -e kbinput
		printf "\x1B[0;37;40m\x1B[20;14f                                                                 "
	fi
	# ***** Low signal level, ZOOM, facility end. *****
	#
	# *********** Horizontal shift control. ***********
	if [ "$kbinput" == "HSHIFT" ]
	then
		status=7
		hold=0
		scan_start=0
		scan_jump=1
		timebase="Fastest possible"
		setup=" X=$timebase, Y=$vertical, $coupling coupled, $capturemode mode.$blankline"
		setup="${setup:0:76}"
		while true
		do
			printf "\x1B[0;37;40m\x1B[20;14f"
			# This input method is something akin to BASIC's INKEY$...
			read -p "Horizontal shift, press L, l, R, r, (Q or q to exit):- " -n 1 -s kbinput
			printf "\x1B[0;37;40m\x1B[20;14f                                                                 \x1B[0;37;40m\x1B[20;14f"
			if [ "$kbinput" == "Q" ] || [ "$kbinput" == "q" ]
			then
				break
			fi
			if [ "$kbinput" == "L" ] || [ "$kbinput" == "l" ] || [ "$kbinput" == "R" ] || [ "$kbinput" == "r" ]
			then
				if [ "$kbinput" == "r" ]
				then
					scan_start=$[ ( $scan_start + 64 ) ]
				fi
				if [ "$kbinput" == "R" ]
				then
					scan_start=$[ ( $scan_start + 1 ) ]
				fi
				if [ "$kbinput" == "l" ]
				then
					scan_start=$[ ( $scan_start - 64 ) ]
				fi
				if [ "$kbinput" == "L" ]
				then
					scan_start=$[ ( $scan_start - 1 ) ]
				fi
				if [ $scan_start -le 0 ]
				then
					scan_start=0
				fi
				if [ $scan_start -ge $scan_end ]
				then
					scan_start=$scan_end
				fi
				display
				statusline
				plot
				draw
			fi
		done
		statusline
		sleep 1
	fi
	# ********* Horizontal shift control end. *********
	#
	# ** Symmetrical waveform frequency measurement. **
	if [ "$kbinput" == "FREQ" ]
	then
		status=8
		hold=0
		freq_counter
		statusline
		sleep 2
	fi
	# Symmetrical waveform frequency measurement end. *
	#
	# ********* Set to default AC input mode. *********
	if [ "$kbinput" == "AC" ]
	then
		ststua=0
		hold=0
		freq=2000
		coupling="AC"
	fi
	# ******* Set to default AC input mode end. *******
	#
	# ********* Detect DC polaruty and level. *********
	if [ "$kbinput" == "DC" ]
	then
		status=8
		hold=0
		coupling="AC"
		freq_counter
		statusline
		if [ $freq -le 1998 ] || [ $freq -ge 2002 ]
		then
			hold=1
			coupling="DC"
		fi
	fi
	# ******* Detect DC polaruty and level end. *******
	#
	# *** Print the X an Y range in the status bar. ***
	if [ "$kbinput" == "MODE" ]
	then
		setup=" X=$timebase, Y=$vertical, $coupling coupled, $capturemode mode.$blankline"
		setup="${setup:0:76}"
	fi
	# ********* Print the X and Y ranges end. *********
	#
	# ** Display the last status in the status bar. ***
	if [ "$kbinput" == "STATUS" ]
	then
		hold=0
		status=$laststatus
		statusline
		sleep 3
	fi
	#
	# **** Rerun, (RESET), the AudioScope script. *****
	if [ "$kbinput" == "RESET" ]
	then
		# Reset terminal back to normal...
		printf "\x1B[0m"
		clrscn
		# Delete all unwanted files, ignore ANY error reports for missing files...
		# Note that all saved grabs using "SAVEON" are left intact.
		# Also, /tmp/1KHz-Test.sh, /tmp/VERT_BAT.BAT, /tmp/VERT_SOX.sh and /tmp/VERT_DSP.sh
		# will be left intact _IF_ any are generated by doing the code modifications.
		rm /tmp/AudioScope.config
		rm /tmp/sinewave.raw
		rm /tmp/squarewave.raw
		rm /tmp/symmetricalwave.raw
		rm /tmp/waveform.raw
		reset
		# IMPORTANT!!! ENSURE, AudioScope.sh is inside your _home_ drawer.
		exec ~/AudioScope.sh "$@"
	fi
	# ************* RESET capability end. *************
	setup=" X=$timebase, Y=$vertical, $coupling coupled, $capturemode mode.$blankline"
	setup="${setup:0:76}"
	statusline
}

# #########################################################
# Help clears the screen to the startup defaults and prints command line help...
commandhelp()
{
	status=2
	hold=0
	printf "\x1B[0m"
	clrscn
	printf "CURRENT COMMANDS AVAILABLE:-\n"
	printf "<CR> ................................................. Reruns the scan(s) again.\n"
	printf "RUN<CR> ......................... Reruns the scan(s), always with real captures.\n"
	printf "QUIT<CR> .................................................... Quits the program.\n"
	printf "HELP<CR> ................................................ This help as required.\n"
	printf "HOLD<CR> ........................................ Switch to pseudo-storage mode.\n"
	printf "DEMO<CR> .......... Switch capture to default DEMO mode and 10 continuous scans.\n"
	printf "DSP<CR> ...................... Switch capture to Linux /dev/dsp mode and 1 scan.\n"
	printf "SOX<CR> ....... Switch capture to multi-platform SOund eXchange mode and 1 scan.\n"
	printf "ONE<CR> ......................................... Sets the number of scans to 1.\n"
	printf "TEN<CR> ........................................ Sets the number of scans to 10.\n"
	printf "HUNDRED<CR> ............. Sets the number of scans to 100, (not very practical).\n"
	printf "VER<CR> .................. Displays the version number inside the status window.\n"
	printf "TBVAR<CR> ............ Set up uncalibrated user timebase offset and jump points.\n"
	printf "        SubCommands: ............................. Follow the on screen prompts.\n"
	printf "FASTEST<CR> .................. Set all modes to the fastest possible scan speed.\n"
	printf "1mS<CR> .......................................... Set scanning rate to 1mS/DIV.\n"
	printf "10mS<CR> ........................................ Set scanning rate to 10mS/DIV.\n"
	printf "100mS<CR> ...................................... Set scanning rate to 100mS/DIV.\n"
	printf "VSHIFT<CR> ........... Set the vertical position from -4 to +4 to the mid-point.\n"
	printf "        SubCommands: ............ Press U or D then <CR> when value is obtained.\n"
	printf "DRAW<CR> .......... Connect up each vertical plot to give a fully lined display.\n"
	printf "\n"
	read -p "Press <CR> to continue:- " -e kbinput
	clrscn
	printf "CURRENT COMMANDS AVAILABLE:-\n"
	printf "TRIG<CR> ........... Sets the synchronisation methods for storage mode retraces.\n"
	printf "        SubCommand: SYNCEQ<CR> .. Synchronise from a variable, fixed value only.\n"
	printf "        SubCommand: SYNCGT<CR> ......... Synchronise from a positive going edge.\n"
	printf "        SubCommand: SYNCLT<CR> ......... Synchronise from a negative going edge.\n"
	printf "        SubCommand: EXT<CR> ........................................ UNFINISHED.\n"
	printf "SAVEON<CR> .................... Auto-saves EVERY scan with a numerical filename.\n"
	printf "SAVEOFF<CR> .............................. Disables auto-save facility, default.\n"
	printf "ZOOM<CR> ................................ Low signal level gain, ZOOM, facility.\n"
	printf "        SubCommand: 0<CR> ................. Default lowest zoom/gain capability.\n"
	printf "        SubCommand: 1<CR> ............................. X2 zoom/gain capability.\n"
	printf "        SubCommand: 2<CR> ............................. X4 zoom/gain capability.\n"
	printf "        SubCommand: 3<CR> ............................. X8 zoom/gain capability.\n"
	printf "        SubCommand: 4<CR> ............................ X16 zoom/gain capability.\n"
	printf "        SubCommand: <CR> ...... To exit zoom mode when waveform has been viewed.\n"
	printf "HSHIFT<CR> ............ Shift the trace left or right at the highest scan speed.\n"
	printf "        SubCommand: L ........................ Shift the trace left by one byte.\n"
	printf "        SubCommand: l ... Shift the trace left by 64 bytes, (one complete scan).\n"
	printf "        SubCommand: R ....................... Shift the trace right by one byte.\n"
	printf "        SubCommand: r .. Shift the trace right by 64 bytes, (one complete scan).\n"
	printf "        SubCommand: Q or q ........ Exit back to normal usage, (quit this mode).\n"
	printf "Manual here: <  http://wisecracker.host22.com/public/AudioScope_Manual.readme  >\n"
	printf "\n"
	read -p "Press <CR> to continue:- " -e kbinput
	clrscn
	printf "CURRENT COMMANDS AVAILABLE:-\n"
	printf "RESET<CR> ............................ Do a complete COLD restart of the script.\n"
	printf "FREQ<CR> ..... Measure a symmetrical waveform's frequency, accuracy 0.1 percent.\n"
	printf "AC<CR> ............................ Set vertical input to default AC input mode.\n"
	printf "DC<CR> ................... Attempt to measure DC polarity and level. UNFINISHED.\n"
	printf "MODE<CR> .. Display the X, Y, coupling and mode ranges inside the status window.\n"
	printf "STATUS<CR> . Display the previous status for 3 seconds inside the status window.\n"
	printf "\n"
	read -p "Press <CR> to continue:- " -e kbinput
	printf "\x1B[H\x1B[0;36;44m"
	clrscn
	display
	statusline
}

# #########################################################
# This is the active part of the pseudo-synchroisation section.
trigger()
{
	while true
	do
		printf "\x1B[0;37;40m\x1B[20;14f"
		# This input method is something akin to BASIC's INKEY$...
		read -p "Sync point:- U for up 1, D for down 1, <CR> to RETURN:- " -n 1 -s sync_input
		printf "\x1B[0;37;40m\x1B[20;14f                                                                 \x1B[0;37;40m\x1B[20;14f"
		if [ "$sync_input" == "" ]
		then
			break
		fi
		if [ "$sync_input" == "U" ]
		then
			sync_point=$[ ( $sync_point + 1 ) ]
		fi
		if [ "$sync_input" == "D" ]
		then
			sync_point=$[ ( $sync_point - 1 ) ]
		# Ensure the synchronisation point is NOT out of bounds.
		fi
		if [ $sync_point -ge 240 ]
		then
			sync_point=240
		fi
		if [ $sync_point -le 15 ]
		then
			sync_point=15
		fi
		printf "\x1B[23;3f Synchronisation point set to \x1B[0;32;40m$sync_point\x1B[0;37;40m...                                        "
	done
}

# #########################################################
# This is the software zooming facility.
# This does NOT alter any user values at all.
zoom()
{
	printf "\x1B[0;37;40m\x1B[20;14f"
	read -p "Set ZOOM gain, (4 = maximum sensitivity), 1, 2, 3 or 4<CR> " -e kbinput
	printf "\x1B[0;37;40m\x1B[20;14f                                                                 \x1B[0;37;40m\x1B[20;14f"
	zoom_facility="OFF"
	zoom="Lowest sensitivity zoom/gain, default condition..."
	# Written longhand for anyone to understnd how it works.
	if [ "$kbinput" == "1" ] || [ "$kbinput" == "2" ] || [ "$kbinput" == "3" ] || [ "$kbinput" == "4" ]
	then
		zoom_facility="ON"
	fi
	display
	# Just these four ranges are needed for the zoom facility.
	if [ "$zoom_facility" == "ON" ]
	then
		subscript=$scan_start
		vert_array=""
		for horiz in {9..72}
		do
			vert=`hexdump -n1 -s$subscript -v -e '1/1 "%u"' /tmp/waveform.raw`
			if [ "$kbinput" == "1" ]
			then
				zoom="\x1B[22;3f 2X zoom/gain state..."
				vert=$[ ( $vert - 64 ) ]
				vert=$[ ( ( $vert / 8 ) + 2 ) ]
			fi
			if [ "$kbinput" == "2" ]
			then
				zoom="\x1B[22;3f 4X zoom/gain state..."
				vert=$[ ( $vert - 96 ) ]
				vert=$[ ( ( $vert / 4 ) + 2 ) ]
			fi
			if [ "$kbinput" == "3" ]
			then
				zoom="\x1B[22;3f 8X zoom/gain state..."
				vert=$[ ( $vert - 112 ) ]
				vert=$[ ( ( $vert / 2 ) + 2 ) ]
			fi
			if [ "$kbinput" == "4" ]
			then
				zoom="\x1B[22;3f 16X zoom/gain state..."
				vert=$[ ( ( $vert - 120 ) + 2 ) ]
			fi
			if [ $vert -le 2 ]
			then
				vert=2
			fi
			if [ $vert -ge 17 ]
			then
				vert=17
			fi
			subscript=$[ ( $subscript + $scan_jump ) ]
			vert_array="$vert_array$vert "
			printf "\x1B[1;37;44m\x1B["$vert";"$horiz"f*"
		done
	fi
	# Revert to the plot function for the default lowest resolution.
	if [ "$zoom_facility" == "OFF" ]
	then
		plot
	fi
	draw
}

# #########################################################
# Frequency counter from 50Hz to 3500Hz.
# This function is used to detect the DC polarity too.
# The sampling rate is the lowest at 8000Hz as that is all that is needed.
freq_counter()
{
IFS=" "
freq=0
freq_array=""
subscript=0
> /tmp/symmetricalwave.raw
# This is a demo mode so that there is no need to access HW.
# Set at 2000Hz so as to always default to AC input mode.
if [ $demo -eq 0 ]
then
	sleep 1
	cp /tmp/squarewave.raw /tmp/symmetricalwave.raw
fi
# The next two are for real grabs, this one is for /dev/dsp users...
if [ $demo -eq 1 ]
then
	dd if=/dev/dsp of=/tmp/symmetricalwave.raw bs=8000 count=1 > /dev/null 2>&1
fi
# This one is for SOX users.
if [ $demo -eq 2 ]
then
	# The absolute address will be found when running the code, but, it WILL take a LONG time to find...
	$capturepath -q -V0 -d -t raw -r 8000 -b 8 -c 1 -e unsigned-integer -> /tmp/symmetricalwave.raw trim 0 00:01
fi
freq_array=(`hexdump -v -e '1/1 "%u "' /tmp/symmetricalwave.raw`)
while true
do
	# Assume a square wave "mark to space" ratio of 1 to 1 is used,
	# then "wait" until a "space" is found.
	# (For those that don't know.)
	#
	#                  +------+      +---
	# Square wave:-    | Mark |Space |
	#               ---+      +------+
	#
	# This ensures that the loop cycles when NO input is
	# applied to the microphone socket.
	# Exit this loop when "mark" is found or n >= 8000...
	while [ ${freq_array[$subscript]} -ge 128 ]
	do
		subscript=$[ ( $subscript + 1 ) ]
		# Ensure as soon as subscript >= 8000 occurs it drops out of the loop.
		if [ $subscript -ge 8000 ]
		then
			break
		fi
	done
	# Ensure as soon as subscript >= 8000 occurs it drops completely out of this loop.
	if [ $subscript -ge 8000 ]
	then
		break
	fi
	# Now the "mark" can loop until a "space" is found again and the whole
	# can cycle until subscript >= 8000...
	while [ ${freq_array[$subscript]} -le 127 ]
	do
		subscript=$[ ( $subscript + 1 ) ]
		# Ensure as soon as subscript >= 8000 occurs it drops out of the loop.
		if [ $subscript -ge 8000 ]
		then
			break
		fi
	done
	# Ensure as soon as subscript >= 8000 occurs it drops completely out of this loop.
	if [ $subscript -ge 8000 ]
	then
		break
	fi
	# "freq" will become the frequency of a symmetrical waveform
	# when the above loops are finally exited, subscript >= 8000...
	# Tick up the freq(uency) per "mark to space" cycle.
	freq=$[ ( $freq + 1 ) ]
	done
IFS="$ifs_str"
}

# #########################################################
# Do an initial screen set up...
display
statusline

# #########################################################
# This is the main loop...
while true
do
	for scan in $( seq 1 $scanloops )
	do
		# "hold" determines a new captured scan or retrace of an existing scan...
		if [ $hold -eq 1 ]
		then
			waveform
		fi
		display
		statusline
		plot
		if [ $drawline -eq 1 ]
		then
			draw
		fi
		if [ "$save_string" == "ON" ]
		then
			savefile=`date +%s`
			cp /tmp/waveform.raw /tmp/$savefile
		fi
	done
	setup=" X=$timebase, Y=$vertical, $coupling coupled, $capturemode mode.$blankline"
	setup="${setup:0:76}"
	laststatus=$status
	status=0
	statusline
	kbcommands
done

# #########################################################
# Getout, autosave AudioScope.config, cleanup and quit...
if [ $status -eq 255 ]
then
	# Save the user configuration file.
	user_config
	# Remove "Shell AudioScope" from the title bar.
	printf "\x1B]0;\x07"
	sleep 0.1
	# Reset back to normal...
	printf "\x1B[0m"
	clrscn
	IFS="$ifs_str"
	reset
fi
printf "\nProgram terminated...\n\nTerminal reset back to startup defaults...\n\n"
exit 0

# #########################################################
# The FIRST extremely simple construction part.
# This is a simple I/O board for testing for the Macbook Pro 13 inch...
# It is just as easy to replace the 4 pole 3.5mm Jack Plug with 2 x 3.5mm Stereo Jack
# Plugs for machines with separate I/O sockets.
#                                                       Orange.       White flylead.
# Tip ----->  O  <------------------------------------+---------O <----------+--------+
# Ring 1 -->  H  <-------------------------+-----------)--------O <- Blue.   |        |
# Ring 2 -->  H  <--------------+-----+-----)----------)--------O <- Yellow. |        |
# _Gnd_ --->  H  <----+         |  C1 | +  |          |         O <- Green.  |        |
#           +===+     |         \   =====  \          \         |            \        |
#           |   |     |         /   --+--  /          /         |            /        |
#        P1 |   |     |         \     |    \          \         |            \        |
#           |   |     |      R1 /     | R2 /       R3 /         |         R4 /        |
#            \ /      |         \     |    \          \         |            \        |
#             H       |         /     |    /          /         |            /        |
#            ~~~      |         |     |    |          |         |            |        |
#                     +---------+------)---+----------+---------+------------+        |
# Pseudo-Ground. -> __|__             |                                               |
#                   /////             +-----------------------------------------------+
# Parts List:-
# P1 ......... 3.5mm, 4 pole jack plug.
# R1 ......... 2K2, 1/8W, 5% tolerence resistor.
# R2, R3 ..... 33R, 1/8W, 5% tolerence resistor.
# R4 ......... 1M, 1/8W, 5% tolerence resistor.
# C1 ......... 47uF, 16V electrolytic.
# 4 way terminal block.
# Stripboard, (Verobaord), as required.
# Green, yellow, orange, blue, white and tinned copper wire as required.
# Small cable ties, optional.
# Stick on cable clip, optional.
# Crimp terminal, 1 off, optional.
# #########################################################
# #########################################################
# The SECOND extremely simple construction part.
# This is the simple vertical calibration HW for this project.
# This uses the dedicated square wave generators for remote machine usage.
# This circuit is isolated from the computer through a transformer.
#                                   R1        1.4VP-P       R2      R3  1VP-P
# Left Channel O/P. O----+    +---/\/\/\---+-----O--------/\/\/\--/\/\/\--O T2
# Tip of 4 pole plug.    |TX1 |            |   T1|  0.1VP-P R4      R5    |
#                        |    |            |     |  T3 O--/\/\/\--/\/\/\--+
#                         )||(             |     |     |    R6      R7 10mVP-P
#                         )||(          D1 | +   |     +--/\/\/\--/\/\/\--O T4
#                         )||( Primary.  --+-- ,-+-,        R8      R9    |
#              Secondary. )||(o (CT)      / \   \ /    +--/\/\/\--/\/\/\--+
#                         )||(           '-+-' --+--   |
#                         )||(             |  D2 | +   |
#                         )||(             |     |     |
#                        |    |            |     |     |
# Barrel of 4 pole plug. |    |            |     |     |           O/P Common.
# Pseudo-Ground. -> O--+-+    +------------+-----+-----+------------------O T5
#                    __|__
#                    /////
# Test lead red wire.
# Connect to T1 - T4 <-----------------------------( Red Croc Clip.
# Test lead black wire.
#      Connect to T5 <-----------------------------( Black Croc Clip.
# Parts List:-
# TX1 ........ Audio Output Transformer, example, Maplin P/No:- LB14Q.
# D1, D2 ..... 1N4148, silicon small signal diodes.
# R1 ......... 2K2, 1/8W, 5% tolerence resistor.
# R2 ......... 12K, 1/8W, 5% tolerence resistor.
# R3 ......... 1K5, 1/8W, 5% tolerence resistor.
# R4 ......... 27K, 1/8W, 5% tolerence resistor.
# R5 ......... 3K3, 1/8W, 5% tolerence resistor.
# R6 ......... 2K7, 1/8W, 5% tolerence resistor.
# R7, R8 ..... 330R, 1/8W, 5% tolerence resistor.
# R9 ......... 4R7, 1/8W, 5% tolerence resistor, this can be omitted.
# T1 - T5 .... 5 way terminal block.
# Stripboard, (Verobaord), as required.
# Red, black and tinned copper wire as required.
# Small cable ties, optional.
# Stick on cable clip, optional.
# 1 Red and 1 Black Croc clip(s) for the test lead.
# #########################################################

