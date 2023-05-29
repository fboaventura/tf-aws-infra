/**
 *
 * # Instances Module
 *
 * This module will create the EC2 instances and all the resources related to it.
 *
 * | Resource | Type | Description |
 * | --- | --- | --- |
 * | Bastion Server | EC2 Instance |  This is the bastion server that will be used to connect to the private instances |
 * | Private Instances | EC2 Instance | We will create one instance per private subnet available |
 * | Application Load Balancer | ALB | This is the load balancer that will be used to distribute the traffic to the private instances |
 * | Target Group | ALB Target Group | This is the target group that will be used to register the private instances |
 * | SSH Key Pair | Key Pair | This is the key pair that will be used to connect to all the instances |
 * | Bastion SSH SG | Security Group | This is the security group that will be used to allow the SSH traffic to the bastion server |
 * | Private Instances SSH SG | Security Group | This is the security group that will be used to allow the traffic from the bastion server to the private instances |
 * | ALB SG | Security Group | This is the security group that will be used to allow the traffic from the internet to the ALB |
 * | Private Instances HTTP SG | Security Group | This is the security group that will be used to allow the traffic from the ALB to the private instances |
 *
 */

locals {
  get_local_ip = var.local_ip != "" ? 0 : 1
  local_ip     = var.local_ip != "" ? var.local_ip : "${chomp(data.http.local_ip[0].response_body)}/32"
  vpc_id       = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.this.id
}

/*********************************
 * DATA SOURCES
 *********************************/
// Identify the current AWS region
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

resource "random_shuffle" "azs" {
  input        = data.aws_availability_zones.available.names
  count        = var.Network.count_subnets_total
  result_count = 1
}

// Identify VPC associated to the current project
data "aws_vpc" "this" {
  tags = {
    "Name" = var.Name
  }
}

// Identify the local public IP address
data "http" "local_ip" {
  count = local.get_local_ip

  url = "https://checkip.amazonaws.com/"

  method = "GET"

  request_headers = {
    "Content-Type" = "text/plain"
    "Accept"       = "text/plain"
  }
}

/*********************************
 * SSH Key Pair
 *********************************/
resource "tls_private_key" "pvt_cert" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  public_key = tls_private_key.pvt_cert.public_key_openssh
  key_name   = "${var.Name}-key"

  tags = merge({
    Name = "${var.Name}-key"
  }, var.Tags)
}

/*********************************
 * Security Groups
 *********************************/

// ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.Name}-alb-sg"
  description = "Controls traffic to the ALB"
  vpc_id      = local.vpc_id

  ingress {
    description = "HTTP traffic from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All traffic to the internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.Network.vpc_cidr]
  }

  tags = merge({
    Name = "${var.Name}-alb-sg"
  }, var.Tags)
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.Name}-bastion-sg"
  description = "Controls traffic to the bastion server"
  vpc_id      = local.vpc_id

  ingress {
    description = "SSH traffic from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.local_ip]
  }

  egress {
    description = "All traffic to the internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.Name}-bastion-sg"
  }, var.Tags)
}

resource "aws_security_group" "private_instances_sg" {
  name        = "${var.Name}-private-instances-sg"
  description = "Control traffic to the private instances"
  vpc_id      = local.vpc_id

  ingress {
    description     = "SSH traffic from the bastion server"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description     = "HTTP traffic from the ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "HTTP traffic from the Bastion Server"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    description = "All traffic to the internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.Name}-private-ssh-sg"
  }, var.Tags)
}

/*********************************
 * Bastion Server Instance
 *********************************/

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.this.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  subnet_id                   = var.Network.public_subnet_ids[0]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/scripts/bastion.sh")

  tags = merge({
    Name = "${var.Name}-bastion"
  }, var.Tags)

  volume_tags = merge({
    Name = "${var.Name}-bastion"
  }, var.Tags)

}

/*********************************
 * Private Instances
 *********************************/

resource "aws_instance" "private" {
  count = var.Network.count_subnets_private

  ami                         = data.aws_ami.golden_image.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.this.key_name
  vpc_security_group_ids      = [aws_security_group.private_instances_sg.id]
  subnet_id                   = var.Network.private_subnet_ids[count.index]
  associate_public_ip_address = false
  user_data                   = file("${path.module}/scripts/instances.sh")

  tags = merge({
    Name = "${var.Name}-pvt-${count.index}"
  }, var.Tags)

  volume_tags = merge({
    Name = "${var.Name}-pvt{count.index}"
  }, var.Tags)

}

/*********************************
 * Application Load Balancer
 *********************************/

resource "aws_lb" "alb" {
  name               = "${var.Name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.Network.public_subnet_ids

  tags = merge({
    Name = "${var.Name}-alb"
  }, var.Tags)
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "${var.Name}-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = merge({
    Name = "${var.Name}-alb-target-group"
  }, var.Tags)
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    type             = "forward"
  }

  tags = merge({
    Name = "${var.Name}-alb-listener"
  }, var.Tags)
}

resource "aws_lb_listener_rule" "alb_listener_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/", "/*"]
    }
  }

  tags = merge({
    Name = "${var.Name}-alb-listener-rule"
  }, var.Tags)
}

resource "aws_lb_target_group_attachment" "alb_target_group_attachment" {
  count            = var.Network.count_subnets_private
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.private[count.index].id
  port             = 80
}
