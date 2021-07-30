#!/bin/bash

target=$1
name=$2
targetOs=$3
vpnConfig=$4

if (($#==4));
then

  ## Create & configure directory
  mkdir -p ~/HackSpace/$name
  mkdir -p ~/HackSpace/$name/recon
  mkdir -p ~/HackSpace/$name/loot
  mkdir -p ~/HackSpace/$name/exploits
  cp $vpnConfig ~/HackSpace/$name/htb-vpn.ovpn

  ## Create notes
  echo "# Name: $name" >> ~/HackSpace/$name/notes.md
  echo "# IP: $target" >> ~/HackSpace/$name/notes.md
  echo "# TargetOS: $targetOs" >> ~/HackSpace/$name/notes.md
  echo "# Level:" >> ~/HackSpace/$name/notes.md
  echo "#" >> ~/HackSpace/$name/notes.md

  ## Create session
  cd ~/HackSpace/$name
  export target
  export targetOs
  export name

  ## Create Tmux Session
  tmux new -s $name -d
  tmux rename-window -t $name VPN
  tmux split-window -v -t VPN
  tmux split-window -h -t $name:VPN.0
  tmux new-window -d -t $name -n NOTES
  tmux new-window -d -t $name -n RECON
  tmux split-window -h -t $name:RECON.0
  tmux split-window -v -t $name:RECON.1
  tmux split-window -v -t $name:RECON.0

  ## Running Commands
  tmux send-keys -t $name:VPN.0 'sudo openvpn htb-vpn.ovpn' 

  tmux send-keys -t $name:RECON.0 'nmap -sC -sV -oN recon/initial_nmap.txt -v -Pn $target' 
  tmux send-keys -t $name:RECON.1 'sudo masscan -p1-65535 -e tun0 -oL recon/allports.txt --rate=1000 -vv -Pn $target'
  tmux send-keys -t $name:RECON.2 'gobuster dir -u http://$target -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o recon/dirscan.txt'
  tmux send-keys -t $name:RECON.2 '/opt/ffuf -w /usr/share/wordlists/dirb/big.txt -u http://$target/FUZZ | tee recon/ffuf.txt' 

  tmux send-keys -t $name:NOTES 'vi notes.md'

else
  echo "Usage: ./htb-recon.sh <IP> <Name_of_Machine> <OS> <Path to VPN Config>"
  echo "Example: ./workspace.sh 10.10.10.180 ServMon Windows ../starting_point.ovpn"

fi
