#!/bin/bash
MYPATH=$PWD
echo $MYPATH
cd ~
mkdir -p ~/bin
ln -s $MYPATH/bin/* ~/bin/
#ln -s $MYPATH/.dircolors
ln -s $MYPATH/gitconfig_office .gitconfig
#ln -s $MYPATH/.mailcap
#ln -s $MYPATH/.offlineimaprc
ln -s $MYPATH/vim/.vim
ln -s $MYPATH/vim/.vim/.vimrc
ln -s $MYPATH/.tmux.conf
#mkdir -p ~/.mutt
#cp -r $MYPATH/mutt/* ~/.mutt/
