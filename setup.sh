#!/bin/bash
MYPATH=$PWD
echo $MYPATH
cd ~
mkdir -p ~/bin
ln -s $MYPATH/bin/* ~/bin/
ln -s $MYPATH/gitconfig_personal .gitconfig
ln -s $MYPATH/vim/.vim
ln -s $MYPATH/vim/.vim/.vimrc
ln -s $MYPATH/.tmux.conf
