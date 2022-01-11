#######################
# iam user and policy #
#######################
resource "aws_iam_user" "flavio-adm" {
  name = "flavio-adm"
  tags = {
      Description = "Flavio Admin user"
  }
}

resource "aws_iam_policy" "adminUser" {
  name = "adminUsers"
  policy = file("admin-policy.json")
}

resource "aws_iam_user_policy_attachment" "flavio-admin-access" {
  user = aws_iam_user.flavio-adm.name
  policy_arn = aws_iam_policy.adminUser.arn
}

# resource "aws_iam_access_key" "flavio-access-key" {
#   user = aws_iam_user.flavio-adm.name  
# }
# 
# output "flavio-access-key" {
#   value = aws_iam_access_key.flavio-access-key.id
# }

#######################
# S3 buckets #
#######################

resource "aws_s3_bucket" "terraform-bucket" {
  bucket = "flaviofuka-terraform-bucket"
  acl = "private"

  tags = {
      Description = "bucket used for terraform learning"
      Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "pets" {
  key = "pets.txt"
  bucket = aws_s3_bucket.terraform-bucket.id
  source = "./local-outputs/pets.txt"
  
}

data "aws_iam_group" "dummy" {
    group_name = "dummy"
}

resource "aws_s3_bucket_policy" "terraform-buck-policy" {
  bucket = aws_s3_bucket.terraform-bucket.id
  policy = <<EOF
    {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": "*",
                    "Resource": "arn:aws:s3:::${aws_s3_bucket.terraform-bucket.id}/*",
                    "Principal":{
                        "AWS":[
                            "${aws_iam_user.flavio-adm.arn}"
                        ]
                    }
                }
            ]
    }

  EOF
}

# imported resource
resource "aws_s3_bucket" "imp-bucket" {
  acl                         = "private"
  force_destroy               = false
  bucket                      = "flaviofuka-imp-bucket"
  tags                        = {}

}

########################
# EC2 Instances and Security Group
########################

# resource "aws_instance" "python-etl" {
#   ami = "ami-0ed9277fb7eb570c9"
#   instance_type = "t2.micro"
# 
#   tags = {
#     Name = "Python Etl"
#   }
# 
#   key_name = aws_key_pair.python-etl.id
#   vpc_security_group_ids = [aws_security_group.ssh-access.id]
# }

resource "aws_security_group" "ssh-access" {
  name = "ssh-access"
  description = "Allow ssh access"
  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "python-etl" {
  public_key = file("dummy-ssh-key.pub")
}