# Specify the provider and access details
provider "aws" {
  region     = "us-east-1"
  access_key = "${var.aws-access-key}"
  secret_key = "${var.aws-secret-key}"
}


# Default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "web" {
#  name        = "angular7demo-security-group-from-terrorform" #optional, when omitted, terraform creates a random name
  description = "security group for angular7demo web created from terraform"
  vpc_id      = "vpc-c422e2a0"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # mongoose access from anywhere
  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to for the database
resource "aws_security_group" "mongo" {
  description = "security group created from terraform"
  vpc_id      = "vpc-c422e2a0"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # mongodb access from anywhere
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mongodb" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"
  }

  instance_type = "t2.micro"
  
  tags = { Name = "mongodb instance" } 

  # standard realmethods community image with mongo started on the default port 
  ami = "ami-0e2a167cf2e0ce6c0"

  # The name of the  SSH keypair you've created and downloaded
  # from the AWS console.
  #
  # https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:
  #
  key_name = "my-public-key"
  
  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.mongo.id}"]
  
  # To ensure ssh access works
    provisioner "remote-exec" {
    inline = [
      "sudo ls",
    ]
  }

}

resource "aws_instance" "web" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"
 }

  instance_type = "t2.medium"
  
  tags = { Name = "angular7demo instance" } 

  # standard realmethods community AMI with docker pre-installed
  ami = "ami-05033408e5e831fb0"

  # The name of the  SSH keypair you've created and downloaded
  # from the AWS console.
  #
  # https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:
  #
  key_name = "my-public-key"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.web.id}"]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install docker",
      "sudo docker login --username tylertravismya --password 69cutlass",
      "sudo docker pull realmethods/angular7demo:latest",
      "sudo docker run -it -e MONGOOSE_HOST_NAME=${aws_instance.web.public_ip} -e MONGO_HOST_ADDRESS=mongodb://${aws_instance.mongodb.public_ip}:27017/angular7demo -p 4000:4000 -p 8080:8080 -p 8000:8000 realmethods/angular7demo:latest"
    ]
  }
}
