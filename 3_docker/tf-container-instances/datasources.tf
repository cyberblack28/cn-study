data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All.*"]
    regex  = true
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_core_shapes" "shapes" {
  compartment_id = var.compartment_ocid
  filter {
    name   = "name"
    values = ["VM.Standard.E.*Flex"]
    regex  = true
  }
}

data "oci_core_images" "images" {
  compartment_id = var.compartment_ocid
  filter {
    name = "display_name"
    values = ["Canonical-Ubuntu-22.04-2023.09.27-*"]
    regex = true
  }
}
