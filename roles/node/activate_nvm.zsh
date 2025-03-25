# Lazily load nvm so that it doesn't slow down shell startup time
# https://github.com/creationix/nvm/issues/782
export NVM_DIR="$HOME/.nvm"

# Only set up lazy loading if not already loaded
if [[ ! -v functions[nvm] ]] && [[ ! -v aliases[nvm] ]]; then
  group_lazy_load $HOME/.nvm/nvm.sh nvm node npm npx yarn
fi
