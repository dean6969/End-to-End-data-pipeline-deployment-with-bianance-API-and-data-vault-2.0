# Tạo EC2 Instance
resource "aws_instance" "my_ec2" {
  ami           = "ami-0474411b350de35fb" # Thay bằng AMI phù hợp với vùng của bạn
  instance_type = "t2.large"

  tags = {
    Name = "${var.project_name}-airflow-app-${var.env_name}"
  }

  iam_instance_profile = aws_iam_instance_profile.my_ec2_role.name

  user_data = <<-EOF
  #!/bin/bash
  sudo yum -y update
  sudo yum -y install ruby
  sudo yum -y install wget

  # setup docker
  sudo yum install -y docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user

  # setup docker-compose
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  # moving to home/ec2-user
  cd /home/ec2-user

  # install and setup CodeDeploy agent
  wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
  sudo chmod +x ./install
  sudo ./install auto

  # setup aws cli and install python-pip
  sudo yum install -y python-pip
  sudo pip install awscli
EOF

  security_groups = [aws_security_group.ec2_sg.name] # add security group for instance
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-airflow-sg-${var.env_name}"
  description = "Block all inbound traffic and allow only SSM outbound traffic"

   
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = ["0.0.0.0/0"]  
  }

  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "ec2_sg_with_ssm"
  }
}


resource "aws_iam_role" "my_ec2_role" {
  name = "${var.project_name}-ec2_role-${var.env_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_codedeploy_policy" {
  role       = aws_iam_role.my_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "ec2_session_mananger_policy" {
  role       = aws_iam_role.my_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "my_ec2_role" {
  name = "${var.project_name}-instance_profile-${var.env_name}"
  role = aws_iam_role.my_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_secret_mananger_policy" {
  role       = aws_iam_role.my_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "ec2_s3r_policy" {
  role       = aws_iam_role.my_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy" "kinesis_put_record_policy" {
  name        = "KinesisPutRecordPolicy"
  description = "Allows EC2 to put records into a Kinesis stream"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "kinesis:PutRecord",
        "kinesis:PutRecords"
      ],
      Resource = "*"  
    }]
  })
}


resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.my_ec2_role.name
  policy_arn = aws_iam_policy.kinesis_put_record_policy.arn
}