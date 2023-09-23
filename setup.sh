#!/bin/bash
MYPATH=$PWD
echo $MYPATH
cp $MYPATH/gitconfig_personal ~/.gitconfig
cp $MYPATH/.tmux.conf ~/.tmux.conf
cp $MYPATH/init.vim ~/config/nvim/
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
apt install build-essential cmake vim-nox python3-dev
apt install  golang
cd ~/.local/share/nvim/plugged/YouCompleteMe
python3 install.py
