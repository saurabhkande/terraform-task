
variable "net-cred" {                     
     type = map
	 default = {
	 
	 "access_key" = "AKIA6FIZKHHDMQJMKBCG" 
	 "secret_key" = "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"
    }
}

variable "region" {
   default = "us-east-1"
}
variable "lb-type" {
   default = "application"
}
variable "lb-name" {
   default = "BG-task-ALB"
}
variable "tg-name" {
   default = "BG-task-ALB-tg"
}
variable "lb-port" {
   default = "80"
}
variable "lb-protocol" {
   default = "HTTP"
}

variable "CB-project-name" {
   default = "B-G-poject"
}

variable "source-type" {
   default = "CODECOMMIT"
}

variable "location" {
   default = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/ssk-repo"
}

variable "pip-name" {
   default = "ECS-blue-green-deployment"
}

variable "artifact-loc" {
   default = "ssk94221"
}

variable "artifact-type" {
   default = "S3"
}

variable "repo" {
   default = "ssk-repo"
}

variable "repo-branch" {
   default = "main"
}

variable "ecr-repo" {
   default = "ssk-ecr-repo"
}

variable "cluster" {
   default = "B-G-task-ecs-cluster"
}

variable "cpu" {
   default = "256"
}

variable "memory" {
   default = "512"
}

variable "con-name" {
   default = "Blue-container"
}

variable "con-port" {
   default = "80"
}

