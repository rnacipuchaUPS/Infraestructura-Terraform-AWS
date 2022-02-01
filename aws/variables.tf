variable "cidr" {
    description = "Direcciones IP privadas a utilizar en el vpc con notacion CIDR"
    default = "10.0.0.0/20"
}

variable "ssh_pub_path" {
    description = "Directorio de la llave SSH publica"
    default = "~/.ssh/id_rsa.pub"
}



