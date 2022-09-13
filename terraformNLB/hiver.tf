
# Subnet Creation.


resource "aws_subnet" "private_subnet" {
  vpc_id                  = "vpc-dde928bb"
  cidr_block              = "172.31.32.0/20"
  availability_zone       = "us-west-1b"
  tags = {
    Name        = "private-subnet"
  }
}


# Security Group Creation.



resource "aws_security_group" "allow_tls" {
  name        = "hiver_SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-dde928bb"

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hiver_SG"
  }
}



# Two r5.large EC2 creation with name prod-web-server1 and 2 respectively.

resource "aws_instance" "prod-web-server" {
  ami = "ami-00831fc7c1e3ddc60"
  count = 2
  instance_type = "r5.large"
  security_groups = ["${aws_security_group.allow_tls.id}"]
  subnet_id = "${aws_subnet.private_subnet.id}"
  tags = {
    Name = "prod-web-server-${count.index+1}"
  }
}


# Target Group Creation.


resource "aws_lb_target_group" "test" {
  name     = "tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = "vpc-dde928bb"
}



# Network Load Balancer Creation



resource "aws_lb" "test" {
  name               = "hiverNLB"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["subnet-941dd1ce"]

  tags = {
    Environment = "production"
  }
}


# Listeners Creation.


resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.test.id
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.test.id
    type             = "forward"
  }
}


# Attaching both the EC2s to the target group.



resource "aws_lb_target_group_attachment" "test" {
  count = 2
  target_group_arn = "${aws_lb_target_group.test.arn}" 
   target_id = "${aws_instance.prod-web-server[count.index].id}"
  port             = 80
}






