# Ubuntu-only stuff. Abort if not Ubuntu.
is_ubuntu || return 1

e_arrow "Installing apt packages"

apt_source_texts=()
apt_packages=()

# Ubuntu distro release name, eg. "xenial"
release_name=$(lsb_release -c | awk '{print $2}')


#############################
# WHAT DO WE NEED TO INSTALL?
#############################

apt_source_texts+=(
  ppa:jonathonf/vim
)
apt_packages+=(
  vim
)
# Packages
apt_packages+=(
  build-essential # contains gcc, g++
  autoconf
  python-all-dev
  boxes
  cmake
  curl
  exuberant-ctags
  emacs
  evince
  exfat-fuse
  exfat-utils
  rig
  git
  graphviz
  htop
  imagemagick
  nmap
  python-pip
  stow
  snapd
  telnet
  tig
  tmux
  tree
  unzip
)

if is_ubuntu_desktop; then
  # Misc
  apt_packages+=(
    fonts-mplus
    gnome-tweak-tool
    k4dirstat
    openssh-server
    unity-tweak-tool
    vlc
    xclip
    zenmap
  )

fi

####################
# ACTUALLY DO THINGS
####################

# adding ppa repos
for pparep in "${apt_source_texts[@]}"; do
    e_header "Adding $pparep"
    sudo add-apt-repository $pparep
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

