#!/bin/bash
#
# Home Environment Settings
#

if test "$(id -u)" == 0; then
  echo -e "\e[91mERROR (!) Required: id != 0\e[0m"
  exit 1
fi

usage()
{
cat << EOF
Usage: $(basename $0) [OPTION]...
Home Environment Settings. Manjaro Linux, Pacman

  [option]
  mc             midnight commander settings
  vim            vimrc + plugins
  home           removing unneeded directories from home
  bashrc         bashrc addition useful lines (export / alias)
  hotkeys        configuration favorite hotkeys (xfce)
  packages       installation favorite packages (pacman)
  help           print this help and exit

EOF
}

check_status()
{
  if [ $? != 0 ]; then
    echo -e "\e[91mSomething went wrong\e[0m"
    exit 1
  fi
}

mc_conf()
{
  if test "$(pacman -Q | grep ^mc)"; then
    # check dirs and create if not exist
    test ! -e $HOME/.config/mc && mkdir $HOME/.config/mc
    sudo test ! -e /root/.config/mc && sudo mkdir /root/.config/mc
    # copy ready configs
    cp configs/mc/*ini $HOME/.config/mc
    sudo cp configs/mc/*ini /root/.config/mc
    [ $? == 0 ] && echo -e "\e[93mMidnight commander updated\e[0m"
  else
    echo -e "\e[91mMidnight Commander not exist\e[0m"
  fi
  check_status
}

vim_conf()
{
  vim_plug_link=https://github.com/junegunn/vim-plug
  vim_plug_path=$HOME/.vim/autoload/plug.vim
  ready_vimrc=configs/etc/vimrc.file

  # plug.vim
  if test "$(pacman -Q | grep ^curl)"; then
    if test -e $vim_plug_path; then
      echo -e "\e[93m$vim_plug_path ready exist\e[0m"
    else
      echo && curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      [ $? == 0 ] && echo -e "\e[93m$vim_plug_path successfully created\e[0m"
    fi

    # .vimrc + plugins
    if test -e $ready_vimrc; then
      cat $ready_vimrc > $HOME/.vimrc
      sleep 1 && vim +PlugInstall
      [ $? == 0 ] && echo -e "\e[93m$HOME/.vimrc updated\e[0m"
    else
      echo -e "\e[91m$ready_vimrc not exist\e[0m"
    fi
  else
    echo -e "\e[91mPlease install curl before plugins installation\e[0m"
  fi
  check_status
}

home_conf()
{
  trash_dirs=(Видео Музыка Общедоступные Шаблоны Документы)
  for dir in ${trash_dirs[*]}; do
    if test -e $HOME/$dir; then
      rm -ri $HOME/$dir && echo -e "\e[93m$dir removed\e[0m"
    fi
  done
  check_status
}

bashrc_extra_here_doc()
{
cat << EOF >> ~/.bashrc

# Common
export HISTCONTROL=ignoredups
export EDITOR='/usr/bin/vim'
export PATH=$HOME/main/bin:"\$${!PATH@}"
export LANG=en_US.utf8
alias _date='date +"%d/%m/%Y - %H:%M:%S"'

EOF
}

bashrc_conf()
{
  if test "$(cat $HOME/.bashrc | grep "# Common")"; then
    echo -e "\e[93m$HOME/.bashrc update done\e[0m"
  else
    bashrc_extra_here_doc
    [ $? == 0 ] && echo -e "\e[93m$HOME/.bashrc successfully updated\e[0m"
  fi
  check_status
}

hotkeys_conf()
{
  keyconf=configs/etc/xfce4-keyboard-shortcuts.xml
  homeconf=$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml

  if test -e $keyconf; then
    cat $keyconf > $homeconf
    [ $? == 0 ] && echo -e "\e[93m$homeconf successfully updated\e[0m"
  else
    echo -e "\e[91m$keyconf not exist\e[0m"
  fi
  check_status
}

packages_conf()
{
  # init 'packages' list
  packages=(dnsutils traceroute whois tcpdump nmap curl ripgrep \
  netcat net-tools gcc make gdb bat vim nano xsel mc strace pv moreutils)

  sudo pacman -Syy
  # loop installation
  for pack in ${packages[*]}; do sudo pacman -S $pack --noconfirm; done
  check_status
}

case $1 in
  "mc") mc_conf ;;
  "vim") vim_conf ;;
  "home") home_conf ;;
  "bashrc") bashrc_conf ;;
  "hotkeys") hotkeys_conf ;;
  "packages") packages_conf ;;
  "help") usage ;;

  *)
    read -p "Ready to configurations?(y/n) " answer
    if [ "$answer" == "y" ] || [ "$answer" == "Y" ]; then
      packages_conf
      home_conf
      mc_conf
      vim_conf
      bashrc_conf
      hotkeys_conf
    fi
  ;;
esac


