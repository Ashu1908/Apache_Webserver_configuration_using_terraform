provider "aws" {
 region                = "us-east-1"
 profile               = "default"
}


resource "aws_instance" "webos1" {
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  security_groups = ["webserver group"]
  key_name = "terraform_key"

  tags = {
    Name = "Web server by TF"
  }
}


resource "null_resource" "nullremote1" {

connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Ashu/Downloads/terraform_key.pem")
    host     = aws_instance.webos1.public_ip
  }

 provisioner "remote-exec" {
    inline = [
      "sudo yum install git -y", 
      "sudo mkdir /var/www/html/web",
      "sudo git clone https://github.com/Ashu1908/git-workshop.git /var/www/html/web",
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
     
    ]
  }
}

resource "aws_ebs_volume" "example" {
  availability_zone = aws_instance.webos1.availability_zone
  size              = 1

  tags = {
    Name = "Webserver HD by TF"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.webos1.id
  force_detach = true
}

resource "null_resource" "nullremote2" {

connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Ashu/Downloads/terraform_key.pem")
    host     = aws_instance.webos1.public_ip
  }

 provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdc", 
      "sudo mount /dev/xvdc /var/www/html",
     
    ]
  }
}





