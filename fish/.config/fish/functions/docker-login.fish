function docker-login --wraps='echo "$CI_PERSONAL_TOKEN" | docker login gitlab.esc-hq.ru:7999 --username Private-Token --password-stdin' --description 'alias docker-login=echo "$CI_PERSONAL_TOKEN" | docker login gitlab.esc-hq.ru:7999 --username Private-Token --password-stdin'
  echo "$CI_PERSONAL_TOKEN" | docker login gitlab.esc-hq.ru:7999 --username Private-Token --password-stdin $argv
        
end
