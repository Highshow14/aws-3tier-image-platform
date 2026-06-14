resource "aws_iam_role" "app" {

  name = "${var.project_name}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "s3" {

  name = "${var.project_name}-s3-policy"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::${var.raw_bucket_name}",
          "arn:aws:s3:::${var.raw_bucket_name}/*"
        ]
      },

      {
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]

        Resource = [
          "arn:aws:s3:::${var.processed_bucket_name}/*"
        ]
      },

      {
        Effect = "Allow"

        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]

        Resource = [
          var.kms_key_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3" {

  role = aws_iam_role.app.name

  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_iam_instance_profile" "app" {

  name = "${var.project_name}-app-profile"

  role = aws_iam_role.app.name
}
