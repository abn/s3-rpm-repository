provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_key_pair" "deployer" {
  key_name = "deployer-key" 
  public_key = "${file("${var.key_file}")}"
}

resource "aws_security_group" "ssh-only" {
  name = "ssh-only"
  description = "Allow all ssh traffic"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instance" {
    ami = "${var.ami}"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.deployer.key_name}"
    security_groups = [
        "${aws_security_group.ssh-only.name}"
    ]
    iam_instance_profile = "${var.prefix}_profile"
}

resource "aws_s3_bucket" "b" {
    bucket = "${var.bucket}"
    acl = "private"
}

resource "aws_iam_instance_profile" "profile" {
    name = "${var.prefix}_profile"
    roles = ["${aws_iam_role.role.name}"]
}

resource "aws_iam_role_policy" "policy" {
    name = "${var.prefix}_role_policy"
    role = "${aws_iam_role.role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1424867341000",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.b.bucket}"
      ]
    },
    {
      "Sid": "Stmt1424867403000",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.b.bucket}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "role" {
    name = "${var.prefix}_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
