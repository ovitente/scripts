#!/bin/bash

# Colors
RED=$(tput setaf 1)
GRN=$(tput setaf 2)
YLW=$(tput setaf 3)
BL=$(tput setaf 4)

REDB=$(tput setaf 1)$(tput bold)
GRNB=$(tput setaf 2)$(tput bold)
YLWB=$(tput setaf 3)$(tput bold)
BLB=$(tput setaf 4)$(tput bold)
BOLD=$(tput bold)
NRML=$(tput sgr0)

grn_a="${GRNB}*${NRML}"
red_a="${REDB}*${NRML}"
bl_a="${BLB}*${NRML}"
ok="$GRNB""[ OK ]""$NRML"
fail="$REDB""[ FAIL ] ""$NRML"

key_length="2048"
key_type="ed25519"

colored_msg() {
    MSG="$1"
    #    let COL=$(tput cols)-$MSG+$GRNB+$NRML
    let COL=$(tput cols)
    printf "%s%${COL}s\n" "$GRNB[OK]$NRML" "$MSG"
}

center(){
    textsize=${#1}
    width=$(tput cols)
    span=$((($width + $textsize) / 2))
    printf "%${span}s\n" "$1"
}
liner() {
    cols=$(tput cols)
    for ((i=0; i<cols; i++));do printf "-"; done; echo
}
#------------------------------


# Check theese tools: nmap
# ======== VARIABLES ========
function ifx7 {
# if [[ -d $HOME/x7 ]]; then
  if [[ -d $HOME/NEVER ]]; then
    ssh_dir="$HOME/x7/dist/linux/configs/ssh"
    ln -s $HOME/x7/dist/linux/configs/ssh/$key $HOME/.ssh/$key
    ln -s $HOME/x7/dist/linux/configs/ssh/$key.pub $HOME/.ssh/$key.pub
  else
    ssh_dir="$HOME/.ssh"
  fi
}

ssh_config="$HOME/.ssh/config"
tail_lines="7"

function usage {
  if [ -z "$hello" ]; then
    printf "%1s ${YLWB}Usage: ${NRML} sshkeygen ${REDB}-n${NRML} <server-alias name> ${REDB}-l${NRML} <remote login> ${REDB}-s${NRML} <server domain/ip> ${REDB}-p${NRML} <port> (empty for defalut 22)\n"
    exit 1
  fi
}

while getopts n:l:s:p: option
do
case "${option}" in
n) key=${OPTARG};;
l) login=${OPTARG};;
s) server=${OPTARG};;
p) port=$OPTARG;;
*) usage;;
esac
done

function ManualDataGet {
    printf "%1s${BOLD}This script generates ssh key and transfers it to remote server.${NRML}\n\n"

    printf "%1s${BOLD}Enter server name alias: ${NRML}${GRNB}"
    read key
    printf "$NRML"

    printf "%1s${BOLD}Enter login ( or leave for current "$USER"): ${NRML}${GRNB}"
    read login
    printf "$NRML"

    printf "%1s${BOLD}Enter server ip or domain: ${NRML}${GRNB}"
    read server
    printf "$NRML"

    printf "%1s${BOLD}Enter server port(default 22): ${NRML}${GRNB}"
    read port
    printf "$NRML"
    #re='^[0-9]+$'

}

function DataCheck {
    if [ -z "$key" ]; then
        printf "%1s${RED}Server name is not defined${NRML}\n"
        usage
        exit 1
    fi

    if [ -z "$port" ]; then
        port="22"
        printf "%1s${YLW}Port is not defined Using default${NRML} [ 22 ]\n"
        let tail_lines-=1
    fi

    if [ -z "$server" ]; then
        printf "%1s${RED}Server domain/IP is not defined${NRML}\n"
        usage
        exit 1
    fi

    if [ -z "$login" ]; then
        printf "%1s${YLW}Username is not defined, using${NRML} [ $USER ]\n"
        login="$USER"
        let tail_lines-=1
    fi
}

