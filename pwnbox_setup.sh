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
toolList="rust\nNetExec\nx8\nLigolo-ng\np0wny-shell\nphpwebshelllimited"
id=$(whoami)

#garbage text alignment but not bothering with it
--help(){
	printf "🦦 🍭\n"
	if [ -z $1 ] 
		then printf "\n--help:         script information. --help options for more\n--setup:        run by itself first to create files\n--config:       configure pwnbox. requires IPv4 address for target\n--conf-prompt:  use my terminal prompt. shows IP/User/Host/PWD\n--prompt-ex:    show example of promp appearance \n--tools:        download tools. use --tools-list to only list tools\n--otter:        print an otter\n\nexample:       ./pwnbox-setup.sh --help config\nexample:       ./pwnbox-setup.sh --config 10.129.16.182 --tools"
		exit

	elif [ $1 == "config" ]
		then printf "set pwnbox configurations for mate panel/desktop/terminal. pulled from ~my_data/conf after setup creates the files"
		exit
	elif [ $1 == "setup" ]
		then printf "after you set your terminal preferences, background image, and panel settings the setup option should be run. it will create or pull the necessary files to ~/my_data/conf/ which will then be saved for future use. you'll only need to run this again if you update some settings that you want to change"
		exit
	fi
}

#setup files for future use
--setup(){
	printf "you will only need to run this the first time. afterwards anytime you start your pwnbox just run --config"
	mkdir /home/$id/my_data/conf
	dconf dump /org/mate/panel/ > /home/$id/my_data/conf/panel.conf
	dconf dump /org/mate/desktop/ > /home/$id/my_data/conf/bg.conf
	dconf dump /org/mate/terminal/profiles/default/ > /home/$id/my_data/conf/term.conf
	printf "#set shell\nset -g default-shell /bin/zsh" > /home/$id/my_data/conf/.tmux.conf
	#upload own zshrc so don't have to use a random one
	curl https://gist.githubusercontent.com/noahbliss/4fec4f5fa2d2a2bc857cccc5d00b19b6/raw/db5ceb8b3f54b42f0474105b4a7a138ce97c0b7a/kali-zshrc > /home/$id/my_data/conf/.zshrc                              
}

