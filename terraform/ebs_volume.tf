resource "aws_ebs_volume" "persistent_volume" {
  availability_zone = "us-west-1a"
  size              = 150
  type              = "gp2"

  tags = {
    Name = "persistent volume test"
  }
}