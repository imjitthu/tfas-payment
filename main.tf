locals {
  key_name = "test"
  key_path = "test.pem"
}

resource "aws_instance" "payment" {
  ami = data.aws_ami.ami.id
  instance_type = "${var.INSTANCE_TYPE}"
  tags = {
    "Name" = "${var.COMPONENT}-${var.env}"
  }

connection {
  host = aws_instance.payment.public_ip
  type = "ssh"
  user = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["SSH_USER"]
  password = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["SSH_PASS"]
}

provisioner "remote-exec" {
  inline = [ 
  "set-hostname ${var.COMPONENT}",
  "yum install python36 gcc python3-devel -y",
   ]
}

provisioner "local-exec" {
  command = "echo ${aws_instance.payment.public_ip} > payment_inv"
}
}

resource "aws_route53_record" "jithendar" {
  name          = "${var.COMPONENT}.${data.aws_route53_zone.jithendar.name}"
  type          = "A"
  ttl           = "300"
  zone_id       = data.aws_route53_zone.jithendar.zone_id
  records       = [aws_instance.payment.public_ip]
}
