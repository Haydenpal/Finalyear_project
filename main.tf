# main.tf

provider "aws" {
  region = "us-east-1"
  access_key ="AKIASABRXIT6ND2F6QW5"  # Use Terraform variables for flexibility
  secret_key ="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"  # Use Terraform variables for flexibility
# Change this to the desired AWS region
}

resource "aws_ecr_repository" "my_ecr_repo" {
  name = "my-ecr-repo"  # Change this to your desired repository name
}

resource "aws_security_group" "allow_all" {
  name        = "allow-all"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 indicates all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "example" {
  key_name   = "hayden-terraform"  # Replace with your desired key name
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your public key file
}

resource "aws_vpc" "myvpc1" {
  cidr_block = "10.0.0.0/18"
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc1.id
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "RTA" {
  subnet_id        = aws_subnet.sub1.id
  route_table_id   = aws_route_table.RT.id
}

resource "aws_security_group" "sg" {
  name  = "sg"
  vpc_id = aws_vpc.myvpc1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0b2ec65899cc867ef"  # Use the desired AMI ID
  instance_type = "m5.large"  # Change to a supported instance type for Microsoft SQL Server
  key_name      = aws_key_pair.example.key_name
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.sub1.id

  tags = {
    Name = "my-instance"
  }

  # Provisioner to run commands on the instance after creation
  provisioner "remote-exec" {
    inline = [
      # Check connectivity before proceeding
      "ping -c 3 ap-south-1.ec2.archive.ubuntu.com",
      "ping -c 3 security.ubuntu.com",
      "curl -I https://packages.microsoft.com/ubuntu/20.04/prod/dists/focal/InRelease",
      "curl -I https://s3.amazonaws.com/aws-cli/awscli-bundle.zip",

      "sudo apt-get update",
      "sudo apt-get install -y git docker.io awscli",
      "git clone https://github.com/Haydenpal/Finalyear_project.git",
      "cd Finalyear_project",
      "sudo apt-get install -y unzip",
      "sudo wget https://releases.hashicorp.com/terraform/0.15.5/terraform_0.15.5_linux_amd64.zip",
      "sudo unzip terraform_0.15.5_linux_amd64.zip",
      "sudo mv terraform /usr/local/bin/",
      "sudo rm terraform_0.15.5_linux_amd64.zip",
      "sudo aws configure set aws_access_key_id 'AKIASABRXIT6ND2F6QW5'",
      "sudo aws configure set aws_secret_access_key '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'",
      "sudo aws configure set region 'ap-south-1'",
      "sudo chmod +x deploy.sh",  # Set execute permissions for deploy.sh
      "sudo ./deploy.sh",  # Execute your deploy.sh script
      "sudo docker run -d -p 80:80 $AWS_ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/$ECR_REPO_NAME:latest",
      # Add any additional setup or script execution commands here
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"  # Change to the appropriate user based on your AMI
      private_key = file("~/.ssh/id_rsa")  # Replace with the path to your private key file
      host        = self.public_ip
    }
  }
}

output "ec2_instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}
