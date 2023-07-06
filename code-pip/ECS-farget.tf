
module "develop" {
source = "/home/ec2-user/task/terraform3/dev-module/vpc-comp"
providers = {
    aws = aws.dev-account
  }
}

# ECS cluster

resource "aws_ecs_cluster" "B-G-ecs-cluster" {
  name = var.cluster
}

# ECS task definition

resource "aws_ecs_task_definition" "BG_task_definition" {
  family                   = "Blue-task-definition"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  
  container_definitions    = <<EOF
[
  {
    "name": "Blue-container",
    "image": "009609560581.dkr.ecr.us-east-1.amazonaws.com/ssk-ecr-repo:latest",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "ENVIRONMENT",
        "value": "blue"
      }
    ]
   }
]
EOF
}

# ECS service for the blue environment

resource "aws_ecs_service" "BG_service_blue" {
  name            = "BG-service-blue"
  cluster         = aws_ecs_cluster.B-G-ecs-cluster.id
  task_definition = aws_ecs_task_definition.BG_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration {
     subnets          = module.develop.subnet-id
     security_groups  = module.develop.sg_id
     assign_public_ip = true
  }
  
  load_balancer {
   target_group_arn = aws_lb_target_group.BG-task-ALB-tg.arn
   container_name   = var.con-name
   container_port   = var.con-port
 }
}



# ECS Green task definition

resource "aws_ecs_task_definition" "Green_task_definition" {
  family                   = "Green-task-definition"
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  
  container_definitions    = <<EOF
[
  {
    "name": "Green-container",
    "image": "009609560581.dkr.ecr.us-east-1.amazonaws.com/ssk-ecr-repo:latest",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "ENVIRONMENT",
        "value": "Green"
      }
    ]
   }
]
EOF
}

# ECS Green service 

resource "aws_ecs_service" "Green_service" {
  name            = "Green-service"
  cluster         = aws_ecs_cluster.B-G-ecs-cluster.id
  task_definition = aws_ecs_task_definition.Green_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration {
     subnets          = module.develop.subnet-id
     security_groups  = module.develop.sg_id
     assign_public_ip = true
  }
  
  load_balancer {
   target_group_arn = aws_lb_target_group.Green-task-ALB-tg.arn
   container_name   = "Green-container"
   container_port   = "80"
 }
}



# IAM role for the ECS task

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM policies to the ECS task role

resource "aws_iam_role_policy_attachment" "ecs_task_role_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



