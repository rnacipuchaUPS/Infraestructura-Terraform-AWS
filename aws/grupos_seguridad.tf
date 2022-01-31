#Reglas de firewall / grupos de seguridad
resource "aws_default_security_group" "default" {
    vpc_id = aws_vpc.proyecto_tesis.id

    ingress {
        protocol = -1
        self = true
        from_port = 0
        to_port = 0
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "Default"
        Episodeo = "Proyecto Tesis"
    }

    depends_on = [aws_vpc.proyecto_tesis]
}

# Grupo de seguridad

resource "aws_security_group" "servidor_web" {
    name = "Servidor Web"
    description = "Grupo de seguridad para las instancias EC2"
    vpc_id = aws_vpc.proyecto_tesis.id

    tags = {
        Name = "Servidor Web"
        Episodeo = "Proyecto Tesis"
    }
}

# Regla de seguridad http para el grupo de seguridad creado
resource "aws_security_group_rule" "http"{
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.servidor_web.id
    description = "Permitir conexiones al puerto HTTP desde cualquier IP"

    depends_on = [aws_security_group.servidor_web]
}

# Regla de seguridad https para el grupo de seguridad creado
resource "aws_security_group_rule" "https" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol ="tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.servidor_web.id
    description = "Permitir conexiones al puerto HTTP desde cualquier IP"

    depends_on = [aws_security_group.servidor_web]
}

# Regla de seguridad para la conexion por ssh a la maquina
resource "aws_security_group_rule" "ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    #Para acceder desde cualquier parte del mundo
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_group_id = aws_security_group.servidor_web.id
    description = "Permitir conexiones al puerto SSH desde cualquier IP"

    depends_on = [aws_security_group.servidor_web]
}

# Grupo de seguridad de EFS (elastic file system) ficheros de amazon
resource "aws_security_group" "efs" {
    name = "EFS"
    description = "Grupo de seguridad para el disco EFS"
    vpc_id = aws_vpc.proyecto_tesis.id

    tags = {
        Name = "EFS"
        Episodeo = "Proyecto Tesis"
    }
}
# Regla de seguridad para EFS
resource "aws_security_group_rule" "efs" {
    count = length(data.aws_availability_zones.available.zone_ids)
    type = "ingress"
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    #A que bloques de direciones para aplicar en un determinado momento
    cidr_blocks = [element(aws_subnet.public[*].cidr_block, count.index)]
    security_group_id = aws_security_group.efs.id
    description = "Permitir conexiones al puerto HTTP desde cualquier IP"

    depends_on = [aws_security_group.efs]
}
