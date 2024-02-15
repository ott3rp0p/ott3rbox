#!/bin/bash 
#should this be a bash script? probably not.
#hack the box pwnbox setup. save in ~/my_data for future use. set up background/terminal/panels appearances as desired and then run.
#sudo will set the wrong home directory. plus pwnbox has (ALL) NOPASSWD: ALL set so you shouldn't need it.
#ott3rp0p


#root check
if [ "$EUID" -eq 0 ]
  then echo "don't run this as root"
  exit
fi

#variables
gitList="\n\e[36mGithub Tools:\033[0m\nNetExec\nx8\nLigolo-ng\np0wny-shell\nphpwebshelllimited\nmarshalsec\nysoserial\nRunasCs"
langList="\n\n\e[36mLanguages:\033[0m\nRust"
otherTools="\n\n\e[36mOther Stuff:\033[0m\nmono\ndocker\nset AWS CLI test keys\n\n"
id=$(whoami)

#probably unnecessary help menu
--help(){
	printf "🦦 🍭\n\n"
	if [ -z $1 ] 
		then printf "use this script to configure your pwnbox's appearance as well as download various tools\n\n--help:         script information. --help options for more\n--setup:        run by itself first to create files\n--config:       configure pwnbox. requires IPv4 address for target\n--conf-prompt:  use my terminal prompt. shows IP/User/Host/PWD\n--prompt-ex:    show example of promp appearance \n--tools:        download all tools\n--list:         list all tools to be downloaded\n--otter:        print an otter\n\nexample:       ./ott3rbox_setup.sh --help config\nexample:       ./ott3rbox_setup.sh --config 10.129.16.182 --tools --config-prompt\n\n"
		exit
	elif [ $1 == "config" ]
		then printf "set pwnbox configurations for mate panel/desktop/terminal.\npulled from ~my_data/conf after --setup creates the files.\n\n"
		exit
	elif [ $1 == "setup" ]
		then printf "save mate settings for terminal/desktop/panel\nwill also save firefox bookmarks\n\nyou'll only need to run this again if you update some settings \nthat you want to save for future pwnbox instances.\n\n" 
		exit
	elif [ $1 == "config-prompt" ]
		then printf "configure terminal prompt.\nwill copy old .zsrhc to ~/my_data/conf/zshrc.old\nuse --ex-prompt for an example of what it will look like\n\n"
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
	printf "you will only need to run this the first time. afterwards anytime you start your pwnbox just run --config\n\n"
	printf "creating folder ~/my_data/conf\n"
	mkdir /home/$id/my_data/conf 2>/dev/null
	printf "creating files ~/my_data/conf/*.mate\n"
	
	#dump/copy mate preferences
	cp /home/$id/my_data/ott3rbox/panel.mate /home/$id/my_data/conf/panel.mate
	dconf dump /org/mate/desktop/ > /home/$id/my_data/conf/bg.mate
	dconf dump /org/mate/terminal/profiles/default/ > /home/$id/my_data/conf/term.mate
	sed -i "s+changeme+$id+g" /home/$id/my_data/conf/panel.mate
	
	#copy example files
	printf "creating ~/my_data/conf/tmux.conf\n"
	cp /home/$id/my_data/ott3rbox/tmux.conf /home/$id/my_data/conf/.tmux.conf
	printf "creating ~/my_data/conf/.zshrc\n"
	cp /home/$id/my_data/ott3rbox/zshrc /home/$id/my_data/conf/.zshrc
	
	#backup firefox bookmarks
	sqlite3 /home/$id/.mozilla/firefox/*.default-esr/places.sqlite ".backup /home/$id/my_data/conf/firefox.bookmarks"
}

#configure everything but terminal prompt
--config(){
	#validate IPv4 format
	var1=$1 var2=$2 var3=$3
	if [ -z $1 ]
		then printf "needs a target IP"
		exit
	elif [[ $1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
		then :
	else printf "target IP is not in a valid IPv4 format"
		exit	
	fi

	#configure appearance of panel/terminal/background
	printf "TUN: $(/opt/vpnbash.sh) " > /home/$id/my_data/conf/tun.txt
	printf "TARGET: $1"  > /home/$id/my_data/conf/target.txt
	dconf load /org/mate/panel/ < /home/$id/my_data/conf/panel.mate
	dconf load /org/mate/desktop/ < /home/$id/my_data/conf/bg.mate
	dconf load /org/mate/terminal/profiles/default/ < /home/$id/my_data/conf/term.mate
	
	#start tmux when opening terminal
	printf '\nif command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then\nexec tmux\nfi' >> /home/$id/.bashrc

	#copy conf files to home directory
	cp /home/$id/my_data/conf/.zshrc /home/$id/.zshrc
	cp /home/$id/my_data/conf/.tmux.conf /home/$id/.tmux.conf
	tmux source /home/$id/.tmux.conf

	#restore firefox bookmarks
	sqlite3 /home/$id/.mozilla/firefox/*.default-esr/places.sqlite ".restore /home/$id/my_data/conf/firefox.bookmarks"

	if [[ $2 == "--tools" ]]
		then --tools
	fi
}

#set terminal prompt 
--config-prompt(){
	printf "\nbacking up current .zshrc to ~/my_data/conf/zshrc.old\n\n"
	cp /home/$id/.zshrc /home/$id/my_data/conf/zshrc.old
	cp /home/$id/my_data/ott3rbox/zshrcprompt /home/$id/my_data/conf/.zshrc
	cp /home/$id/my_data/ott3rbox/zshrcprompt /home/$id/.zshrc
}

#show terminal prompt example
--ex-prompt(){
	printf "\n\e[31m┌[\e[36m10.10.14.84\e[31m]─[\e[92mott3rp0p 🦦 htb-1hcye3hbvf\e[31m]─[\e[35m/home/ott3rp0p/my_data\e[31m]
└╼[\e[33m$\n\n"
}

#print an otter
--otter(){
	printf "▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████████▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒██▓▓▓▓██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██▓▓▓▓██▒▒▒▒▒▒\n▒▒▒▒██▓▓▓▓██▒▒▒▒▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▒▒▒▒██▓▓▓▓██▒▒▒▒\n▒▒▒▒██▓▓██▒▒▒▒▓▓████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒████████▓▓▒▒▒▒██▓▓██▒▒▒▒\n▒▒▒▒██▓▓██▒▒▒▒██  ██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██  ██████▒▒▒▒██▓▓██▒▒▒▒\n▒▒▒▒▒▒██▒▒▒▒▒▒██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████████▒▒▒▒▒▒██▒▒▒▒▒▒\n▒▒▒▒▒▒██▒▒▒▒▒▒▓▓██████▒▒▒▒▓▓████████▓▓▒▒▒▒██████▓▓▒▒▒▒▒▒██▒▒▒▒▒▒\n▒▒▒▒▒▒██▒▒▒▒▒▒▒▒▓▓▓▓▒▒▒▒▓▓████  ██████▓▓▒▒▒▒▓▓▓▓▒▒▒▒▒▒▒▒██▒▒▒▒▒▒\n▒▒▒▒▒▒██▒▒    ▒▒▒▒▒▒▒▒▓▓████  ██████████▓▓▒▒▒▒▒▒▒▒    ▒▒██▒▒▒▒▒▒\n▒▒▒▒▒▒██░░░░░░░░▒▒▒▒▒▒████████████████████▒▒▒▒▒▒░░░░░░░░██▒▒▒▒▒▒\n▒▒▒▒▒▒██░░░░░░░░░░▒▒▒▒████████████████████▒▒▒▒  ░░░░░░░░██▒▒▒▒▒▒\n▒▒▒▒▒▒██░░░░  ░░▒▒▒▒░░▒▒████████████████▒▒░░▒▒▒▒░░    ░░██▒▒▒▒▒▒\n▒▒▒▒▒▒██            ░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ░░          ░░██▒▒▒▒▒▒\n▒▒▒▒▒▒    ▒▒▒▒▒▒░░░░  ░░░░            ░░░░  ░░  ▒▒▒▒▒▒    ▒▒▒▒▒▒\n▒▒    ▒▒██▒▒      ░░░░░░░░████████████░░░░░░░░      ▒▒██▒▒    ▒▒\n  ▒▒▒▒▒▒    ▒▒▒▒░░░░▒▒▒▒██▓▓▓▓▓▓▓▓▓▓▓▓██▒▒▒▒░░░░▒▒▒▒    ▒▒▒▒▒▒  \n▒▒▒▒    ▒▒██▒▒▒▒▒▒▒▒████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓████▒▒▒▒▒▒▒▒██▒▒    ▒▒▒▒\n▒▒  ▒▒▒▒▒▒▒▒██▒▒▒▒▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▒▒▒▒██▒▒▒▒▒▒▒▒  ▒▒\n▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████████▓▓▓▓▓▓▒▒▒▒▓▓▓▓▓▓██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒▒▒██▓▓▓▓▓▓▓▓▓▓████████████████▓▓▓▓▓▓▓▓▒▒██▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒▒▒██▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒██▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒██▒▒░░▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒  ░░▒▒██▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒██▒▒░░░░▒▒▓▓▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒░░░░░░▒▒██▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒██▒▒░░░░  ▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓▓▓▓▓▒▒  ▒▒▓▓██▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒██▓▓▓▓▒▒░░▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓▒▒  ░░▒▒▓▓▓▓██▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒██▓▓▓▓▒▒░░  ▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓░░  ░░░░  ▒▒▓▓██▒▒▒▒▒▒▒▒"
}

#list tools
--list(){
	printf "\neverything listed will be downloaded. #comment out in script to ignore certain repos.\n"
	printf "$gitList"
	printf "$langList"
	printf "$otherTools"
}

#download tools
#comment out unwanted tools as needed
--tools(){
	sudo apt update --yes
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source "$HOME/.cargo/env"
	cargo install x8
	pipx install git+https://github.com/Pennyw0rth/NetExec
	sudo mkdir /opt/tools;sudo chown $(whoami) /opt/tools;sudo chgrp $(whoami) /opt/tools
	git clone https://github.com/danielmiessler/SecLists.git /opt/tools/SecLists
	git clone https://github.com/carlospolop/Auto_Wordlists.git /opt/tools/Auto_Wordlists
	git clone https://github.com/nicocha30/ligolo-ng.git /opt/tools/ligolo-ng
	git clone https://github.com/flozz/p0wny-shell.git /opt/tools/p0wny-shell
	git clone https://github.com/carlospolop/phpwebshelllimited.git /opt/tools/phpwebshelllimited
	git clone https://github.com/mbechler/marshalsec /opt/tools/marshalsec;cd /opt/tools/marshalsec; mvn clean package -DskipTests
	git clone https://github.com/frohoff/ysoserial.git /opt/tools/ysoserial
	wget https://github.com/frohoff/ysoserial/releases/latest/download/ysoserial-all.jar -O /opt/tools/ysoserial/ysoserial-all.jar
	mkdir /opt/tools/jd-gui;mkdir /opt/tools/RunasCs
	wget https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.jar -O /opt/tools/jd-gui/jd-gui-1.6.6.jar
	wget https://github.com/antonioCoco/RunasCs/releases/latest/download/RunasCs.zip -O /opt/tools/RunasCs/RunasCs.zip;cd /opt/tools/RunasCs/; unzip RunasCs.zip
	aws configure set aws_access_key_id "AKIAIOSFODNN7EXAMPLE"
    aws configure set aws_secret_access_key "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    sudo apt install dirmngr ca-certificates gnupg
	sudo gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
	echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/debian stable-buster main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
	sudo apt update
	sudo apt install mono-devel --yes
	sudo apt-get install docker.io docker-compose-plugin --yes
	clear; printf "\nall downloads will be in /opt/tools/\n"

	if [[ $var3 == "--config-prompt" ]]
		then --config-prompt
	fi
}

$1 $2 $3 $4 $5

if [ -z $1 ]
	then --help
	exit
fi
