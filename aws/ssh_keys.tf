#Creacion de llaves ssh en Amazon

resource "aws_key_pair" "keyssh" {
    key_name = "keyssh"
    public_key = file(var.ssh_pub_path)

    tags = {
        Name = "keyssh"
        Usuario = "Rodrigo Nacipucha"
        Episodeo = "Proyecto Tesis"
    }
}
