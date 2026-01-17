function rm-target --wraps='sudo find . -depth -type d -name target -exec sudo rm -rf {} +' --description 'alias rm-target=sudo find . -depth -type d -name target -exec sudo rm -rf {} +'
  sudo find . -depth -type d -name target -exec sudo rm -rf {} + $argv
        
end
