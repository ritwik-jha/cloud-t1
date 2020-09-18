provider "aws" {
	region = "ap-south-1"
	profile = "default"
	}

resource "aws_key_pair" "keypair1" {
		key_name = "mykey5"
		public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2"

}

resource "aws_security_group" "sg1" {
		name = "security_wizard_8"
		
		
		ingress {
			from_port = 80
			to_port = 80
			protocol = "http"
		}

		ingress {
			from_port = 0
			to_port = 0
			protocol = "ssh"
		}

		egress {
			from_port = 0
			to_port = 0
			protocol = "-1"
		}
		tags = {
			Name = "security_wizard_5"
		}
	}


resource "aws_instance" "codeins_1" {
				ami = "ami-052c08d70def0ac62"
			instance_type = "t2.micro"

			tags = {
				Name = "automated_instance"
				}
			security_groups = ["${aws_security_group.sg1.id}"] 
			key_name = "${aws_key_pair.keypair1.key_name}"
			}

resource "aws_ebs_volume" "esb1" {
  		availability_zone = aws_instance.codeins_1.availability_zone
                        		 size = 1
  	
		tags = {
    			Name = "ebs_vol"
		  }
	}

resource "aws_volume_attachment" "ebs_att" {
 			 device_name = "/dev/sdh"
			  volume_id   = "${aws_ebs_volume.esb1.id}"
 			 instance_id = "${aws_instance.codeins_1.id}"
			  force_detach = true
	}

resource "null_resource" "mount" {
		depends_on = [
   			 aws_volume_attachment.ebs_att,
			  ]


  connection {
   		 type     = "ssh"
   		 user     = "ec2-user"
   		 host_key = aws_key_pair.keypair1.public_key
   		 host     = aws_instance.codeins_1.public_ip
  	}

provisioner "remote-exec" {
   			 inline = [
					"sudo yum  install httpd -y",
					"sudo systemctl start httpd",
      				"sudo mkfs.ext4  /dev/xvdh",
     				 "sudo mount  /dev/xvdh  /var/www/html",
     				 "sudo rm -rf /var/www/html/*",
     				 "sudo git clone https://github.com/ritwik-jha/instance_automation.git /var/www/html/",
					 "sudo systemctl restart httpd",
   				 ]
 			 }
	}

resource "aws_s3_bucket" "bucket1" {
 		 bucket = "ritbucket123"
		  acl    = "public-read"

		  tags = {
			  Name = "my bucket"
		  }
	}

resource "aws_s3_bucket_object"  "first_one" {
		key                    = "image"
  		bucket                 = aws_s3_bucket.bucket1.id
  		source                 = "https://github.com/ritwik-jha/instance_automation.git/Screenshot.png"
}











