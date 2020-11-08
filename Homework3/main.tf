module "vpc" {
  source = "./modules/vpc"
  
  web_servers_id            = module.nginx.nginx_id # Don't change this line

  project_name              = "opsschooll"
  vpc_cidr                  = "10.10.0.0/16"
  private_subnet_cidr       = ["10.10.10.0/24", "10.10.11.0/24"]
  public_subnet_cidr        = ["10.10.20.0/24", "10.10.21.0/24"]
  
}

module "nginx" {
    source = "./modules/nginx"

    public_sub_id             = module.vpc.public_sub # Don't change this line
    web_server_sg             = module.vpc.nginx_sg   # Don't change this line

    project_name              = "opsschooll"
    num_of_web_servers        = 2
    web_servers_intance_type  = "t2.micro"
    intances_private_key_name = "<YOUR-KP-NAME-HERE>"
    owner_name                = "<YOUR-NAME-HERE>"

}

module "db" {
  source = "./modules/db"

  private_subnet_id         = module.vpc.private_sub  # Don't change this line
  db_server_sg              = module.vpc.db_sg        # Don't change this line

  project_name              = "opsschooll"
  num_of_db_servers         = 2
  db_servers_intance_type   = "t2.micro"
  intances_private_key_name = "<YOUR-KP-NAME-HERE>"
  owner_name                = "<YOUR-NAME-HERE>"

}