# Jeanie's Notes on Getting Started with Terraform
## Introduction 
### What is Terraform?
Terraform is a handy devops tool that lets you create machines, network, etc. adhoc in the public cloud provider of your choice (for most ppl, this is AWS).  
### Why do these notes exist?
There are lots of tutorials on how to start using Terraform, but because I really like things explained from scratch including initial setup, I wrote this.  It's for my own personal setup, (Windows 10) but beyond the initial installs environment shouldn't matter much. 
### Why AWS?
AWS is the most widely used public cloud provider.  I've already done some work in the past using Azure, and after doing some tutorials I can say that the main difference is just the resources you use.  Terraform is NOT cloud provider agnostic - you can't just rename things from aws to azure and hope things will work; the structure of their offerings is different.

## Installation/AWS User Setup
Like all things in software development, setup is never simple.. first things first, all the installing of things:

1. Install [Terraform](https://www.terraform.io/downloads.html) 
    1. I put it at C:\terraform like the example in the Terraform docs, but feel free to put it wherever works for you.
    2. set the Terraform executable's location in your computer's path variable so that you can call it from any directory.
        1. verify this works afterwards in some random folder by calling 'Terraform --version' from PowerShell. 
2. Install [Python](https://www.python.org/downloads/) - you need Python to run the AWS command line interface (AWS CLI).
3. Create an AWS account if you don't already have one.
4. [Create a special user for Terraform](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/signup-create-iam-user.html) in AWS IAM.  I called mine terraform_user.  
5. Give this user full admin privs and save their access credentials. You MUST save these details at the time of credentials creation:
    3. access key id
    4. secret access key
    5. password
6. Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
7. Configure the terraform user's aws credentials for use with AWS CLI - there are two options: 
    6. create credential files: 
        2. use PowerShell to run 'aws configure', and then input the above credentials when prompted.  
        3. You will also be prompted to input a default region name and output format, you can leave these blank if you want.
        4. Afterward, the credentials that Terraform will use will be saved in a new folder at C:\Users\(your username)\.aws
    7. [set environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
8. Install an editor to use with Terraform files - there are a few but recommended ones include:
    8. [Visual Studio Code](https://code.visualstudio.com/)
        5. also install the [Terraform extension](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)
    9. [Atom](https://atom.io/)
9. (not required but recommended) have a github account where you will save your work.

Ok, now you're ready to start making things in the Amazon public cloud!

## Step 1: Making a load balanced web server cluster
### Why this project?  Shouldn't we do something simpler?
There are a few example first projects, like the one in the [terraform docs](https://learn.hashicorp.com/terraform/getting-started/build), but I recommend doing the one from [blog.gruntwork.io](https://blog.gruntwork.io/an-introduction-to-terraform-f17df9c6d180) because it's a bit more complicated but is very friendly to beginners.  It walks you through the process from the very beginning of creating just a basic web server to by the end having a full-on load balanced cluster.  

You can find the final version of the gruntwork tf files [here](https://github.com/gruntwork-io/intro-to-terraform). Do not be tempted to just copy this file and look at it.  Do it yourself step by step following the tutorial, and only refer to their reference if things are broken for some reason.  FYI they used Terraform 0.7 - everything worked for me with v0.11 but your experience may vary.

#### Notes on the gruntwork tutorial
1. create a folder for your example project.  
2. use PowerShell to run 'terraform init' to [initialize Terraform](https://learn.hashicorp.com/terraform/getting-started/build#initialization) to use with the AWS credentials we created.
3. create a .tf file in that folder (name it whatever you want) and add the info from the [gruntwork simple server example](https://blog.gruntwork.io/an-introduction-to-terraform-f17df9c6d180) into the file and save it.
4. navigate in PowerShell to the folder that contains the terraform files you want to execute.  Terraform will make the plan from everything in this folder and its subfolders.
5. Use PowerShell to run 'terraform plan' to see the plan - it should say '1 to add' in the plan summary.
6. Use PowerShell to run 'terraform apply' to create the server. You'll have to type 'yes' to confirm.
7. Woo hoo!  check AWS:
    1. go to aws.amazon.com, and 'sign into the console'
    2. click on 'all services>EC2>Instances'
    3. you should see your server
8. Make sure to also try the update where you give it a name, you'll see '1 to update' in the plan before you execute 'terraform apply'
9. Continue doing the steps in the blog post until you get to the end, and you'll have set up a load balanced auto-adjustable group of web servers..  woot.
10. Don't forget to do 'terraform destroy' in the end just in case you might get charged by Amazon!  You'll also have to confirm by typing 'yes' here.

## Step 2: Make your code team-friendly
### Terraform backend in the cloud
If multiple ppl are working on a project, or just.. you know, best practices to not have the current state of your infrastructure dependent on your personal computer or some local store, you can use place like [Amazon S3](https://aws.amazon.com/s3/) to save things that Terraform needs to run, like the state or output. Terraform calls this the '[Backend](https://www.terraform.io/docs/backends/index.html)'.  Setup is pretty straightforward - but use [this blog post](https://datanextsolutions.com/blog/terraform-using-aws-s3-remote-backend/) bc the gruntwork blog post method is deprecated.

### [S3 specific backend](https://www.terraform.io/docs/backends/types/s3.html) details
1. create a bucket in the S3 management console (name must be globally unique).
2. make sure your terraform user has access to the bucket.
3. make a 'terraform' section in a tf file and put the details from the blog post mentioned in there.
    1. if you need to know the code for your region they are [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions).
4. run 'terraform init' in order to set up the backend for the first time.  it'll ask you if you want to copy over or start fresh. up to you.
5. bonus round:  if you would like to lock the tfstate file to prevent collisions, you must set up a Dynamo DB table and add that to the terraform section. 

## Terraform Interpolation Syntax
Using variables or referring to other things is an essential part of using Terraform. Hardcoding is always a bad idea..  In order to make your life easier, use the [Terraform Interpolation Syntax](https://www.terraform.io/docs/configuration-0-11/interpolation.html).

## Important AWS/Terraform/etc Definitions

### Arguments used in resources
*   ami (terraform) ([amazon](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html)) - Amazon Machine Image 
    *   what type of machine to create (linux, windows, etc, as well as what kind of resources it has (memory, storage space)
    *   why are the names of these so cryptic?  ugh.
    *   it is very hard to find the names for these... 
*   [availability_zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) - separate data center areas available from Amazon
    *   this data is fetched by Terraform from Amazon at time of terraform script execution by use of the amazon[ data source](https://www.terraform.io/docs/configuration/data-sources.html).
*   CIDR block ([wiki](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)) - a concise way of detailing blocks of IP addresses
*   [tags](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html) - you can apply tags at your discretion to most resources. 
*   [user_data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) - commands that aws can run on a linux machine image after launch.

### Resources
The names of things that terraform can create are called 'resources'.  all of the resources for amazon start with 'aws_'.

*   aws_instance - ([terraform](https://www.terraform.io/docs/providers/aws/r/instance.html)) an amazon [ec2 instance](https://www.terraform.io/docs/providers/aws/r/instance.html) aka a server.
*   aws_security_group ([terraform](https://www.terraform.io/docs/providers/aws/r/security_group.html)) ([amazon](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html)) - basically a firewall that restricts traffic
*   aws_autoscaling_group ([terraform](https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html)) ([amazon](https://aws.amazon.com/autoscaling/)) - amazon can make or remove servers as needed to handle load within a group
    *   aws_launch_configuration ([terraform](https://www.terraform.io/docs/providers/aws/r/launch_configuration.html)) ([amazon](https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchConfiguration.html)) - resource required by autoscaling groups
*   aws_elb ([terraform](https://www.terraform.io/docs/providers/aws/r/elb.html)) ([amazon](https://aws.amazon.com/elasticloadbalancing/)) - elastic load balancer

### Other random Terraform/AWS items worth knowing about
*   [Dynamo DB](https://aws.amazon.com/dynamodb/) - Amazon's no sql db offering
*   Packer - another piece of software from HashiCorp (makers of Terraform) that can be used to generation custom automated machine images.
*   Docker - used to generate custom automated machine images
*   [S3](https://aws.amazon.com/s3/) - Simple Storage Service - Amazon's cloud storage offering.
*   [input variables](https://learn.hashicorp.com/terraform/getting-started/variables.html) - Terraform can load variables from a few places:
    *   a *.tfvars file
    *   from variables declared throughout the code
    *   from command line input at the time of execution of the terraform scripts
*   [output variables](https://learn.hashicorp.com/terraform/getting-started/outputs.html) - Terraform can output useful info that you don't need to look up afterward.  you can also query these outputs as Terraform stores them.
