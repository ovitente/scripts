COMMANDS_LIST='
ag --nobreak --nonumbers --noheading . | fzf
ansible all -m shell -a "echo test"
cat .gitlab-ci.yml | pbcopy
cat FILE | base64 -w0 | xclip -selection clipboard
circleci config validate config.yaml
docker build -t $(basename $(pwd)) .
docker build -t $(basename $(pwd)) . --build-arg CI_PROJECT_NAME="$(basename $(pwd))" --build-arg CI_PROJECT_NAMESPACE="vcg"
git add . && git commit -a && git push
git commit --amend --author="Ivan Kostrubin <ivan.kostrubin01@currys.co.uk>"
git config --global user.email "ivan.kostrubin01@currys.co.uk"
git config --global user.name "Ivan Kostrubin"
grep --line-buffered --color=never -r "" * | fzf
hcloud server create --image=ubuntu-22.04 --type=cpx41 --location=hel1 --ssh-key=IvanKostrubin --user-data-from-file=userdata.yaml --name instance-name
python3 -m http.server
'

choise=$(echo -n "${COMMANDS_LIST}" | fzf )
# choise=$(echo -n "${COMMANDS_LIST}" | rofi -dmenu -p "Choose fast cmd")
echo -n "$choise" | pbcopy
# pbpaste