function PreCheckShowData {
    cols=$(tput cols)
    for ((i=0; i<cols; i++));do printf "="; done; echo
    printf "%1s${BOLD}Please check data.${NRML}\n\n"
    printf "%1sServer name: [ ${GRNB}$key${NRML} ]\n"
    printf "%1sServer username: [ ${GRNB}$login${NRML} ]\n"
    printf "%1sServer address: [ ${GRNB}$server${NRML} ]\n"
    printf "%1sServer port: [ ${GRNB}$port${NRML} ]\n"
    printf "%1sConnection string: [ ${GRNB}${login}@${server}:${port}${NRML} ]\n\n"
    liner
    printf "%1s${BOLD}If everyhing is ok - pres any key. If else - hit ${REDB}^C${NRML}${NRML}"
    read anykey
    for ((i=0; i<cols; i++));do printf "="; done; echo

}

function CheckConnection {
    printf "%1s${BOLD}Checking server connection via nmap open ssh port: ${NRML}"
    access=$(nmap $server -PN -p $port ssh 2>/dev/null | egrep 'open|closed|filtered' | awk '{ print $2 }')
    if [[ "$access" = open ]]; then
        printf "%0s${GRNB}OK${NRML}\n"
        connection="ok"
    else
        printf "%0s${REDB}FAIL${NRML}\n"
        connection="fail"
        printf "%1s${YLWB}Cannot connect to selected server. Should i proceed and write to config anyway? y/n: ${NRML}"
        read answer
        case $answer in
          y) echo "Proceeding." ;;
          n)
            echo "Exit."
            exit 1 ;;
        esac
    fi
}

function KeyGeneration {
  ifx7
    printf "%1s${BOLD}Generating key: ${NRML}"
    if [ -f "$ssh_dir/$key" ]; then
        printf "%1s${YLWB}SSH key is already exist. Press any key to generate new.${NRML}\n"
        read anykey
    fi

    ssh-keygen -t ${key_type} -b ${key_length} -C "${login}@${server}" -f $ssh_dir/$key # > /dev/null 2>&1;

    if [ -f "$ssh_dir/$key" ]; then
        printf "%0s${GRNB}DONE${NRML}\n"
    else
        printf "%0s${REDB}FAIL. KEY HAS NOT BEED GENERATED. EXIT.${NRML}\n"
        exit 1
    fi
}

function CopyKeyToRemoteServer {
    printf "%1s${BOLD}Copying key to the server: ${NRML}\n"
    if [ $connection = "ok" ]; then
      printf "%1s${YLWB}Please enter your "
      ssh-copy-id -i $ssh_dir/${key}.pub -p ${port} ${login}@${server} > /dev/null 2>&1 || printf "%1sSomething gone wrong. Check permissions on remote ~/.ssh/ and authorized_keys"
      printf "\n%1s${NRML}${BOLD}Now you can try 'ssh ${key}'\n"
    else
      printf "\n%1s${YLW}Connection to server was not established.\n You need to copy ${key}.pub to the servers /home/\$USER/.ssh/authorized_keys manualy.\n Then you will be able to use 'ssh ${key}'${NRML}\n"

    fi
}

function WriteToConfig {
    host_name=$key
    printf "${NRML}"
    printf "Host $host_name\n" >> $ssh_config
    printf "%2sHostname $server\n" >> $ssh_config

    if ! [ "$login" = $USER ]; then
        printf "%2sUser $login\n" >> $ssh_config
    fi

    if ! [ "$port" = 22 ]; then
        printf "%2sPort $port\n" >> $ssh_config
    fi

    printf "  PasswordAuthentication no\n" >> $ssh_config
    ssh_dir="$HOME/.ssh"
    printf "%2sIdentityFile $ssh_dir/$key\n\n" >> $ssh_config

    if ! [ -f $ssh_config ]; then
      printf "\n%1s Cant write to $ssh_config. Exit."
      exit 1
    fi

    printf "\n%1s${BOLD}SSH key${NRML}${GRNB} [${NRML}$key${GRNB}]${NRML} with hostname ${GRNB}[${NRML}$host_name${GRNB}]${NRML}${BOLD} has been created, and added to ${ssh_config}. as ${NRML}\n"
    liner
    printf "%1s${GRN}$(tail -n $tail_lines $ssh_config)${NRML}\n"
    liner
}

DataCheck
PreCheckShowData
CheckConnection
KeyGeneration
WriteToConfig
CopyKeyToRemoteServer
