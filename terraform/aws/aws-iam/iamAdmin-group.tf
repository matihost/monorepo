# IAM Admin group allow to define priviledges
resource "aws_iam_group" "iamAdmin" {
  name = "IamAdmin"
  path = "/"
}


resource "aws_iam_group_policy_attachment" "iamFullAccessToIamAdminGroup" {
  group      = aws_iam_group.iamAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}
