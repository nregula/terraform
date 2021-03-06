# Creating VPC - 02

- Subnet associations with the Public Route Table
	- Associate the public subnet

	```
	resource "aws_route_table_association" "public_assoc" {
		subnet_id = "${aws_subnet.public.id}"
		route_id = "${aws_route_table.public.id}"
	}
	```

	- Associate the private subnet 1

	```
	resource "aws_route_table_association" "private1_assoc" {
		subnet_id = "${aws_subnet.private1.id}"
		route_id = "${aws_route_table.public.id}"
	}
	```

	- Associate the private subnet 2

	```
	resource "aws_route_table_association" "private2_assoc" {
		subnet_id = "${aws_subnet.private2.id}"
		route_id = "${aws_route_table.public.id}"
	}
	```

	- Associate RDS Subnets

	```
	resource "aws_db_subnet_group" "rds_subnet_group" {
		name = "rds_subnet_group"
		subnet_ids = ["${aws_subnet.rds1.id}", "${aws_subnet.rds2.id}", "${aws_subnet.rds3.id}"]
		tags {
			Name = "rds_sng"
		}
	}
	```

- Let us create the security groups
	- Add Jumphost Security Group
	
	```
	resource "aws_security_group" "jumphost" {
		name = "sg_jumphost"
		description = "Used for Jump host access"
		vpc_id = "${aws_vpc.vpc.id}"
		
		# SSH-INGRESS
		ingress {
			from_port	= 22
			to_port		= 22
			protocol	= "tcp"
			cidr_blocks	= ["0.0.0.0/0"]
		}
		tags {
			Name = "sg-jumphost"
		}
	}
	```
	
	- Add PUBLIC Security Group
	
	```
	resource "aws_security_group" "public" {
		name = "sg_public"
		description = "Used for Public and Private instances for load balancer access"
		vpc_id = "${aws_vpc.vpc.id}"
	
		# SSH-INGRESS
		ingress {
			from_port	= 22
			to_port		= 22
			protocol	= "tcp"
	#		cidr_blocks	= ["${var.localip}"]
			cidr_blocks	= ["10.1.0.0/16"]
		}
		
		# HTTP-INGRESS
		ingress {
			from_port	= 80
			to_port		= 80
			protocol	= "tcp"
			cidr_blocks	= ["0.0.0.0/0"]
		}
	
		# HTTP-EGRESS
		egress {
			from_port	= 0
			to_port		= 0
			protocol	= "-1"
			cidr_blocks	= ["0.0.0.0/0"]
		}
		tags {
			Name = "sg_public"
		}
	}
	```
	
	- Add PRIVATE Security Group
	
	```
	resource "aws_security_group" "private" {
		name = "sg_private"
		description = "Used for private instances"
		vpc_id = "${aws_vpc.vpc.id}"
		
		# Access from other security groups
		ingress {
			from_port	= 0
			to_port		= 0
			protocol	= "-1"
			cidr_blocks	= ["10.1.0.0/16"]
		}
		egress {
			from_port	= 0
			to_port		= 0
			protocol	= "-1"
			cidr_blocks	= ["0.0.0.0/0"]
		}
		tags {
			Name = "sg_private"
		}
	}
	```
	
	- Add RDS Security Group
	
	```
	resource "aws_security_group" "rds" {
		name = "sg_rds"
		description = "Used for DB instances"
		vpc_id = "${aws_vpc.vpc.id}"
	
		# SQL access from public/private security group
		ingress {
			from_port	= 3306
			to_port		= 3306
			protocol	= "tcp"
			security_groups	= ["${aws_security_group.public.id}", "${aws_security_group.private.id}"]
		}
		tags {
			Name = "sg_rds"
		}
	}
	```
