terraform {
    backend "s3"{
        bucket  = "buckt-test"
        key = "terraform.tfstate"
        encrypt = "true"

    }
}

# Configurcion del proveedor
provider "aws" {
    region = "us-east-1"
}
