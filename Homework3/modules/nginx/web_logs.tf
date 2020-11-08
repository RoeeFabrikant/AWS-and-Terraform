
resource "aws_s3_bucket" "opsschool_s3_bucket" {
    acl = "private"
    tags = {
        Name    = "${var.project_name}_web_logs"
    }
}

resource "aws_iam_role" "ec2_s3_write_role" {
  name                  = "ec2-s3-write-role"
  assume_role_policy    = file("iam_role_policy.json")
}

resource "aws_iam_policy" "ec2_s3_write_policy" {
  name                  = "ec2-s3-write-policy"
  policy                = file("s3_policy_write.json")
}

resource "aws_iam_policy_attachment" "iam_role_policy_attach" {
  name                  = "iam-role-policy-attach"
  roles                 = [aws_iam_role.ec2_s3_write_role.name]
  policy_arn            = aws_iam_policy.ec2_s3_write_policy.arn
}

resource "aws_iam_instance_profile" "iam_role_s3_write_profile" {
  name                  = "iam-role-s3-write-profile"
  role                  = aws_iam_role.ec2_s3_write_role.name
}