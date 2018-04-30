## PURPOSE

This is a project to automate the process of launching a 3 node MongoDB Cluster on AWS.
The project divide into 2 part: Provisioning the servers using Terraform and Configuration using Ansible. 
We will create 3 host with a route53 record: db[0-2].test.com and using the dns record for mongoDB configuration.


## I. CREATE THE 3 EC2-INSTANCE IN AWS USING TERRAFORM

### Prerequisite: 
 - AWS Credential is setup in the system
 - terraform is installed   


### 1. Create a S3 bucket to store terraform state

The S3 bucket is used to store the terraform state so we can easily break 
and run Terraform using different components.

- Init terraform and apply. Please provide a unique name for the bucket.
```
  terraform init terraform/data-storage/s3/
  terraform apply terraform/data-storage/s3/
```

### 2. Create VPC 

- Edit file /terraform/vpc/terraform.tf
  Changed the bucket name to the S3 bucket name above


Init and apply: 
```
  terraform init terraform/vpc
  terraform apply terraform/vpc
```

### 3. Launch the EC2 instance

- Must have permission to do: ec2:DescribeVpcs for Route53 to create private DNS zone
(Some users with full Admin right might still need to add this ec2 permission)

- edit files /modules/mongo-cluster/vars.tf, changed the bucket (line 6) to correct bucket name

- You can edit the /services/mongoCluster/main.tf for customizing ec2 instance type and ami id

- Launch these ec2 instance:
```
  terraform get terraform/services/mongoCluster/
  terraform init terraform/services/mongoCluster/
  terraform apply terraform/services/mongoCluster/
```

- The console will output public IP address of the instances just created. Use the stageKey to access those instance and verify if the config is correct. Else you can use the AWS Management Console to verify


## II. USING ANSIBLE TO DEPLOY MONGODB CLUSTER


### 1. Update instance public IP address

Please update the hostfile of the machine running ansible to include the public IP of 3 new instances above:

e.g
```
52.207.246.29 master
34.224.74.219 slave1
54.152.68.12 slave2
```
- Set ansible host checking = false before start using Ansible (this is to avoid key fingerprint confirmation)
```
export ANSIBLE_HOST_KEY_CHECKING=false
```
### 2. Install and configure
Go to ansible directory

- Install Docker and necessary package to the 3 mongoldb servers
```
ansible-playbook -i inventory install.yml
```  
- Setup and run mongodb container on each servers
```
ansible-playbook -i inventory setup.yml
```
- Configure and initiate the cluster 
```
ansible-playbook -i inventory configure.yml
```

Verify the cluster status by accessing any container, run mongo shell and command rs.status()
