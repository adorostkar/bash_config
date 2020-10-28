# Ubuntu-only stuff. Abort if not Ubuntu.
is_ubuntu || return 1

e_arrow "Installing apt packages"

apt_keys=()
apt_source_files=()
apt_source_texts=()
apt_packages=()
deb_installed=()
deb_sources=()

# Ubuntu distro release name, eg. "xenial"
release_name=$(lsb_release -c | awk '{print $2}')

function add_ppa() {
  apt_source_texts+=($1)
  IFS=':/' eval 'local parts=($1)'
  apt_source_files+=("${parts[1]}-ubuntu-${parts[2]}-$release_name")
}

#############################
# WHAT DO WE NEED TO INSTALL?
#############################

# Misc.
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
  vim
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

