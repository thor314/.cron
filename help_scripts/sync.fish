#!/usr/bin/fish
# argument to run on my other machines to keep them in sync

if not type -q taplo
  # https://taplo.tamasfe.dev/cli/introduction.html
  echo "INFO: installing taplo"
  wget https://github.com/tamasfe/taplo/releases/latest/download/taplo-linux-x86.gz
  gunzip taplo-linux-x86.gz
  chmod +x taplo-linux-x86
  mv taplo-linux-x86 ~/.cargo/bin/taplo
end

if not type -q gi
  # https://github.com/oh-my-fish/plugin-gi
  echo "INFO: updating fish plugin gi"
  fisher install oh-my-fish/plugin-gi
  gi update-completions
end

# if test -L ~/.config/Code/User/settings.json
#   echo "INFO: unlink vscode symlinks, which are i have merge conflicts with now every day"
#   set CODE ~/.config/Code/User
#   cp ~/.private/vscode $CODE
#   rm -rf $CODE/{settings.json, keybindings.json, snippets}
#   cp $CODE/vscode/* $CODE
# end

if not test -f ~/.cargo/bin/cargo-binstall
  cargo binstall cargo-binstall # fast binary installer, don't build from source
end

command -s node -q || nvm use latest

if not command -s prettier -q
  # nvm use latest
  npm install -g prettier
end
  
if not command -s hackmd-cli -q
  # nvm use latest
  npm install -g @hackmd/hackmd-cli
end

if not command -s tsc -q # a gizmo to give me linux cli instructions from the command line
  # nvm use latest
  npm install -g typescript
end 

if not test -d ~/fun/cmdh
  curl https://ollama.ai/install.sh | sh
  hub clone https://github.com/pgibler/cmdh ~/fun/cmdh && cd cmdh
  ./install.sh
end

# zellij - buggy to start, and installation options are crap
# if not test -f ~/.local/bin/zellij
#     wget https://github.com/zellij-org/zellij/releases/download/v0.39.2/zellij-x86_64-unknown-linux-musl.tar.gz
#     tar -xvf zellij*.tar.gz
#     chmod +x zellij
#     mv zellij ~/.local/bin
#     rm zellij*
#     # cargo install --locked zellij # bugged install
# end

# require password
# sudo apt -y install libnotify-bin
# sudo apt -y install keychain

