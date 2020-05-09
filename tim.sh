#!/usr/bin/env bash

install(){
  if ! [ -x "$(command -v docker)" ]; then
    echo 'Error: docker is not installed.' >&2
    exit 1
  fi
  [ -n ~/.local/bin/ ] && mkdir -p ~/.local/bin/
  p=$(grep ~/.local/bin: ~/.bashrc)
  [ -n $p ] && echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> ~/.bashrc && source ~/.bashrc
  p=$(grep ~/.local/bin: ~/.zshrc)
  [ -n $p ] && echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> ~/.zshrc && source ~/.zshrc
  [ -n ~/.local/share/icons/hicolor/256x256/apps ] && mkdir -p ~/.local/share/icons/hicolor/256x256/apps

  if ! [ -x ~/.local/bin/tim.sh ]; then
    echo 'Install this script to ~/.local/bin/tim.sh' >&2
    cp $0 ~/.local/bin/tim.sh
    sed -i -r -e 's/^\s*remove.*install$/start/g' ~/.local/bin/tim.sh
    chmod +x ~/.local/bin/tim.sh
    ln -i ~/.local/bin/tim.sh ~/.local/bin/tim
    QQ_P=/home/$(whoami)/.local/bin/tim.sh
	cp tim.png ~/.local/share/icons/hicolor/256x256/apps/WINE_TIM.png
    cat <<-EOF > /home/$(whoami)/.local/share/applications/TIM.desktop
[Desktop Entry]
Categories=Network;InstantMessaging;
Exec=${QQ_P}
Icon=/home/$(whoami)/.local/share/icons/hicolor/256x256/apps/WINE_TIM.png
Name=TIM
NoDisplay=false
StartupNotify=true
Terminal=0
Type=Application
Name[en_US]=TIM
EOF
  start
  else
    echo "already installed at ~/.local/bin/tim.sh"
  fi
  return 0
}

remove(){
  [ -e ~/.local/bin/tim.sh ] && rm -f ~/.local/bin/tim.sh && echo "remove ~/.local/bin/tim.sh"
  [ -e ~/.local/bin/tim ] && rm -f ~/.local/bin/tim

  [ -e ~/.local/share/icons/hicolor/256x256/apps/WINE_TIM.png ] \
  && rm -f ~/.local/share/icons/hicolor/256x256/apps/WINE_TIM.png\
  && echo "remove ~/.local/share/icons/hicolor/256x256/apps/WINE_TIM.png"


  [ -e /home/$(whoami)/.local/share/applications/TIM.desktop ] \
  && rm -f /home/$(whoami)/.local/share/applications/TIM.desktop \
  && echo "remove ~/.local/share/applications/TIM.desktop"

  return 0
}
removei(){
  clean
  imgs=$(docker images | awk '$1 ~ /hoking\/tim/ {print $3}')
  [[ -n $imgs ]] && docker rmi $imgs
  return 0
}

clean(){
  container_ids=$(docker ps -a | awk  'NR!=1 && $2 ~ /hoking\/tim/ {print $1}')
  if [[ -n "$container_ids" ]]; then
    docker container rm -f $container_ids
  fi
  return 0
}

update(){
  clean
  remove && install
  return 0
}

startContainer(){
  arg='--name script_tim'
  if [[ "$1" == "instance" ]]; then
    arg='--rm'
  fi
  docker container run -d ${arg} \
    --device /dev/snd \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
    -v $HOME:$HOME \
    -v $HOME/TencentFiles:/TencentFiles \
    -e DISPLAY=unix$DISPLAY \
    -e XMODIFIERS=@im=fcitx \
    -e QT_IM_MODULE=fcitx \
    -e GTK_IM_MODULE=fcitx \
    -e AUDIO_GID=`getent group audio | cut -d: -f3` \
    -e VIDEO_GID=`getent group video | cut -d: -f3` \
    -e GID=`id -g` \
    -e UID=`id -u` \
	-e DPI=120 \
    hoking/tim
  return 0
}

start(){
  container_id=$(docker ps -a | grep script_tim | awk  '$2 ~ /hoking\/tim/ {print $1}')
  if [[ -z "$container_id" ]]; then
    startContainer
  else
    container_stat=$(docker ps | grep script_tim | awk  '$2 ~ /hoking\/tim/ {print $1}')
    if [ -z "$container_stat" ]; then
      docker container start ${container_id}
    else
      docker container exec -d ${container_id} /entrypoint.sh
    fi
  fi
  return 0
}

starti(){
  startContainer instance
  return 0
}

help(){
  echo "tim [-h] [-i] [-f] [-c] [--start|start] [--remove] [--instance]"
  echo "  -h, --help            Show help"
  echo "  -i, --install         Install this script to system"
  echo "  -f, --force           Force install or reinstall"
  echo "  -c, --clean           Clean all tim container"
  echo "      --start           Start tim"
  echo "      --update          Update script"
  echo "      --remove          Remove this script"
  echo "      --instance        Create a instance tim container, you can create more then one using this option"
  return 0
}


REMOVE=''
INSTALL=''
REINSTALL=''
HELP=""
INSTANCE=""
CLEAN=""
UPDATE=""
START=""
while [[ $# > 0 ]];do
  key="$1"
  case $key in
      -i|--install)
      INSTALL="1"
      ;;
      --start|start)
      START="1"
      ;;
      --remove)
      REMOVE="1"
      ;;
      -f|--force)
      REINSTALL="1"
      ;;
      --instance)
      INSTANCE="1"
      ;;
      --update)
      UPDATE="1"
      ;;
      -c|--clean)
      CLEAN="1"
      ;;
      -h|--help)
      HELP="1"
      ;;
      *)
      echo "Unknown opt."
      help
      exit 1
      ;;
  esac
  shift
done

main(){
  [[ "$REMOVE" == "1" ]] && removei && remove && return
  [[ "$INSTALL" == "1" ]] && install && return
  [[ "$REINSTALL" == "1" ]] && remove && install && return
  [[ "$INSTANCE" == "1" ]] && starti && return
  [[ "$CLEAN" == "1" ]] && clean && return
  [[ "$UPDATE" == "1" ]] && update && return
  [[ "$HELP" == "1" ]] && help && return
  [[ "$START" == "1" ]] && start && return
  remove && install
}
main
