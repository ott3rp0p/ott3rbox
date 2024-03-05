#!/bin/bash 
#should this be a bash script? probably not.
#hack the box pwnbox setup. save in ~/my_data for future use.
#primarily made for hackthebox's pwnbox. could be used elsewhere with very minimal tweaking.
#run --setup and then use the script in the folder you provide for configuration.
#ott3rp0p


#root check
if [ "$EUID" -eq 0 ]
  then echo "don't run this as root"
  exit
fi

#variables
id=$(whoami)
workFolder=workFolder
scriptSource=$0
scriptDirectory=$(dirname "$0")
var1=$1 var2=$2 var3=$3
penList="\n\e[36mPentest:\033[0m\nNetExec\nx8\nLigolo-ng\np0wny-shell\nPHP webshell limited\nMarshalsec\nYsoserial\nRunasCs\nSharpGPOAbuse\nPEASS-ng\nPsMapExec\nPython BloodHound\nWhiteWinterWolf PHP Shell\nChisel\nTInjA"
langList="\n\n\e[36mLanguages:\033[0m\nRust\nUpdate Go"
forenList="\n\n\e[36mForensics:\033[0m\nOLETools\nDidierStevensSuite\nVivisect\nVolatlity Framework"
otherStuff="\n\n\e[36mOther Stuff:\033[0m\nMono\nDocker\nSet AWS CLI test keys\nAwesomeVIM\n\n"


#probably unnecessary help menu
--help(){
	printf "🦦 🍭\n\n"
	if [ -z $1 ] 
		then printf "use this script to configure your pwnbox's appearance as well as download various tools\n\n--help:         script information. --help options for more\n--setup:        run by itself first to create files\n--config:       configure pwnbox. requires IPv4 address for target\n--prompt:       use my terminal prompt. shows IP/User/Host/PWD\n--ex-prompt:    show example of promp appearance \n--tools:        download all tools\n--list:         list all tools to be downloaded\n--otter:        print an otter\n\nexample:       ./ott3rbox_setup.sh --help config\nexample:       ./ott3rbox_setup.sh --config 10.129.16.182 --tools --prompt\n\n"
		exit
	elif [ $1 == "config" ]
		then printf "set pwnbox configurations for mate panel/desktop/terminal.\npulled from $workFolder/conf after --setup creates the files.\n\n"
		exit
	elif [ $1 == "setup" ]
		then printf "save mate settings for terminal/desktop/panel\nwill also save firefox bookmarks\n\nyou'll only need to run this again if you update some settings \nthat you want to save for future pwnbox instances.\n\n" 
		exit
	elif [ $1 == "prompt" ]
		then printf "configure terminal prompt.\nwill copy old .zsrhc to %sconf/zshrc.old\nuse --ex-prompt for an example of what it will look like\n\n" $workFolder
		exit
	elif [ $1 == "ex-prompt" ]
		then printf "shows an example of my prompt\n\n"
		exit
	elif [ $1 == "tools" ]
		then printf "download tools from various web locations. review script for exact URIs\n\n"
		exit
	elif [ $1 == "list" ]
		then printf "list tools to be downloaded\n\n"
		exit
	elif [ $1 == "otter" ]
		then printf "otter time\n\n"
		exit
	else printf "no help menu for \"$1\"\n\n"
	fi
}

