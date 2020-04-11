# install fzf
e_arrow "Installing fzf"
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
$HOME/.fzf/install --all --no-update-rc

# FZF
e_header "Updating bashrc.user"
if [[ "$(type -P rg)" ]]
then 
  echo "export FZF_DEFAULT_COMMAND='rg --files'" >> ~/.bashrc.user
else
  echo "export FZF_DEFAULT_COMMAND='find .'" >> ~/.bashrc.user
fi
echo "[ -f ~/.fzf.bash ] && source ~/.fzf.bash" >> ~/.bashrc.user

