# Create dev instance
resource "aws_instance" "dev" {
        instance_type = "${var.dev_instance_type}"
        ami = "${var.dev_ami}"
        tags {
                Name = "dev"
        }
        key_name = "${aws_key_pair.auth.id}"
        vpc_security_group_ids = ["${aws_security_group.public.id}"]
        iam_instance_profile = "${aws_iam_instance_profile.s3_access.id}"
        subnet_id = "${aws_subnet.public.id}"
        provisioner "local-exec" {
                command = "cat <<EOF > aws_hosts
[dev]
${aws_instance.dev.public_ip}
[dev:vars]
s3code=${aws_s3_bucket.code.bucket}
EOF"
        }
        provisioner "local-exec" {
                command = "sleep 6m && ansible-playbook -i aws_hosts 05-wordpress.yml"
        }
}

