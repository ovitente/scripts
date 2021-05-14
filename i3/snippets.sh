COMMANDS_LIST='
ag --nobreak --nonumbers --noheading . | fzf
ansible all -m shell -a "echo test"
cat .gitlab-ci.yml | xclip -selection clipboard
docker build -t $(basename $(pwd)) .
docker build -t $(basename $(pwd)) . --build-arg CI_PROJECT_NAME="$(basename $(pwd))" --build-arg CI_PROJECT_NAMESPACE="vcg"
grep --line-buffered --color=never -r "" * | fzf
git add . && git commit -a && git push
circleci config validate config.yaml
cat FILE | base64 -w0 | xclip -selection clipboard
'

choise=$(echo -n "${COMMANDS_LIST}" | fzf )
# choise=$(echo -n "${COMMANDS_LIST}" | rofi -dmenu -p "Choose fast cmd")
echo -n "$choise" | pbcopy
# pbpaste
