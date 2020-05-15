### Usage
* Create config file `~/.x7-tools.conf`
* Get teck-secrets directory from gs bucket through [tsec](https://github.com/ovitente/scripts/tree/master/tsec) tool
* Put path to the secrets directory into it: `ENV_FILES_PATH="$HOME/projects/Teck/teck-secrets"`
* cd to the `smt` dir
* execute `export GITHUB_ACCESS_TOKEN=your-github-token smt.sh < project name > < env name >`
* Example `export GITHUB_ACCESS_TOKEN=your-github-token smt.sh mamba dev`
