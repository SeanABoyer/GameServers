resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
}


resource "aws_ecs_cluster" "cluster" {
    name = "${var.game_name}-cluster"
}

resource "aws_ecs_task_definition" "task" {
    family = "${var.game_name}-task"
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    cpu = 2
    memory = 2048
    container_definitions = jsonencode(
        [
            {
                "name":"${var.game_name}-game-container",
                "image":"joedwards32/cs2",
                "cpu":2,
                "memory":2048,
                "portMappings": [
                    {
                        "containerPort":"27015",
                        "hostPort":"27015"
                        "protocol":"tcp"
                    },
                    {
                        "containerPort":"27015",
                        "hostPort":"27015"
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