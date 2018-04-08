# DevOps test

## Introduction

This is my solution to the technical test for DevOps candidates at ITRS.

The requirement is to deploy an AWS environment using Terraform, having at least 2 services correlated.

## Prerequisites to run the exercise

* git and terraform must be already installed in the computer
* A valid AWS account with known access key and secret key. For security reasons they are not saved in git and I will share them in a separate e-mail.
* An ssh key pair has been already generated in AWS. The private key is not stored in git for security reasons and it will be shared in a separate e-mail.

## Proposed environment

The environment that I propose for this exercise contains 2 virtual machines in separate subnets. A new VPC is created and 2 subnets configured, one private and one public.

One of the virtual machines will act as fron-end server running an Apache server and will have a public IP associated, so it can be accessed from the Internet. It will be deployed in the public subnet.

The second virtual machine is deployed in the private subnet and cannot be accessed directly from the Internet. When this virtual machine is created a new record in DNS is created as well. The front-end machine will connect to the database using the DNS name.

Each virtual machine has a different security group associated according to the services running on them.

The virtual machines will be created in 2 different availability zones for Paris region.

The AWS services used in this test are:

* EC2
* VPC
* Route53

## How to run the test

1. Clone the repository containing the code: git clone https://github.com/jcgarridog/itrs.git
2. Change to the itrs directory: *cd itrs*
3. Edit the file variables.tf and assign the proper values to aws_access_key and aws_secret_key. For security reasons they are not provided in the scripts.
4. Execute the command: *terraform init*
5. Execute the command: *terraform apply*

Once step 5 has finished the environment should be already deployed. You can access the AWS console and check that the virtual machines, subnets, etc. have been created, and read the public IP or DNS name of the fron-end server. Please pay attention to the region selected in the console, as the virtual machines have been created in Paris.

You can open a web browser and visit the URL http://<frontend-public-ip>/calldb.php

When you are done with the environment you can get rid of it running the command: *terraform destroy*

## Explanation about the different modules

To improve the readability and ease maintenance the code has been separated in different modules.

### variables.tf

All the configurations have been centralized in this file. In this module we set up different parameters that will be used in the rest of the modules. All these parameters have been set except *AWS access key* and *AWS secret key* which have been left blank intentionally for security reasons.

* region: We have chosen "eu-west-3" (Paris) due to geographical proximity.
* AmiLinux: This is a map where we can set the AMI-ID for equivalet AMIs in different regions. Then the scripts will pick up the proper AMI-ID  dependion on the region where we are deploying the virtual machines.
* aws_access_key: this must be set with the AWS access key.
* aws_secret_key: this must be set with the AWS secret key.
* vpc-fullcidr: IP range for the full VPC. It will be splitted into 2 different subnets (public and private).
* Subnet-Public-AzA-CIDR: IP range for the public subnet.
* Subnet-Private-AzA-CIDR: IP range for the private subnet.
* key_name: name of an already existing SSH key pair to have access to the virtual machines.
* DnsZoneName: name of the internal domain

### network.tf

In the network.tf file, we set up the provider for AWS and the VPC declaration. Together with the Route53 configuration, the option specified for the vpc creation enables an internal name resolution for our VPC.

### routing.tf

When you start from scratch, you need to attach an internet gateway to your VPC and define a network ACL. There aren’t restriction at network ACL level because the restriction rules will be enforced by security group.

There are two routing tables: one for public access, and the other one for private access. In our case, we also need to have access to the internet from the database machine since we use it to install MySQL Server. We will use the AWS NAT Gateway in order to increase our security and be sure that there aren’t incoming connections coming from outside the database. The depends_on allows us to avoid errors and create the NAT gateway only after the internet gateway is in the available state.

### subnets.tf

We create the public and private subnets, each one in different availability zones (just for the sake of the test).

### dns_and_dhcp.tf

In this file, three things were accomplished: the private Route53 DNS zone was created, the association with the VPC was made, and the DNS record for the database was created.

### securitygroups.tf

We create 2 different security groups, one for the front-end and the other one for the database. All the outbound traffic is allowed but only specific services are allowed for incoming traffic.

### ec2-vm.tf

#### The database machine

This machine is placed in the private subnet and has its security group. The userdata performs the following actions:

* Update the OS
* Install the MySQL server and run it
* Configure the root user to grant access from other machines
* Create a table in the test database and add one line inside

There is a dependency on the NAT Gateway in order to be able to update the OS and install MySQL server.

#### The front-end machine

It is placed in the public subnet so it is possible to reach it from your browser using port 80. The userdata performs the following actions:

* Update the OS
* Install the Apache web server and its php module
* Start the Apache
* Using the echo command place in the public html directory, a php file that reads the value inside the database created in the other EC2
