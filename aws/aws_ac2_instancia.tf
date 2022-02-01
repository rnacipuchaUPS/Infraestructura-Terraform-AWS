#Reserva de una IP publica Elastic IPS
resource "aws_eip" "simple"{
    vpc = true

    tags ={
        Name = "IP elastica"
        Episodeo = "Proyecto Tesis"
    }

    lifecycle {
        prevent_destroy = false
    }
}

resource "aws_instance" "simple" {
    count = 1
    availability_zone = "us-east-1a" 
    ami = "ami-04505e74c0741db8d"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public[0].id
    vpc_security_group_ids = concat([aws_security_group.servidor_web.id], [aws_default_security_group.default.id]) //concatenando arrays en terraform
    key_name = aws_key_pair.keyssh.id

    #Ciclo de vida
    lifecycle {
        create_before_destroy = true
    }

    root_block_device {
        #Volumen de proposito general SSD(gp2)
        volume_type = "gp2"
        volume_size = "8"
        delete_on_termination = true

    }
    user_data = <<-EOF
                  #!/bin/bash
                  # ---> Updating, upgrating and installing the base
                  sudo apt-get update
                  sudo apt-get install \
                  ca-certificates \
                  curl \
                  gnupg \
                  lsb-release
                  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                  echo \
                  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
                  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                  sudo apt-get update && apt-get upgrade -y
                  sudo apt install docker-ce -y
                  systemctl start docker
                  sudo usermod -aG docker ubuntu
                  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                  sudo chmod +x /usr/local/bin/docker-compose
                  
                  EOF

    tags = {
        Name = "EC2 simple en ${aws_subnet.public[count.index].availability_zone}"
        Episodeo = "Proyecto Tesis"
    }

    depends_on = [aws_vpc.proyecto_tesis, aws_key_pair.keyssh, aws_security_group.servidor_web]

}

resource "aws_eip_association" "simple" {
    instance_id = aws_instance.simple[0].id
    allocation_id = aws_eip.simple.id
}

output "simple_dns" {
    value = aws_eip.simple.public_dns
}

/*output "ssh" {
    value = "ssh -l ubuntu ${aws_eip.web.public_ip}"
}*/
