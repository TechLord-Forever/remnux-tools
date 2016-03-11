#!/bin/bash

set -e

[[ -e ~/remnux-tools/bin/common.sh ]] && . ~/remnux-tools/bin/common.sh || exit "Cant find common.sh."

fix-apt-google

sudo apt-get update && sudo apt-get -y dist-upgrade

# General tools
sudo apt-get -y -qq install ctags curl git vim vim-doc vim-scripts \
    exfat-fuse exfat-utils zip

# Tools for Vmware
sudo apt-get -y -qq install open-vm-tools-desktop fuse

if [ ! -d ~/src ]; then
    mkdir -p ~/src/bin
fi

if [ ! -d ~/src/git ]; then
    mkdir -p ~/src/git
fi

if [ ! -d ~/cases ]; then
    mkdir -p ~/cases/docker
fi

for dir in pescanner radare2 mastiff thug v8 viper; do
    if [ ! -d ~/cases/docker/$dir ]; then
        mkdir ~/cases/docker/$dir
        chmod 777 ~/cases/docker/$dir
    fi
done

# Install Remnux
if [[ ! -e ~/.config/.remnux ]]; then
    wget --quiet -O - https://remnux.org/get-remnux.sh | sudo bash
    touch ~/.config/.remnux
fi

# Install Sift
if [[ ! -e ~/.config/.sift ]]; then
    wget --quiet -O - https://raw.github.com/sans-dfir/sift-bootstrap/master/bootstrap.sh | sudo bash -s -- -i -s -y
    touch ~/.config/.sift
fi

# Install Chrome
if ! dpkg --status google-chrome-stable > /dev/null 2>&1 ; then
    cd /tmp
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb || true
    sudo apt-get -f -y install
    fix-apt-google
    rm -f google-chrome-stable_current_amd64.deb
fi

# This repo contians newer versions of Wireshark etc. Update again after adding
if [[ ! -e /etc/apt/sources.list.d/pi-rho-security-trusty.list ]]; then
    sudo add-apt-repository -y ppa:pi-rho/security
    sudo apt-get update && sudo apt-get -y dist-upgrade
    sudo apt-get install html2text nasm && sudo apt-get autoremove -y
fi

# Clean up
if [[ -e ~/examples.desktop ]]; then
    rm -f ~/examples.desktop
fi
if [[ -e ~/Desktop/SANS-DFIR.pdf ]]; then
    echo "Clean Desktop."
    mkdir ~/Documents/Remnux_SIFT
    mv ~/Desktop/REMnux* ~/Documents/Remnux_SIFT/
    mv ~/Desktop/*.pdf ~/Documents/Remnux_SIFT/
    rm -f ~/Desktop/cases
fi

# Add scripts from different sources
# http://phishme.com/powerpoint-and-custom-actions/
[ ! -e ~/src/bin/psparser.py ] && wget -q -O ~/src/bin/psparser.py \
    https://github.com/phishme/malware_analysis/blob/master/scripts/psparser.py && \
    chmod +x ~/src/bin/psparser.py && \
    info-message "Installed psparser.py"
# https://zeltser.com/convert-shellcode-to-assembly/
[ ! -e ~/src/bin/shellcode2exe.py ] && wget -q -O ~/src/bin/shellcode2exe.py \
    https://raw.githubusercontent.com/MarioVilas/shellcode_tools/master/shellcode2exe.py && \
    chmod +x ~/src/bin/shellcode2exe.py && \
    info-message "Installed shellcode2exe.py"
# https://www.virustotal.com/en/documentation/public-api/#getting-file-scans
[ ! -e ~/src/bin/vt.py ] && wget -q -O ~/src/bin/vt.py \
    https://raw.githubusercontent.com/Xen0ph0n/VirusTotal_API_Tool/master/vt.py && \
    chmod +x ~/src/bin/vt.py && \
    info-message "Installed vt.py"
# https://testssl.sh/
[ ! -e ~/src/bin/testssl.sh ] && wget -q -O ~/src/bin/testssl.sh \
    https://testssl.sh/testssl.sh && \
    chmod +x ~/src/bin/testssl.sh && \
    info-message "Installed testssl.sh"

# Add git repos
# http://www.tekdefense.com/automater/
[ ! -d ~/src/git/TekDefense-Automater ] && \
    git clone --quiet https://github.com/1aN0rmus/TekDefense-Automater.git \
    ~/src/git/TekDefense-Automater && \
    info-message "Checked out Automater,"

# https://github.com/keydet89/RegRipper2.8
[ ! -d ~/src/git/RegRipper2.8 ] && \
    git clone --quiet https://github.com/keydet89/RegRipper2.8.git \
    ~/src/git/RegRipper2.8 && \
    info-message "Checked out RegRipper2.8," && \
    cp ~/remnux-tools/files/regripper2.8 ~/src/bin/regripper2.8 && \
    chmod 755 ~/src/bin/regripper2.8

# Info manual config
if [[ ! -e ~/.config/.manual_conf ]]; then
    echo "##################################################################"
    echo "Remember to change the following things:"
    echo "1. Change desktop resolution to be able to do the other steps."
    echo "2. Security & Privacy -> Search -> Turn of online search results."
    echo "3. -> Diagnotstics -> Turn of error reports."
    echo "4. Change Desktop Background :)"
    echo "Run make in ~/remnux-tools for .bashrc etc."
    echo "##################################################################"
    touch ~/.config/.manual_conf
fi

