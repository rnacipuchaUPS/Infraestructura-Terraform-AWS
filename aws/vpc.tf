# Confiuracion de una red privada virtual
resource "aws_vpc" "proyecto_tesis" {
    cidr_block = var.cidr
    assign_generated_ipv6_cidr_block = false
    enable_dns_hostnames = true  //Servico de DNS dentro de la red virtual

    tags = {
        Name = "VPC Tests"
        Episodio = "Proyecto Tesis"
    }

    lifecycle {
        prevent_destroy = false
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.proyecto_tesis.id
    count = length(data.aws_availability_zones.available.zone_ids)
    cidr_block = cidrsubnet(var.cidr, 4, 0 + count.index)
    map_public_ip_on_launch = false
    availability_zone = element(data.aws_availability_zones.available.names, count.index)

    tags = {
        Name = "Red publica-${count.index}"
        Episodeo = "Informe Nube 4"
    }

    depends_on = [aws_vpc.proyecto_tesis]
}

resource "aws_subnet" "privada" {
    vpc_id = aws_vpc.proyecto_tesis.id
    count = length(data.aws_availability_zones.available.zone_ids)
    cidr_block = cidrsubnet(var.cidr, 4, 6 + count.index)
    map_public_ip_on_launch = false
    availability_zone = element(data.aws_availability_zones.available.names, count.index)

    tags = {
        Name = "Red publica-${count.index}"
        Episodeo = "Proyecto Tesis"
    }

    depends_on = [aws_vpc.proyecto_tesis]
}

#Configuracion de la Puerta de salida o gateway

resource "aws_internet_gateway" "informe_nubec" {
    vpc_id = aws_vpc.proyecto_tesis.id

    tags = {
        Name = "Internet Gateway"
        Episodeo = "Proyecto Tesis"
    }

    lifecycle {
        prevent_destroy = false
    }

    depends_on = [aws_vpc.proyecto_tesis]
}

# Routes

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.proyecto_tesis.id
    #Internet
    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.informe_nubec.id
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.informe_nubec.id
    }

    tags = {
        Name = "Tabla de Route para las redes public"
        Episodeo = "Proyecto Tesis"
    }
}

#Asociacion de las redes con la tabla de rutas

resource "aws_route_table_association" "public" {
    count = length(data.aws_availability_zones.available.zone_ids)
    route_table_id = aws_route_table.public.id
    subnet_id = element(aws_subnet.public[*].id,count.index)

    depends_on = [aws_route_table.public]
}
