# Install rust
e_arrow "Installing Rust"
curl https://sh.rustup.rs -sSf | sh -s -- -y

source $HOME/.cargo/env

cargo_packages=(
  ripgrep
  bat
)

installed_cargo_packages="$(cargo install --list | awk 'NR % 2 {print $1}')"
cargo_packages=($(setdiff "${cargo_packages[*]}" "$installed_cargo_packages"))

if (( ${#cargo_packages[@]} > 0 )); then
  e_header "Installing cargo packages (${#cargo_packages[@]})"
  for package in "${cargo_packages[@]}"; do
    e_arrow "$package"
    cargo install "$package" 
  done
fi


# Setup rust
echo 'export PATH=$PATH:$HOME/.cargo/bin' >> ~/.bashrc.user

