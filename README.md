# Nginx balancer and Terraform in AWS
Creates 3 virtual machines with Nginx. 1 VM balancer nginx and 2 VM backand nginx

# Quick Start
1. Use this instuctions to install [Terraform](https://learn.hashicorp.com/tutorials/terraform/aws-build?in=terraform/aws-get-started) and configurate AWS CLI 
2. Terraform will automatically search for saved API credentials in ~/.aws/credentials
3. Copy all file in one dirctory on you unix PC
4. Use command `terraform init` to initialize a working directory containing Terraform configuration files
5. Use command `terraform apply` to create VM's
6. To check, go to 80 port on you public IP balancer

# File list
1. Provider.tf - info for provider
2. Main.tf -  Create VM, copy file and run script
3. Securitygroup.tf - Create securitygroup for connect to VM
4. Subnet.tf - Create subnet to create custom network
5. Var.tf - variables
6. Site folder - Default site
7. conf_file - folder with conf file for balancer and backand

//////////////// Сonfiguration Files /////////////////////

1. balancer.conf - Conf file for balancer server
2. site.conf - conf file for Nginx backand

//////////////// Virtual Mashine ////////////////////////

1. balancer  - balancer server, private network ip 192.168.0.199
2. backend-1 - Nginx backand, private network ip 192.168.0.201
3. backend-2 - Nginx backand, private network ip 192.168.0.202

