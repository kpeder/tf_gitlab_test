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

### Backup and Restore Procedures

#### Backup:
- connect to the gitlab_server instance
- run the backup and note the resulting tarball location
```
$ sudo gitlab-rake gitlab:backup:create
...
$ sudo ls -l /var/opt/gitlab/backups
...
```
- scp the latest tarball to your local system before shutting down the server
```
$ scp ubuntu@$(terraform output|grep server|awk '{print $NF}'):/var/opts/gitlab/backups/<<somefile>>.tar
```

#### Restore:
- place the archive file to restore in the project root or some other referenceable directory on your local system
- run the restore by adding the following variables in your terraform.tfvars file... generally needed on initial redeploy of the gitlab server instance
```
gitlab_server_backup = {
                         "archive_to_restore"  = "my_archive_gitlab_backup.tar" # for example
                         "restore_flag"        = "1"                            # default is 0, good idea to set to 0 again after a restore
                       }
```
- restore doesn't affect the server's configuration, only the project data, repositories, users, etc. (stuff you'll configure in the UI, mostly), so best to restore on a freshly deployed server
- this will break some GitLab features under some conditions and is not meant to be a robust solution at this time (if 2FA is enabled for instance, the encryption keys in the configuration are not backed up)
- see https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/raketasks/backup_restore.md for a proper treatment from the vendor

#### Tested on Terraform 0.10.7
