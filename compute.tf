data "oci_identity_availability_domains" "ads" {
  compartment_id = oci_identity_compartment.Compute_Resources.id
}

output "name-of-first-availability-domain" {
  value = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

resource "oci_core_instance" "my_instance_1" {
    # Required
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = oci_identity_compartment.Compute_Resources.id
    shape = "VM.Standard.E2.1.Micro"
    source_details {
        source_id = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaabgr47stuemgyryj5cvavqihfqekbavc6o4a6kuf6se3oek6cbl3a"
        source_type = "image"
    }

    # Optional
    display_name = "Instance-A"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = oci_core_subnet.subnet_a.id
    }
    metadata = {
        ssh_authorized_keys = file(var.ssh_instance_key)
    } 
    preserve_boot_volume = false
}

### Test with remote exec

# Execute commands in Linux Instance

resource "null_resource" "remote-exec_1" {

  depends_on = [oci_core_instance.my_instance_1]

  provisioner "remote-exec" {

    connection {
      agent       = false
      timeout     = "30m"
      host        = oci_core_instance.my_instance_1.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key)

    }

    inline = [

      "sudo yum install -y httpd",
      "sudo firewall-cmd --zone=public --add-service=http --permanent",
      "sudo firewall-cmd --zone=public --add-service=https --permanent",
      "sudo firewall-cmd --reload",
      "sudo yum install -y git",
      "sudo git clone https://github.com/REKKKLESS/Test_Terraform.git ~/web",
      "sudo cp ~/web/first.html /var/www/html/index.html",
      "sudo cp -r ~/web /var/www/html",
      "sudo systemctl start httpd"

    ]

  }

}

resource "oci_core_instance" "my_instance_2" {
    # Required
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = oci_identity_compartment.Compute_Resources.id
    shape = "VM.Standard.E2.1.Micro"
    source_details {
        source_id = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaabgr47stuemgyryj5cvavqihfqekbavc6o4a6kuf6se3oek6cbl3a"
        source_type = "image"
    }

    # Optional
    display_name = "Instance-B"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = oci_core_subnet.subnet_b.id
    }
    metadata = {
        ssh_authorized_keys = file(var.ssh_instance_key)
    } 
    preserve_boot_volume = false
}

### Test with remote exec

# Execute commands in Linux Instance

resource "null_resource" "remote-exec_2" {

  depends_on = [oci_core_instance.my_instance_2]

  provisioner "remote-exec" {

    connection {
      agent       = false
      timeout     = "30m"
      host        = oci_core_instance.my_instance_2.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key)

    }

    inline = [

      "sudo yum install -y httpd",
      "sudo firewall-cmd --zone=public --add-service=http --permanent",
      "sudo firewall-cmd --zone=public --add-service=https --permanent",
      "sudo firewall-cmd --reload",
      "sudo yum install -y git",
      "sudo git clone https://github.com/REKKKLESS/Test_Terraform.git ~/web",
      "sudo cp ~/web/test.html /var/www/html/index.html",
      "sudo cp -r ~/web/ /var/www/html",
      "sudo systemctl start httpd"

    ]

  }

}
