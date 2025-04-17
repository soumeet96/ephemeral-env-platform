app_name = "go-project"

branch_name = "feature-login"

container_image = "637423232823.dkr.ecr.us-east-1.amazonaws.com/go-dev:feature-login"

vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs_1 = ["10.0.1.0/24"]

public_subnet_cidrs_2 = ["10.0.2.0/24"]

private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

azs = ["us-east-1a", "us-east-1b"]

hosted_zone_id = "Z00614253F6R1L4576VOA"

domain_name = "soumeet.store"

destroy_after_secs = 86400