#setup files for future use
#uncomment line to save settings instead of using provided file
--setup(){
	read -p $'Provide the folder path for conf files. \nPress enter for default:  ' -i "/home/$id/my_data/ " -e workFolder
	printf "\nyou will only need to run this the first time. \nafterwards anytime you run this script use\n%sconf/ott3rbox_setup.sh --config\n\n\n" $workFolder

	printf "creating workFolder %sconf" $workFolder
	mkdir $workFolder/conf 2>/dev/null

	#moving script
	printf "\ncopying otterbox_setup.sh to %sconf\n" $workFolder
	cp $scriptSource $workFolder/conf/ott3rbox_setup.sh;chmod +x $workFolder/conf/ott3rbox_setup.sh
	cp $scriptDirectory/conf.txt $workFolder/conf/conf.txt
	sed -i "s+workFolder=workFolder+workFolder=$workFolder+g" $workFolder/conf/ott3rbox_setup.sh
	sed -i "s+changeme+$workFolder+g" $workFolder/conf/conf.txt
	
	#dump/copy mate preferences
	printf "creating files %sconf/*.mate\n" $workFolder
	awk '/aaaa/{flag=1;next}/bbbb/{flag=0}flag' $workFolder/conf/conf.txt > $workFolder/conf/panel.mate
	dconf dump /org/mate/desktop/ > $workFolder/conf/bg.mate
	awk '/iiii/{flag=1;next}/jjjj/{flag=0}flag' $workFolder/conf/conf.txt > $workFolder/conf/term.mate
	#dconf dump /org/mate/terminal/profiles/default/ > $workFolder/conf/term.mate
	
	#copy example files
	printf "creating %sconf/tmux.conf\n" $workFolder
	awk '/cccc/{flag=1;next}/dddd/{flag=0}flag' $workFolder/conf/conf.txt > $workFolder/conf/.tmux.conf
	printf "creating %sconf/.zshrc\n" $workFolder
	awk '/eeee/{flag=1;next}/ffff/{flag=0}flag' $workFolder/conf/conf.txt > $workFolder/conf/.zshrc
	
	#backup firefox bookmarks
	printf "exporting firefox bookmarks to %sconf/firefox.bookmarks" $workFolder
	mv $workFolder/conf/firefox.bookmarks $workFolder/conf/firefox.bookmarks.old
	sqlite3 /home/$id/.mozilla/firefox/*.default-esr/places.sqlite ".backup $workFolder/conf/firefox.bookmarks"

}

#configure everything but terminal prompt
--config(){
	#validate IPv4 format
	if [ -z $1 ]
		then printf "needs a target IP"
		exit
	elif [[ $1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
		then :
	else printf "target IP is not in a valid IPv4 format"
		exit	
	fi

	#configure appearance of panel/terminal/background
	printf "TARGET: $1\n"  > $workFolder/conf/data.txt
	ip a |awk '/tun/ && /inet/ {print "TUN: "$2;exit}' >> $workFolder/conf/data.txt
	dconf load /org/mate/panel/ < $workFolder/conf/panel.mate
	dconf load /org/mate/desktop/ < $workFolder/conf/bg.mate
	dconf load /org/mate/terminal/profiles/default/ < $workFolder/conf/term.mate
	
	#start tmux when opening terminal
	printf '\nif command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then\nexec tmux\nfi' >> /home/$id/.bashrc

	#copy conf files to home directory
	cp $workFolder/conf/.zshrc /home/$id/.zshrc
	cp $workFolder/conf/.tmux.conf /home/$id/.tmux.conf
	tmux source /home/$id/.tmux.conf 2>/dev/null

	#restore firefox bookmarks
	sqlite3 /home/$id/.mozilla/firefox/*.default-esr/places.sqlite ".restore $workFolder/conf/firefox.bookmarks"

	#fix apache2. this may be fixed in later versions of pwnbox since academy requires it.
 	sudo sed -i '1i Servername localhost' /etc/apache2/apache2.conf 2>/dev/null
  	sudo sed -i 's/Listen 80/Listen 8811/g' /etc/apache2/ports.conf 2>/dev/null


	if [[ $var2 == "--tools" ]]
		then --tools
	elif [[ $var2 == "--prompt" ]]
		then --prompt
	fi
	exit
}

#set terminal prompt 
--prompt(){
	printf "\nbacking up current .zshrc to %sconf/zshrc.old\n\n" $workFolder
	cp /home/$id/.zshrc $workFolder/conf/zshrc.old
	awk '/gggg/{flag=1;next}/hhhh/{flag=0}flag' $workFolder/conf/conf.txt > /home/$id/.zshrc
	exit
}

#show terminal prompt example
--ex-prompt(){
	printf "\n\e[31m┌[\e[36m10.10.14.84\e[31m]─[\e[92mott3rp0p 🦦 htb-1hcye3hbvf\e[31m]─[\e[35m/home/ott3rp0p/my_data\e[31m]
└╼[\e[33m$\n\n"
}

#print an otter
--otter(){
	printf "▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████████▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒██▓▓▓▓██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██▓▓▓▓██▒▒▒▒▒▒\n▒▒▒▒██▓▓▓▓██▒▒▒▒▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▒▒▒▒██▓▓▓▓██▒▒▒▒\n▒▒▒▒██▓▓██▒▒▒▒▓▓████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒████████▓▓▒▒▒▒██▓▓██▒▒▒▒\n▒▒▒▒██▓▓██▒▒▒▒██  ██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██  ██████▒▒▒▒██▓▓██▒▒▒▒\n▒▒▒▒▒▒██▒▒▒▒▒▒██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████████▒▒▒▒▒▒██▒▒▒▒▒▒\n▒▒▒▒▒▒██▒▒▒▒▒▒▓▓██████▒▒▒▒▓▓████████▓▓▒▒▒▒██████▓▓▒▒▒▒▒▒██▒▒▒▒▒▒\n▒▒▒▒▒▒██▒▒▒▒▒▒▒▒▓▓▓▓▒▒▒▒▓▓████  ██████▓▓▒▒▒▒▓▓▓▓▒▒▒▒▒▒▒▒██▒▒▒▒▒▒\n▒▒▒▒▒▒██▒▒    ▒▒▒▒▒▒▒▒▓▓████  ██████████▓▓▒▒▒▒▒▒▒▒    ▒▒██▒▒▒▒▒▒\n▒▒▒▒▒▒██░░░░░░░░▒▒▒▒▒▒████████████████████▒▒▒▒▒▒░░░░░░░░██▒▒▒▒▒▒\n▒▒▒▒▒▒██░░░░░░░░░░▒▒▒▒████████████████████▒▒▒▒  ░░░░░░░░██▒▒▒▒▒▒\n▒▒▒▒▒▒██░░░░  ░░▒▒▒▒░░▒▒████████████████▒▒░░▒▒▒▒░░    ░░██▒▒▒▒▒▒\n▒▒▒▒▒▒██            ░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ░░          ░░██▒▒▒▒▒▒\n▒▒▒▒▒▒    ▒▒▒▒▒▒░░░░  ░░░░            ░░░░  ░░  ▒▒▒▒▒▒    ▒▒▒▒▒▒\n▒▒    ▒▒██▒▒      ░░░░░░░░████████████░░░░░░░░      ▒▒██▒▒    ▒▒\n  ▒▒▒▒▒▒    ▒▒▒▒░░░░▒▒▒▒██▓▓▓▓▓▓▓▓▓▓▓▓██▒▒▒▒░░░░▒▒▒▒    ▒▒▒▒▒▒  \n▒▒▒▒    ▒▒██▒▒▒▒▒▒▒▒████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓████▒▒▒▒▒▒▒▒██▒▒    ▒▒▒▒\n▒▒  ▒▒▒▒▒▒▒▒██▒▒▒▒▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▒▒▒▒██▒▒▒▒▒▒▒▒  ▒▒\n▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████████▓▓▓▓▓▓▒▒▒▒▓▓▓▓▓▓██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒▒▒██▓▓▓▓▓▓▓▓▓▓████████████████▓▓▓▓▓▓▓▓▒▒██▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒▒▒██▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒██▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒██▒▒░░▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒  ░░▒▒██▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒██▒▒░░░░▒▒▓▓▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒░░░░░░▒▒██▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒██▒▒░░░░  ▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓▓▓▓▓▒▒  ▒▒▓▓██▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒██▓▓▓▓▒▒░░▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓▒▒  ░░▒▒▓▓▓▓██▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒██▓▓▓▓▒▒░░  ▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓░░  ░░░░  ▒▒▓▓██▒▒▒▒▒▒▒▒"
	exit
}

#list tools
--list(){
	printf "\neverything listed will be downloaded. #comment out in script to ignore certain repos.\n"
	printf "$penList"
	printf "$forenList"
	printf "$langList"
	printf "$otherStuff"
	exit
}

#download tools
#comment out unwanted tools as needed
--tools(){

	#prompts keychain
	pip3 install vivisect

	#make directories
	sudo mkdir /opt/tools;sudo chown $(whoami) /opt/tools;sudo chgrp $(whoami) /opt/tools
	mkdir /opt/tools/jd-gui;mkdir /opt/tools/RunasCs;mkdir /opt/tools/peass;mkdir /opt/tools/SharpGPOAbuse

	#otherStuff
	sudo apt update --yes
	sudo apt install dirmngr ca-certificates gnupg
	sudo gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/debian stable-buster main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
	sudo apt install mono-devel --yes
	sudo apt-get install docker.io docker-compose-plugin --yes
	sudo apt install libc6
	
	#set aws test keys
	aws configure set aws_access_key_id "AKIAIOSFODNN7EXAMPLE"
 	aws configure set aws_secret_access_key "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
	git clone --depth=1 https://github.com/amix/vimrc.git .vim_runtime
	sh .vim_runtime/install_awesome_vimrc.sh

	#might hang on this. comment out if unneeded 
	#searchsploit -u

	#langList
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source "$HOME/.cargo/env"
	sudo apt-get remove golang-go --yes
	sudo apt-get remove --auto-remove golang-go --yes 
	wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz -O /tmp/go1.22.0.linux-amd64.tar.gz;cd /tmp
	sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz

	#gitList
	cargo install x8
	pipx install git+https://github.com/Pennyw0rth/NetExec
	git clone https://github.com/danielmiessler/SecLists.git /opt/tools/SecLists
	git clone https://github.com/carlospolop/Auto_Wordlists.git /opt/tools/Auto_Wordlists
	git clone https://github.com/nicocha30/ligolo-ng.git /opt/tools/ligolo-ng
	git clone https://github.com/flozz/p0wny-shell.git /opt/tools/p0wny-shell
	git clone https://github.com/carlospolop/phpwebshelllimited.git /opt/tools/phpwebshelllimited
	git clone https://github.com/mbechler/marshalsec /opt/tools/marshalsec;cd /opt/tools/marshalsec; mvn clean package -DskipTests
	git clone https://github.com/frohoff/ysoserial.git /opt/tools/ysoserial
	git clone https://github.com/The-Viper-One/PsMapExec.git /opt/tools/PsMapExec
	git clone https://github.com/WhiteWinterWolf/wwwolf-php-webshell.git /opt/tools/wwwolf-php-webshell
	git clone https://github.com/jpillora/chisel.git /opt/tools/chisel
	git clone https://github.com/Hackmanit/TInjA.git /opt/tools/TInjA


	wget https://github.com/frohoff/ysoserial/releases/latest/download/ysoserial-all.jar -O /opt/tools/ysoserial/ysoserial-all.jar
	wget https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.jar -O /opt/tools/jd-gui/jd-gui-1.6.6.jar
	wget https://github.com/antonioCoco/RunasCs/releases/latest/download/RunasCs.zip -O /opt/tools/RunasCs/RunasCs.zip;cd /opt/tools/RunasCs/; unzip RunasCs.zip
	wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh -O /opt/tools/peass/linpeas.sh
	wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASany.exe -O /opt/tools/peass/winpeasany.exe
	wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat -O /opt/tools/peass/winpeas.bat
	wget https://github.com/byronkg/SharpGPOAbuse/releases/latest/download/SharpGPOAbuse.exe -O /opt/tools/SharpGPOAbuse/SharpGPOAbuse.exe
	wget https://github.com/dirkjanm/BloodHound.py/archive/refs/tags/v1.0.1.zip -O /opt/tools/v1.0.1.zip;cd /opt/tools;unzip v1.0.1.zip;cd BloodHound.py-1.0.1; pip install .;rm /opt/tools/v1.0.1.zip
	wget https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_amd64.gz -O /opt/tools/chisel/linux.gz;cd /opt/tools/chisel;gunzip linux.gz
	wget https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_windows_amd64.gz -O /opt/tools/chisel/windows.gz;gunzip windows.gz
	wget https://github.com/Hackmanit/TInjA/releases/download/1.1.2/TInjA_1.1.2_linux_amd64.tar.gz -O /opt/tools/TInjA; cd /opt/tools/TInjA/build;tar -xzvf TInjA_1.1.2_linux_amd64.tar.gz

	#forenList
	git clone https://github.com/decalage2/oletools.git /opt/tools/oletools
	git clone https://github.com/DidierStevens/DidierStevensSuite.git /opt/tools/DidierStevensSuite
	git clone https://github.com/volatilityfoundation/volatility3.git /opt/tools/volatility3;cd /opt/tools/volatility3;pip3 install -r requirements.txt
	

	#finish
 	printf "\nall downloads will be in /opt/tools/\n"
  

	if [[ $var3 == "--prompt" ]]
		then --prompt
	fi
	exit
}

$1 $2 $3 $4 $5

if [ -z $1 ]
	then --help
	exit
fi

#notes conf.txt
#aaaabbbb -> panel.conf
#ccccdddd -> tmux.conf
#eeeeffff -> zshrc
#gggghhhh -> prompt
#iiiijjjj -> term.conf
