data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "web" {

  name_prefix = "${var.project_name}-web-"

  image_id = data.aws_ami.amazon_linux.id

  instance_type = "t3.micro"

  vpc_security_group_ids = [
    var.web_sg_id
  ]

  user_data = base64encode(<<-EOF
#!/bin/bash

dnf update -y

dnf install nginx -y

systemctl enable nginx

systemctl start nginx

echo "<h1>Web Tier Running</h1>" > /usr/share/nginx/html/index.html

EOF
  )

  tag_specifications {

    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-web"
    }
  }
}

resource "aws_launch_template" "app" {

  name_prefix = "${var.project_name}-app-"

  image_id = data.aws_ami.amazon_linux.id

  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.app_instance_profile_name
  }

  vpc_security_group_ids = [
    var.app_sg_id
  ]

  user_data = base64encode(<<-EOF
#!/bin/bash

dnf update -y

dnf install python3 python3-pip -y

pip3 install flask gunicorn boto3

mkdir -p /opt/app

cat > /opt/app/app.py << 'PYTHON'
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Flask App Tier Running"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PYTHON

nohup python3 /opt/app/app.py &
EOF
  )

  tag_specifications {

    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-app"
    }
  }
}

resource "aws_autoscaling_group" "web" {

  name = "${var.project_name}-web-asg"

  desired_capacity = 2

  min_size = 2

  max_size = 4

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    var.target_group_arn
  ]

  launch_template {

    id = aws_launch_template.web.id

    version = "$Latest"
  }

  health_check_type = "ELB"

  health_check_grace_period = 300

  tag {

    key = "Name"

    value = "${var.project_name}-web"

    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "app" {

  name = "${var.project_name}-app-asg"

  desired_capacity = 2

  min_size = 2

  max_size = 4

  vpc_zone_identifier = var.private_subnet_ids

  launch_template {

    id = aws_launch_template.app.id

    version = "$Latest"
  }

  tag {

    key = "Name"

    value = "${var.project_name}-app"

    propagate_at_launch = true
  }
}