#configure everything but terminal prompt
--config(){
	#validate IPv4 format
	if [ -z $1 ]
		then printf "needs a target IP"
		exit
	elif [[ $1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
		then :
	else printf "not a valid IPv4 format"
	exit	
	fi

	#configure appearance of panel/terminal/background
	printf "TUN: $(/opt/vpnbash.sh) " > /home/$id/my_data/conf/tun.txt
	printf "TARGET: $1"  > /home/$id/my_data/conf/target.txt
	dconf load /org/mate/panel/ < /home/$id/my_data/conf/panel.conf
	dconf load /org/mate/desktop/background/ < /home/$id/my_data/conf/bg.conf
	dconf load /org/mate/terminal/profiles/default/ < /home/$id/my_data/conf/term.conf
	
	#start tmux when opening terminal
	printf '\nif command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then\nexec tmux\nfi' >> /home/$id/.bashrc

	#copy conf files to home directory
	cp /home/$id/my_data/conf/.zshrc /home/$id/.
	cp /home/$id/my_data/conf/.tmux.conf /home/$id/.

	if [[ $2 == "--tools" ]]
		then --tools
	elif [[ $2 == "--tools-list" ]]
		then --tools-list
	else exit
	fi 
}

#set terminal prompt 
--conf-prompt(){
	sed -i 's+configure_prompt().*}+configure_prompt() {\n    #case\n            PROMPT="%F{red}┌%f%F{red}[%f%F{cyan}%D{$(/opt/vpnbash.sh)}%f%F{red}]─[%B%F{%(#.red.green)}%n%(#.💀.  🦦 )%m%b%F{%(#.blue.red)}]─[%f%F{magenta}%d%f%F{red}]%f"$'\n'"%F{red}└╼%f%F{green}[%f%F{yellow}%f%F{yellow} $%f"\n    #esac\n}+g' /home/$id/.zshrc
}
--prompt-ex(){
	printf "\n\e[31m┌[\e[36m10.10.14.84\e[31m]─[\e[92mott3rp0p 🦦 htb-1hcye3hbvf\e[31m]─[\e[35m/home/ott3rp0p/my_data\e[31m]
└╼[\e[33m$\n\n"
}

#download tools
--tools(){
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	cargo install x8
	pipx install git+https://github.com/Pennyw0rth/NetExec
	sudo git clone https://github.com/danielmiessler/SecLists.git /opt/SecLists
	sudo git clone https://github.com/carlospolop/Auto_Wordlists.git /opt/Auto_Wordlists
	sudo git clone https://github.com/nicocha30/ligolo-ng.git /opt/ligolo-ng
	sudo git clone https://github.com/flozz/p0wny-shell.git /opt/p0wny-shell
	sudo git clone https://github.com/carlospolop/phpwebshelllimited.git /opt/phpwebshelllimited
}

#list tools
--tools-list(){
	printf "$toolList"
	exit
}

#print an otter
--otter(){
	printf "▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████████▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒██▓▓▓▓██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██▓▓▓▓██▒▒▒▒▒▒\n▒▒▒▒██▓▓▓▓██▒▒▒▒▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▒▒▒▒██▓▓▓▓██▒▒▒▒\n▒▒▒▒██▓▓██▒▒▒▒▓▓████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒████████▓▓▒▒▒▒██▓▓██▒▒▒▒\n▒▒▒▒██▓▓██▒▒▒▒██  ██████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██  ██████▒▒▒▒██▓▓██▒▒▒▒\n▒▒▒▒▒▒██▒▒▒▒▒▒██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████████▒▒▒▒▒▒██▒▒▒▒▒▒\n▒▒▒▒▒▒██▒▒▒▒▒▒▓▓██████▒▒▒▒▓▓████████▓▓▒▒▒▒██████▓▓▒▒▒▒▒▒██▒▒▒▒▒▒\n▒▒▒▒▒▒██▒▒▒▒▒▒▒▒▓▓▓▓▒▒▒▒▓▓████  ██████▓▓▒▒▒▒▓▓▓▓▒▒▒▒▒▒▒▒██▒▒▒▒▒▒\n▒▒▒▒▒▒██▒▒    ▒▒▒▒▒▒▒▒▓▓████  ██████████▓▓▒▒▒▒▒▒▒▒    ▒▒██▒▒▒▒▒▒\n▒▒▒▒▒▒██░░░░░░░░▒▒▒▒▒▒████████████████████▒▒▒▒▒▒░░░░░░░░██▒▒▒▒▒▒\n▒▒▒▒▒▒██░░░░░░░░░░▒▒▒▒████████████████████▒▒▒▒  ░░░░░░░░██▒▒▒▒▒▒\n▒▒▒▒▒▒██░░░░  ░░▒▒▒▒░░▒▒████████████████▒▒░░▒▒▒▒░░    ░░██▒▒▒▒▒▒\n▒▒▒▒▒▒██            ░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ░░          ░░██▒▒▒▒▒▒\n▒▒▒▒▒▒    ▒▒▒▒▒▒░░░░  ░░░░            ░░░░  ░░  ▒▒▒▒▒▒    ▒▒▒▒▒▒\n▒▒    ▒▒██▒▒      ░░░░░░░░████████████░░░░░░░░      ▒▒██▒▒    ▒▒\n  ▒▒▒▒▒▒    ▒▒▒▒░░░░▒▒▒▒██▓▓▓▓▓▓▓▓▓▓▓▓██▒▒▒▒░░░░▒▒▒▒    ▒▒▒▒▒▒  \n▒▒▒▒    ▒▒██▒▒▒▒▒▒▒▒████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓████▒▒▒▒▒▒▒▒██▒▒    ▒▒▒▒\n▒▒  ▒▒▒▒▒▒▒▒██▒▒▒▒▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▒▒▒▒██▒▒▒▒▒▒▒▒  ▒▒\n▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████████▓▓▓▓▓▓▒▒▒▒▓▓▓▓▓▓██████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒▒▒██▓▓▓▓▓▓▓▓▓▓████████████████▓▓▓▓▓▓▓▓▒▒██▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒▒▒██▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒██▒▒▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒██▒▒░░▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒  ░░▒▒██▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒██▒▒░░░░▒▒▓▓▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒░░░░░░▒▒██▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒▒▒██▒▒░░░░  ▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓▓▓▓▓▒▒  ▒▒▓▓██▒▒▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒██▓▓▓▓▒▒░░▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓▒▒  ░░▒▒▓▓▓▓██▒▒▒▒▒▒▒▒\n▒▒▒▒▒▒▒▒██▓▓▓▓▒▒░░  ▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▓▓░░  ░░░░  ▒▒▓▓██▒▒▒▒▒▒▒▒"
}

$1 $2 $3 

if [ -z $1 ]
	then --help
fi
