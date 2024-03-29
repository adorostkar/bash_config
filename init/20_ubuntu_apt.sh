# Ubuntu-only stuff. Abort if not Ubuntu.
is_ubuntu || return 1

e_arrow "Installing apt packages"

apt_source_texts=()
apt_packages=()
snap_packages=()


#############################
# WHAT DO WE NEED TO INSTALL?
#############################

apt_source_texts+=(
  ppa:jonathonf/vim
)
apt_packages+=(
  vim
)

# Conflicts with prefix in tmux
# apt_source_texts+=(
#   ppa:agornostal/ulauncher
# )
# apt_packages+=(
#   ulauncher
# )

# Packages
apt_packages+=(
  build-essential # contains gcc, g++
  autoconf
  python3-all-dev # python2.7 not needed any longer
  python3-pip
  boxes
  cmake
  curl
  default-jdk
  exuberant-ctags
  emacs
  evince
  exfat-fuse
  exfat-utils
  guake
  kdenlive
  rig
  git
  graphviz
  htop
  imagemagick
  nmap
  node
  p7zip-full
  stow
  systemtap
  snapd
  telnet
  tig
  tmux
  tree
  unzip
  fonts-powerline
)

snap_packages+=(
  go
  nvim
  foliate
)

nvim_options="--classic"
go_options="--classic"
preinstall_node(){
    curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
}

is_ubuntu_desktop && snap_packages+=(spotify)

if is_ubuntu_desktop; then
  # Misc
  apt_packages+=(
    fonts-mplus
    gnome-sushi
    gnome-tweak-tool
    k4dirstat
    openssh-server
    unity-tweak-tool
    xclip
    zenmap
  )
  snap_packages+=(
    vlc
  )

fi

####################
# ACTUALLY DO THINGS
####################

# adding ppa repos
for pparep in "${apt_source_texts[@]}"; do
    e_header "Adding $pparep"
    sudo add-apt-repository $pparep -y
done
# Update APT.
e_header "Updating APT"
${SUDO} apt-get -qq update

# Only do a dist-upgrade on initial install, otherwise do an upgrade.
e_header "Upgrading APT"
${SUDO} apt-get -qy upgrade > /dev/null

# Install APT packages.
installed_apt_packages="$(dpkg --get-selections | grep -v deinstall | awk 'BEGIN{FS="[\t:]"}{print $1}' | uniq)"
apt_packages=($(setdiff "${apt_packages[*]}" "$installed_apt_packages"))

if (( ${#apt_packages[@]} > 0 )); then
  e_header "Installing APT packages (${#apt_packages[@]})"
  for package in "${apt_packages[@]}"; do
    e_arrow "$package"
    [[ "$(type -t preinstall_$package)" == function ]] && preinstall_$package
    ${SUDO} apt-get -qq install "$package" > /dev/null && \
    [[ "$(type -t postinstall_$package)" == function ]] && postinstall_$package
  done
fi

# Install snap packages.
installed_snap_packages="$(snap list | awk '{print $1}'  | uniq)"
snap_packages=($(setdiff "${snap_packages[*]}" "$installed_snap_packages"))

if (( ${#snap_packages[@]} > 0 )); then
  e_header "Installing SNAP packages (${#snap_packages[@]})"
  for package in "${snap_packages[@]}"; do
    e_arrow "$package $(eval echo \$${package}_options)"
    [[ "$(type -t preinstall_$package)" == function ]] && preinstall_$package
    ${SUDO} snap install "$package" $(eval echo \$${package}_options) > /dev/null && \
    [[ "$(type -t postinstall_$package)" == function ]] && postinstall_$package
  done
fi
