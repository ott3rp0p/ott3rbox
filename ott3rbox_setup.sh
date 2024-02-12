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
otherTools="\n\n\e[36mOther Stuff:\033[0m\njd-gui\n\n"
id=$(whoami)

#probably unnecessary help menu with garbage text alignment
--help(){
	printf "🦦 🍭\n\n"
	if [ -z $1 ] 
		then printf "use this script to configure your pwnbox's appearance as well as download various tools\n\n--help:         script information. --help options for more\n--setup:        run by itself first to create files\n--config:       configure pwnbox. requires IPv4 address for target\n--conf-prompt:  use my terminal prompt. shows IP/User/Host/PWD\n--prompt-ex:    show example of promp appearance \n--tools:        download tools. use --tools-list to only list tools\n--otter:        print an otter\n\nexample:       ./ott3rbox_setup.sh --help config\nexample:       ./ott3rbox_setup.sh --config 10.129.16.182 --tools\n\n"
		exit
	elif [ $1 == "config" ]
		then printf "set pwnbox configurations for mate panel/desktop/terminal.\npulled from ~my_data/conf after --setup creates the files.\n\n"
		exit
	elif [ $1 == "setup" ]
		then printf "used to save mate settings for terminal/desktop/panel into ~/my_data/conf.\nyou'll only need to run this again if you update some settings that you want to change.\n\n" 
		exit
	elif [ $1 == "config-prompt" ]
		then printf "configure terminal prompt.\nwill copy old .zsrhc to ~/my_data/conf/zshrc.old\nuse --ex-prompt for an example of what it will look like\n\n"
		exit
	elif [ $1 == "ex-prompt" ]
		then printf "shows an example of my prompt\n\n"
		exit
	elif [ $1 == "tools" ]
		then printf "download tools from various web locations. review script for exact URIs\nuse --tools-list to view the tools the will be downloaded\n\n"
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
	printf "saving mate settings to ~/my_data/conf/*.conf\n"
	cp /home/$id/my_data/ott3rbox/panel.conf /home/$id/my_data/conf/panel.conf
	sed -i "s+changeme+$id+g" /home/$id/my_data/conf/panel.conf
	#dconf dump /org/mate/panel/ > /home/$id/my_data/conf/panel.conf
	dconf dump /org/mate/desktop/ > /home/$id/my_data/conf/bg.conf
	dconf dump /org/mate/terminal/profiles/default/ > /home/$id/my_data/conf/term.conf
	printf "creating ~/my_data/conf/tmux.conf\n"
	cp /home/$id/my_data/ott3rbox/tmux.conf /home/$id/my_data/conf/.tmux.conf
	printf "creating ~/my_data/conf/.zshrc\n"
	cp /home/$id/my_data/ott3rbox/zshrc /home/$id/my_data/conf/.zshrc
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
	printf "TUN: $(/opt/vpnbash.sh) " > /home/$id/my_data/conf/tun.txt
	printf "TARGET: $1"  > /home/$id/my_data/conf/target.txt
	dconf load /org/mate/panel/ < /home/$id/my_data/conf/panel.conf
	dconf load /org/mate/desktop/ < /home/$id/my_data/conf/bg.conf
	dconf load /org/mate/terminal/profiles/default/ < /home/$id/my_data/conf/term.conf
	
	#start tmux when opening terminal
	printf '\nif command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then\nexec tmux\nfi' >> /home/$id/.bashrc

	#copy conf files to home directory
	cp /home/$id/my_data/conf/.zshrc /home/$id/.zshrc
	cp /home/$id/my_data/conf/.tmux.conf /home/$id/.tmux.conf

	if [[ $2 == "--tools" ]]
		then --tools
	elif [[ $2 == "--tools-list" ]]
		then --tools-list
	else exit
	fi 
}

#set terminal prompt 
--config-prompt(){
	printf "\nbacking up current .zshrc to ~/my_data/conf/zshrc.old\n\n"
	cp /home/$id/.zshrc /home/$id/my_data/conf/zshrc.old
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
--tools-list(){
	printf "\neverything listed will be downloaded. #comment out in script to ignore certain repos.\n"
	printf "$gitList"
	printf "$langList"
	printf "$otherTools"
	exit
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
}

$1 $2 $3 

if [ -z $1 ]
	then --help
	exit
fi
