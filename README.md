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

### Optional: remote state setup (recommended)

Create an S3 bucket in AWS... not specified in the project because terraform depends on it

Create a file 'remote_state.tf' with the followinf content
```
terraform {
  backend "s3" {
    bucket  = "my-tf-state-files"             # your bucket name
    key     = "tf_gitlab_test/state.tfstate"  # path to the state file in your bucket
    region  = "us-west-2"                     # region in which your bucket is located (can be different than the project's region)
    profile = "default"                       # the AWS credentials profile to use for connection to the bucket
  }
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

Connect to the GitLab server instance
Run the backup and note the resulting tarball location
```
$ sudo gitlab-rake gitlab:backup:create
$ sudo ls /var/opt/gitlab/backups
1510189685_2017_11_09_10.1.1-ee-gitlab_backup.tar
```
Do something with both the tarball, and the /etc/gitlab/gitlab-secrets.json, to keep them safe and correlated; this is your backup set

Secure copy the latest backup set to your local system before shutting down the server

#### Restore:

Place the archive file and 'gitlab-secrets.json' files to restore in the project root on your local system.

Run the restore by adding the following variables in your terraform.tfvars file... generally needed on initial redeploy of the gitlab server instance
```
gitlab_server_backup = {
                         "archive_to_restore"  = "my_archive_gitlab_backup.tar" # for example
                         "restore_flag"        = "1"                            # default is 0, good idea to set to 0 again after a restore
                       }
```
Note that runners, CI/CD variables and 2FA will break if you don't place the correlated secrets file with the restore.

See https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/raketasks/backup_restore.md for a proper treatment from the vendor about backup and restore.

#### Tested on Terraform 0.10.7
