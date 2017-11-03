# tf_gitlab_test
Instance to install and fiddle with gitlab

### Resources:

- 'provisioner.tf' contains initial setup commands
- 'server.tf' specifies gitlab server instance details and inbound interface accesses
- 'runner.tf' specifies gitlab runner instance details and inbound interface accesses
- 'variables.tf' sets most defaults, including instance sizes, counts and regions

### Create a 'terraform.tfvars' with your own values:

```
# see EC2 --> Network & Security --> Key Pairs
# to configure this key in AWS
keypair="aws_keypair_name"

# change this to match your preferred profile;
# if setting up remote state in S3, also set the profile
# there if it's not 'default' (the default)
aws_profile = "default"

# set your regional preferences;
# only primary is currently used
region      = {
                primary = "us-west-2"
                backup  = "us-east-1"
              }

# Size of the box
inst_type  = {
                server = "t2.large"
                runner = "t2.small"
             }

# Number of boxes
inst_count = {
                server = "1"
                runner = "1"
             }
```

### Use the ssh-agent for the provisioner connection authentication

```
$ eval $(ssh-agent)
$ ssh-add ~/.ssh/path/to/myprivatekey
```

User is 'ubuntu' for defaulted images.

### Backup and Restore Procedures (to be automated)

#### Backup:
- connect to the gitlab_server instance
- run the backup and note the resulting tarball location
```
$ sudo gitlab-rake gitlab:backup:create
...
$ sudo ls -l /var/opt/gitlab/backups
...
```

#### Restore
- place the archive file to restore in the /var/opt/gitlab/backups directory
- run the restore
```
$ sudo gitlab-rake gitlab:backup:restore
```
- if the gitlab URL (external dns name) has changed, then we also need to update the following items:

...in file /home/git/gitlab/config/gitlab.yml:
```
    gitlab:
      host: <<your-gitlab-server-public-dns-name>>
```
...in file /home/git/gitlab-shell/config.yml
```
  gitlab_url: "https://<<your-gitlab-server-public-dns-name>>"
```
...in file /etc/nginx/sites-available/gitlab
```
  server {
    server_name <<your-gitlab-server-public-dns-name>>
```

#### Tested on Terraform 0.10.7.
