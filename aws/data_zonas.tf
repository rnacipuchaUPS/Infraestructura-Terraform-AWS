#Devuelve zonas disponible en ese momento
data "aws_region" "current" {}
data "aws_availability_zones" "available"{
    state = "available"
}
