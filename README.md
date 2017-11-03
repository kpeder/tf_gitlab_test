# tf_gitlab_test
Instance to install and fiddle with gitlab

###Resources:

- 'provisioner.tf' contains initial setup commands
- 'server.tf' specifies gitlab server instance details and inbound interface accesses
- 'runner.tf' specifies gitlab runner instance details and inbound interface accesses
- 'variables.tf' sets most defaults, including instance sizes, counts and regions

###Create a 'terraform.tfvars' with your own values:

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

###Use ssh-agent for the provisioner connection auth, no keyfile is specified.

```
$ eval $(ssh-agent)
$ ssh-add ~/.ssh/path/to/myprivatekey
```

User is 'ubuntu' for defaulted images.

Tested on Terraform v0.10.7.
