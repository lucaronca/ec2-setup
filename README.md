# EC2 Setup

This is a Terraform module that provides a configurable and ship-ready AWS EC2 setup with fundamental features (security group ingress/egress, ebs volume, cloudwatch cpu usage metric alarm, aws key pair, etc.)  
It allows you to connect to your EC2 instance directly via SSH from your local machine, you will need a public rsa key stored in `~/.ssh/id_rsa.pub` to associate your local machine.  

## Usage
Use `aws ec2 describe-images --image-ids <ami-id>` to retrieve information about the ami your are going to use.  
Use `ImageLocation` and `OwnerId` to fill the `ami.name` and `ami.owner` module variables.
