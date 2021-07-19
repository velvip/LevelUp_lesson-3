resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey" # Create "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "balancer" {
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.kp.key_name
  instance_type          = "t2.micro"
  private_ip             = "192.168.0.199" #Create ip address in private network
  subnet_id              = aws_subnet.subnet_public.id
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]
  tags = {
    Name = "balancer"
  }
  provisioner "remote-exec" {
    inline = [ #install nginx server
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
  provisioner "file" { #copy conf file to VM
    source      = "./conf_file/balancer.conf"
    destination = "/tmp/balancer.conf"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/balancer.conf /etc/nginx/conf.d/balancer.conf",
      "sudo rm /etc/nginx/sites-enabled/default",
      "sudo service nginx restart",
    ]
  }
  connection { #Connect to VM
    host        = aws_instance.balancer.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.pk.private_key_pem
  }
}
resource "aws_instance" "backend" {
  count                  = var.backend_count
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.kp.key_name
  instance_type          = "t2.micro"
  private_ip             = format("192.168.0.20%d", count.index + 1) #Create ip address in private network
  subnet_id              = aws_subnet.subnet_public.id
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]
  tags = {
    Name = "${format("backend-%d", count.index + 1)}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
  provisioner "file" { #copy site to VM
    source      = "site"
    destination = "/tmp/site"
  }
  provisioner "file" { #copy conf file to VM
    source      = "./conf_file/site.conf"
    destination = "/tmp/site.conf"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/site.conf /etc/nginx/conf.d/site.conf",
      "sudo rm /etc/nginx/sites-enabled/default",
      "sudo mv /tmp/site /var/www/site",
      "sudo service nginx restart",
    ]
  }

  connection { #Connect to VM
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.pk.private_key_pem
  }
}