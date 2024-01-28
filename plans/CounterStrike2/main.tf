terraform {
    required_version = ">=1.1.3"
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "4.40.0"
      }
    }
}
provider "aws" {
    default_tags {
        tags = {
            Name = var.game_name
            Game = var.game_name
        }
    }
}

data "aws_availability_zones" "availability_zones" {
  filter {
    name = "region-name"
    values = [var.region]
  }
}

#START NETWORKING
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc.id
}


resource "aws_route" "route_ign_to_vpc" {
  route_table_id = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id  
}

resource "aws_vpc" "vpc" {
    
    cidr_block = var.cidr_block
    tags = {
      name =  "${var.game_name}-vpc"
    }
}

resource "aws_subnet" "subnet_az_one" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block,8,0)
  availability_zone = data.aws_availability_zones.availability_zones.names[0]
}

resource "aws_subnet" "subnet_az_two" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block,8,1)
  availability_zone = data.aws_availability_zones.availability_zones.names[1]
}

# resource "aws_security_group" "alb_sg"{
#     name =  "${var.game_name}-alb-sg"
#     vpc_id = aws_vpc.vpc.id
#     ingress {
#         from_port = 27015
#         to_port = 27015
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     ingress {
#         from_port = 27015
#         to_port = 27015
#         protocol = "udp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     egress {
#         from_port   = 0
#         to_port     = 0
#         protocol    = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
# }

# resource "aws_lb" "alb" {
#   name = "${var.game_name}-alb"
#   load_balancer_type = "application"
#   subnets = [aws_subnet.subnet_az_one.id,aws_subnet.subnet_az_two.id]
#   security_groups = [aws_security_group.alb_sg.id] 
# }

# resource "aws_lb_target_group" "alb_target_group" {
#     name = "${var.game_name}-alb-tg"
#     port = 27015
#     protocol = "TCP_UDP"
#     target_type = "ip"
#     vpc_id = aws_vpc.vpc.id
# }

# resource "aws_lb_listener" "alb_listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port = 27015
#   protocol = "TCP_UDP"
#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.alb_target_group.arn
#   }
# }
#END NETWORKING

resource "aws_ecs_cluster" "cluster" {
    name = "${var.game_name}-cluster"
}

resource "aws_ecs_task_definition" "task" {
    depends_on = [ aws_ecs_cluster.cluster ]
    family = "${var.game_name}-task"
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    cpu = 2048
    memory = 4096
    container_definitions = jsonencode(
        [
            {
                "name":"${var.game_name}-task",
                "image":"joedwards32/cs2",
                "environment":[
                    {
                        "name":"CS2_PORT",
                        "value":"27014"
                    },
                    {
                        "name":"SRCDS_TOKEN",
                        "value":"${var.steamGSLT}"
                    }
                ]
                "cpu":2,
                "memory":2048,
                "portMappings": [
                    {
                        "containerPort":27020,
                        "hostPort":27020
                        "protocol":"tcp"
                    },
                    {
                        "containerPort":27015,
                        "hostPort":27015
                        "protocol":"tcp"
                    },
                    {
                        "containerPort":27014,
                        "hostPort":27014
                        "protocol":"udp"
                    }
                ]
            }
        ]
    )
    volume {
        name = "${var.game_name}-efs"
        efs_volume_configuration {
            file_system_id = aws_efs_file_system.efs.id
            root_directory = "/${var.game_name}-task/"
            transit_encryption = "ENABLED"


        }
    }
}

resource "aws_efs_file_system" "efs" {}

resource "aws_ecs_service" "ecs_service" {
  name = "${var.game_name}-task"
  cluster = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type = "FARGATE"
  desired_count = 1

#   load_balancer {
#     target_group_arn = aws_lb_target_group.alb_target_group.arn
#     container_name = aws_ecs_task_definition.task.family
#     container_port = 27015
#   }

  network_configuration {
    subnets = [aws_subnet.subnet_az_one.id,aws_subnet.subnet_az_two.id]
    assign_public_ip = true
    security_groups = [aws_security_group.ecs_service_sg.id]
  }
}

resource "aws_security_group" "ecs_service_sg" {
    vpc_id = aws_vpc.vpc.id
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
         cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}