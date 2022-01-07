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