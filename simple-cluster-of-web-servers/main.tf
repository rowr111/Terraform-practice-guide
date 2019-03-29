/*
This code was created by following the tutorial in:
https://blog.gruntwork.io/an-introduction-to-terraform-f17df9c6d180
Source code with detailed notes can be found at:
https://github.com/gruntwork-io/intro-to-terraform
*/

//required info
provider "aws" {
  region = "us-east-1"
}

//the 'data' section here tells terraform to fetch all the zones for aws
data "aws_availability_zones" "all" {}

//create an auto-scaling group of web servers
//define the load balancer to use and the launch configuration to use for each instance in the group
resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  min_size = 2
  max_size = 10
  load_balancers = ["${aws_elb.example.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

//launch configuration for each instance in the autoscaling group
//define the security group to use, the data to run on each instance after launch.
resource "aws_launch_configuration" "example" {
  image_id = "ami-2d39803a"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

//security group to use on each instance created in the autoscaling group
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

//load balancer to be used by the autoscaling group. 
//define the security group to be used by this load balancer 
//as well as a health check to be used on each instance
resource "aws_elb" "example" {
  name = "terraform-asg-example"
  security_groups = ["${aws_security_group.elb.id}"]
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }
}

//security group to be used by the load balancer
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"
   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//variable to be referenced by various resources - this could also be in a tfvars file.
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}
output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}