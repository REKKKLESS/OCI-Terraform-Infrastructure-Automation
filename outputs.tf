output compute_compartment {
    value = oci_identity_compartment.Compute_Resources.id
    description = "The Network Compartment OCID."
}

output vcn_a_id {
  value       = oci_core_vcn.vcn_a.id
  description = "The VCN A OCID."
}

output igw_1 {
    value = oci_core_internet_gateway.igw_1.id
    description = "The IGW-1 OCID."    
}

output route_table_a {
    value = oci_core_route_table.route_table_a.id
    description = "The Route Table A OCID."
}

output public_ip_instance_1 {
    value = oci_core_instance.my_instance_1.public_ip
}

output public_ip_instance_2 {
    value = oci_core_instance.my_instance_2.public_ip
}
