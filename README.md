### sshkeygen2

##### *sshkeygen2*.sh

##### Description:

**Script can do:**

* Generate ssh key
* Generate record assigned to your server in `~/ssh/config`
* Send key to the server into `~/.ssh/authorized_keys`
* Let you just enter `ssh <server-name>` and get access to your server.

#### Usage

```bash
bash sshkeygen2 -n <server-alias name> -l <remote login> -s <server domain/ip> -p <port>
```

**Flags**

* **-n** Name of the server instance you trying to get access to.
* **-l** Username in the remote server
* **-s** Server domain name or IP address
* **-p** Custom port number. If not specified then default 22

**Example**

```bash
sshkeygen2 -n cool-serv -l det -s yourserver.com
ssh cool-serv
```

---

### SSHFS Mounter

***sshmount.sh***

**Description**: Allows to use this script i.e. for ranger, as sshfs only connector. For realisation same functions like in mc's ssh session. Have its own bash completion script that reads your user's ssh config directory to read servers you want connect to.

#### Usage

`sshmount.sh <server>`

---

### Mounter

***mounter.sh***

**Description**: Allows to use this script i.e. for ranger, as ssh/ftp/smb connector. For realisation same functions like in mc's ssh session.

**Modules**

* ssh - using `sshfs` tool for work
* ftp - `gvfs-mount`
* smb - `gvfs-mount`

#### Usage

`mounter.sh -t <type ssh/ftp/smb> <server>`
