locals {
  cidr_block                = "192.168.0.0/16"
  cidr_block_public_subnet  = "192.168.0.0/24"
  cidr_block_private_subnet = "192.168.1.0/24"
  cidr_block_all            = "0.0.0.0/0"
  all_services              = data.oci_core_services.all_services.services.0
  destination_type_cidr     = "CIDR_BLOCK"
  destination_type_service  = "SERVICE_CIDR_BLOCK"
  protocol_all              = "all"
  protocol_icmp             = "1"
  protocol_tcp              = "6"
}

##### VCN #####
resource "oci_core_vcn" "cn_study_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = local.cidr_block
  display_name   = "cn-study-vcn"
}

##### Gateway #####
resource "oci_core_internet_gateway" "cn_study_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.cn_study_vcn.id
  display_name   = "cn-study-igw"
}

resource "oci_core_nat_gateway" "cn_study_ngw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.cn_study_vcn.id
  display_name   = "cn-study-ngw"
}

resource "oci_core_service_gateway" "cn_study_sgw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.cn_study_vcn.id
  display_name   = "cn-study-sgw"
  services {
    service_id = local.all_services.id
  }
}

##### Route Table #####
resource "oci_core_default_route_table" "public_route_table" {
  manage_default_resource_id = oci_core_vcn.cn_study_vcn.default_route_table_id
  compartment_id             = var.compartment_ocid
  display_name               = "cn-study-pub-rt"
  route_rules {
    destination       = local.cidr_block_all
    destination_type  = local.destination_type_cidr
    network_entity_id = oci_core_internet_gateway.cn_study_igw.id
  }
}

##### Security Lists #####
resource "oci_core_security_list" "cn_study_pub_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.cn_study_vcn.id
  display_name   = "cn-study-sl"
  ingress_security_rules {
    protocol = local.protocol_tcp
    source   = local.cidr_block_all
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    protocol = local.protocol_tcp
    source   = local.cidr_block_all
    tcp_options {
      max = "80"
      min = "80"
    }
  }
  ingress_security_rules {
    protocol = local.protocol_tcp
    source   = local.cidr_block_all
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  ingress_security_rules {
    protocol = local.protocol_icmp
    source   = local.cidr_block_all
    icmp_options {
      type = "3"
      code = "4"
    }
  }
  ingress_security_rules {
    protocol = local.protocol_icmp
    source   = local.cidr_block
    icmp_options {
      type = "3"
    }
  }
  egress_security_rules {
    description = "Allow trafic for all ports"
    destination = local.cidr_block_all
    protocol    = local.protocol_all
  }
}

resource "oci_core_security_list" "cn_study_pri_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.cn_study_vcn.id
  display_name   = "cn-study-pri-sl"
  ingress_security_rules {
    protocol = local.protocol_tcp
    source   = local.cidr_block
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  ingress_security_rules {
    protocol = local.protocol_icmp
    source   = local.cidr_block_all
    icmp_options {
      type = "3"
      code = "4"
    }
  }
  ingress_security_rules {
    protocol = local.protocol_icmp
    source   = local.cidr_block
    icmp_options {
      type = "3"
    }
  }
  egress_security_rules {
    description = "Allow trafic for all ports"
    destination = local.cidr_block_all
    protocol    = local.protocol_all
  }
}

##### Subnet #####
resource "oci_core_subnet" "cn_study_public_subnet" {
  cidr_block                 = local.cidr_block_public_subnet
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.cn_study_vcn.id
  security_list_ids          = [oci_core_security_list.cn_study_pub_sl.id]
  display_name               = "cn-study-public-subnet"
  route_table_id             = oci_core_vcn.cn_study_vcn.default_route_table_id
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "cn_study_private_subnet" {
  cidr_block        = local.cidr_block_private_subnet
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.cn_study_vcn.id
  security_list_ids = [oci_core_security_list.cn_study_pri_sl.id]
  display_name      = "cn-study-private-subnet"
  route_table_id    = oci_core_vcn.cn_study_vcn.default_route_table_id
}