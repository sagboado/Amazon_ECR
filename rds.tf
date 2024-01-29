# Confifure Database

resource "aws_db_instance" "setri_db" {
  identifier           = "db-setri"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = "Mafiwars21"  # Replace with a secure password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  tags = {
    Name = "SetriDB"
  }
}