function myip --wraps="curl -s ipinfo.io | jq 'del(.readme)'" --description "alias myip=curl -s ipinfo.io | jq 'del(.readme)'"
  curl -s ipinfo.io | jq 'del(.readme)' $argv
        
end
