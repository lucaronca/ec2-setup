data "aws_ami" "app-machine" {
  most_recent = true

  filter {
    name   = "name"
    values = [lookup(var.ami, "name")]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = [lookup(var.ami, "owner")]
}

data "template_file" "ssh-public-key" {
  template = file("~/.ssh/id_rsa.pub")
}

resource "aws_key_pair" "deployer" {
  key_name = format(
    "%s-%s-deployer-key",
    lookup(var.instance_tags, "name"), lookup(var.instance_tags, "environment")
  )
  public_key = data.template_file.ssh-public-key.rendered
}

resource "aws_security_group" "app-sg" {
  name = format(
    "%s-%s-%s",
    lookup(var.instance_tags, "name"), lookup(var.instance_tags, "environment"), var.security_group_name
  )
  description = format(
    "%s-%s-%s",
    lookup(var.instance_tags, "name"), lookup(var.instance_tags, "environment"), var.security_group_name
  )

  // To Allow SSH Transport
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "app-sg-ssl" {
  security_group_id = aws_security_group.app-sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]

  count      = var.allow_tls ? 1 : 0
  depends_on = [aws_security_group.app-sg]

  lifecycle {
    create_before_destroy = true
  }
}

#AWS Instance
resource "aws_instance" "app" {
  ami                         = data.aws_ami.app-machine.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  availability_zone           = var.availability_zone
  key_name                    = aws_key_pair.deployer.key_name

  tags = {
    Name        = lookup(var.instance_tags, "name")
    Environment = lookup(var.instance_tags, "environment")
    OS          = lookup(var.instance_tags, "os")
  }

  depends_on = [aws_security_group.app-sg]

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_network_interface_sg_attachment" "sg-attachment" {
  security_group_id    = aws_security_group.app-sg.id
  network_interface_id = aws_instance.app.primary_network_interface_id
}

resource "aws_ebs_volume" "app" {
  availability_zone = var.availability_zone
  size              = 10
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.app.id
  instance_id = aws_instance.app.id
}

resource "aws_cloudwatch_metric_alarm" "ec2-cpu" {
  alarm_name                = "cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = var.cloudwatch_metric_alarm_period #seconds
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.app.id
  }
}
