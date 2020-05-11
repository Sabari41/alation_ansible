resource "aws_key_pair" "aws_key" {
  key_name    = "${var.aws_key_name}"
  public_key  = file("${var.public_key_path}")
}