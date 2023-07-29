## LB

resource "oci_load_balancer_load_balancer" "test_load_balancer" {
    #Required
    compartment_id = oci_identity_compartment.Compute_Resources.id
    display_name = "Test LB"
    subnet_ids = [oci_core_subnet.subnet_a.id]
    ip_mode = "IPV4"
    is_private = false
    shape = "flexible"
    shape_details {
        minimum_bandwidth_in_mbps = 10
        maximum_bandwidth_in_mbps = 10
    }
}

resource "oci_load_balancer_backend_set" "test_backend_set" {
    #Required
    health_checker {
        #Required
        protocol = "HTTP"

        #Optional
        interval_ms = "10000"
        port = "80"
        retries = "3"
        return_code = "200"
        timeout_in_millis = "3000"
        url_path = "/"
    }
    load_balancer_id = oci_load_balancer_load_balancer.test_load_balancer.id
    name = "Backend_set"
    policy = "ROUND_ROBIN"
}

resource "oci_load_balancer_backend" "test_backend_1" {
    #Required
    backendset_name = oci_load_balancer_backend_set.test_backend_set.name
    ip_address = oci_core_instance.my_instance_1.private_ip
    load_balancer_id = oci_load_balancer_load_balancer.test_load_balancer.id
    port = "80"

}

resource "oci_load_balancer_backend" "test_backend_2" {
    #Required
    backendset_name = oci_load_balancer_backend_set.test_backend_set.name
    ip_address = oci_core_instance.my_instance_2.private_ip
    load_balancer_id = oci_load_balancer_load_balancer.test_load_balancer.id
    port = "80"

}

resource "oci_load_balancer_listener" "test_listener" {
    #Required
    default_backend_set_name = oci_load_balancer_backend_set.test_backend_set.name
    load_balancer_id = oci_load_balancer_load_balancer.test_load_balancer.id
    name = "Listener"
    port = "80"
    protocol = "HTTP"
}


locals {
    lb_ip = element(oci_load_balancer_load_balancer.test_load_balancer.ip_address_details, 0)
}

output lb_ip_address {
    value = lookup(local.lb_ip, "ip_address")
}
