# EC2 Setup
This is a Terraform module that allows provisioning of a ready-to-use AWS EC2 configuration, equipped with key functionalities (security group ingress / egress, EBS volume, Cloudwatch cpu usage metric alarm, AWS key pair, etc.) but largely customizable.  
Among the features in evidence is the possibility, automatically, to connect to your EC2 instance directly using the public SSH key from your client machine, you will need a public rsa key stored in `~/.ssh/id_rsa.pub` to bind your local machine.  

## Usage
- Use `aws ec2 describe-images --image-ids <ami-id>` to retrieve information about the ami will use.  
- Use the `ImageLocation` and `OwnerId` values to fill the `ami.name` and `ami.owner` module variables.
- Check the existence of your ssh public key
  - `cat ~/.ssh/id_rsa.pub`
  - (if `id_rsa.pub` missing) `ssh-keygen`
- Plan and apply 🚢

See `variables.tf` for all the possible configurations.

## Terraform example
```hcl
provider "aws" {
  region = "us-east-1"
}

module "ec2-setup" {
  source = "github.com/lucaronca/ec2-setup?ref=v0.0.2"
  ami = {
    name  = "amzn2-ami-kernel-5.10-hvm-2.0.*.1-x86_64-gp2"
    owner = "137112412989"
  }
  instance_tags = {
    name        = "SERVER01"
    environment = "DEV"
    os          = "AMAZON-LINUX"
  }
  allow_tls = false
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2-setup.instance_id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2-setup.instance_public_ip
}

output "instance_public_dns" {
  description = "Public IPv4 DNS address of the EC2 instance"
  value       = module.ec2-setup.instance_public_dns
}
```
### Then
```bash
terraform plan
terraform apply
ssh ec2-user@<instance_public_ip>
sudo python3 -m http.server 80
```  

```bash
curl <instance_public_dns>
```
