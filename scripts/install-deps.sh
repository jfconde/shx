#!/bin/sh

UNAME="$(uname -s)"

install_prompt () {
    echo "About to try to download and install several tools for your system."
}

prompt_section () {
    read -p "Do you want to proceed ahead and install and/or configure $1? (Yn) " RESPONSE
        case $RESPONSE in
        [Yy]* ) LAST_PROMPT=0;;
        [Nn]* ) LAST_PROMPT=1;;
        * ) echo "Please answer yes or no. Aborted install of $1."; LAST_PROMPT=1;;
    esac
}

section_header () {
    echo "--------------------------------------------------------------------"
    echo "$1"
    echo "--------------------------------------------------------------------"
}

install_pkg () {
    echo "[$1] Trying to install package/s: $2"
    if [ "$1" = "Linux" ]
    then
        DIST="$(uname -a)"
        case "$DIST" in 
            *Ubuntu*)   sudo apt-get install $2;;
            *amzn*)     sudo yum install $2;;
            *)          echo "No known way to install packages in $DIST"; exit;;
        esac
    elif [ "$1" = "Mac" ]
    then
        brew install ${3:-$2}
        return 0
    fi
}

install_nvm () {
    section_header "nvm (node version manager)"
    prompt_section "nvm"
    if [ "$LAST_PROMPT" = 1 ]; then return; fi;
    
    if [ $(command -v curl &> /dev/null) ]
    then
        echo "Installing using installed curl."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    elif [ $(command -v wget &> /dev/null) ]
    then
        echo "Installing using installed wget."
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    else
        echo "No curl and no wget found. Trying to install curl and wget and re-running install."
        install_pkg $1 "curl wget"
        sleep 1
        install_nvm $1
    fi
}

install_rvm () {
    section_header "rvm (ruby version manager) - requires bash"
    prompt_section "rvm"
    if [ "$LAST_PROMPT" = 1 ]; then return; fi;

    if [ ! $(command -v bash &> /dev/null) ]
    then
        install_pkg $1 "bash"
        sleep 1
        install_rvm $1
    fi

    if [ $(command -v gpg &> /dev/null) ]
    then
        gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    else
        install_pkg $1 "gpg" "gnupg"
        sleep 1
        install_rvm $1
    fi

    if [ $(command -v curl &> /dev/null) ]
    then
        echo "Installing using installed curl."
        curl -sSL https://get.rvm.io | /bin/bash -s stable
    else
        echo "No curl. Trying to install curl and re-running install."
        install_pkg $1 "curl"
        sleep 1
        install_rvm $1
    fi 
}

install_git () {
    section_header "git (version control system)"
    if [ ! $(command -v bash &> /dev/null) ]
    then
        prompt_section "git"
        if [ "$LAST_PROMPT" = 1 ]; then return; fi;

        if [ "$1" != "Mac" ]
        then
            install_pkg "git"
        fi
    else
        echo "git is installed. trying to run it to trigger possible activation if never run in Mac."
        $(git version 2>/dev/null)
    fi
}

case "${UNAME}" in
    Linux*)     OS_NAME=Linux;;
    Darwin*)    OS_NAME=Mac;;
    *)          OS_NAME=""
esac

if [ -n $OS_NAME ]
then
    install_prompt
    install_nvm $OS_NAME
    install_rvm $OS_NAME
    install_git $OS_NAME
else
    echo "OS Family \($OS_NAME\) not recognized."
fi

