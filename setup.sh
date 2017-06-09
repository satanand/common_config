#!/bin/bash
PATH=`$PWD`
cd ~
mkidr -p ~/bin
ln -s $PATH/bin/* ~/bin/
ln -s $PATH/dircolors
ln -s $PATH/gitconfig_office .gitconfig
ln -s $PATH/.mailcap .mailcap
ln -s $PATH/.offlineimaprc .offlineimaprc
ln -s $PATH/vim/.vim  .vim
ln -s $PATH/vimrc .vimrc
ln -s $PATH/.tmux.conf .tmux.conf
mkidr -p ~/.mutt
cp -r $PATH/mutt/* ~/.mutt/
