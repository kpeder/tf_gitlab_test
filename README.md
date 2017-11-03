# tf_gitlab_test
Instance to install and fiddle with gitlab

- 'provisioner.tf' contains initial setup commands
- 'inst.tf' specifies instance details and inbound interface accesses
- 'variables.tf' sets most defaults
- create a 'terraform.tfvars' with your own values:

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
inst_type  = "t2.large"

# Number of boxes
inst_count = "2"
```
