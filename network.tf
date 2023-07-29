## Compute Compartment

resource "oci_identity_compartment" "Compute_Resources" {
    #Required
    compartment_id = var.compartment_id
    description = var.compute_compartment_description
    name = var.compute_compartment_name
    enable_delete = true
}

## VCN A

resource "oci_core_vcn" "vcn_a" {
  dns_label      = "internal"
  cidr_block     = var.cidr_block_vcn_a
  compartment_id = oci_identity_compartment.Compute_Resources.id
  display_name   = var.vcn_name_a
  freeform_tags = {"environment"= "vcn_a"}
}

## IGW A

resource "oci_core_internet_gateway" "igw_1" {
    #Required
    compartment_id = oci_identity_compartment.Compute_Resources.id
    vcn_id = oci_core_vcn.vcn_a.id

    #Optional
    display_name = var.internet_gateway_display_name_a
}

## ROUTE TABLE A

resource "oci_core_route_table" "route_table_a" {
    #Required
    compartment_id = oci_identity_compartment.Compute_Resources.id
    vcn_id = oci_core_vcn.vcn_a.id

    #Optional
    display_name = var.route_table_display_name_a

    route_rules {
        network_entity_id = oci_core_internet_gateway.igw_1.id
        description = "IGW to the world."
        destination = var.open_to_the_world

    }
}

## ROUTE TABLE B

resource "oci_core_route_table" "route_table_b" {
    #Required
    compartment_id = oci_identity_compartment.Compute_Resources.id
    vcn_id = oci_core_vcn.vcn_a.id

    #Optional
    display_name = var.route_table_display_name_b

    route_rules {
        network_entity_id = oci_core_internet_gateway.igw_1.id
        description = "IGW to the world."
        destination = var.open_to_the_world

    }
}

## SUBNET A

resource "oci_core_subnet" "subnet_a" {
    #Required
    cidr_block = var.subnet_a_cidr_block
    compartment_id = oci_identity_compartment.Compute_Resources.id
    vcn_id = oci_core_vcn.vcn_a.id

    #Optional
    display_name = var.subnet_a_display_name
    route_table_id = oci_core_route_table.route_table_a.id
    security_list_ids = [oci_core_security_list.security_list_a.id]
    freeform_tags = {"environment"= "subnet_a"}
}

## SUBNET B

resource "oci_core_subnet" "subnet_b" {
    #Required
    cidr_block = var.subnet_b_cidr_block
    compartment_id = oci_identity_compartment.Compute_Resources.id
    vcn_id = oci_core_vcn.vcn_a.id

    #Optional
    display_name = var.subnet_b_display_name
    route_table_id = oci_core_route_table.route_table_a.id
    security_list_ids = [oci_core_security_list.security_list_b.id]
    freeform_tags = {"environment"= "subnet_b"}
}

## SECURITY LIST A

resource "oci_core_security_list" "security_list_a" {
    #Required
    compartment_id = oci_identity_compartment.Compute_Resources.id
    vcn_id = oci_core_vcn.vcn_a.id
    display_name = var.security_list_name_a

    #Optional
    egress_security_rules {
        #Required
        destination = var.open_to_the_world
        protocol = "all"
    }
    # ingress_security_rules {
    #     #Required
    #     protocol = "6"
    #     source = var.open_to_the_world
    #     tcp_options {
    #         min = "22"
    #         max = "22"
    #     }
    # }
    # ingress_security_rules {
    #     #Required
    #     protocol = "6"
    #     source = var.open_to_the_world
    #     tcp_options {
    #         min = "80"
    #         max = "80"
    #     }
    # }
    dynamic "ingress_security_rules" {
        for_each = local.ingress_ports
        content {
            protocol = "6"
            source = var.open_to_the_world
            tcp_options {
                min = ingress_security_rules.value
                max = ingress_security_rules.value
            }
        }

    }
}

## SECURITY LIST B

resource "oci_core_security_list" "security_list_b" {
    #Required
    compartment_id = oci_identity_compartment.Compute_Resources.id
    vcn_id = oci_core_vcn.vcn_a.id
    display_name = var.security_list_name_b

    #Optional
    egress_security_rules {
        #Required
        destination = var.open_to_the_world
        protocol = "all"
    }
    # ingress_security_rules {
    #     #Required
    #     protocol = "6"
    #     source = var.open_to_the_world
    #     tcp_options {
    #         min = "22"
    #         max = "22"
    #     }
    # }
    # ingress_security_rules {
    #     #Required
    #     protocol = "6"
    #     source = var.open_to_the_world
    #     tcp_options {
    #         min = "80"
    #         max = "80"
    #     }
    # }
    dynamic "ingress_security_rules" {
        for_each = local.ingress_ports
        content {
            protocol = "6"
            source = var.open_to_the_world
            tcp_options {
                min = ingress_security_rules.value
                max = ingress_security_rules.value
            }
        }

    }
}

locals {
    ingress_ports = [80,22,3389,443]
}
