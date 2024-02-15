locals {
  ad    = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

resource oci_container_instances_container_instance cn_study_container_instance {
  availability_domain = local.ad
  compartment_id      = var.compartment_ocid
  container_restart_policy = "ALWAYS"
  containers {
    display_name = "WordPress"
    image_url = "wordpress"
    is_resource_principal_disabled = "false"
    environment_variables = {
      "WORDPRESS_DB_HOST" = "127.0.0.1",
      "WORDPRESS_DB_USER" = "wordpress",
      "WORDPRESS_DB_PASSWORD" = "wordpress",
      "WORDPRESS_DB_NAME" = "wordpress"
    }    
  }
  containers {
    display_name = "MySQL"
    image_url = "mysql:8.0.30"
    is_resource_principal_disabled = "false"
    environment_variables = {
      "MYSQL_ROOT_PASSWORD" = "wordpressonmysql",
      "MYSQL_DATABASE" = "wordpress",
      "MYSQL_USER" = "wordpress",
      "MYSQL_PASSWORD" = "wordpress"
    }   
  }
  display_name = "WordPress"
  graceful_shutdown_timeout_in_seconds = "0"
  shape                                = "CI.Standard.E4.Flex"
  shape_config {
    memory_in_gbs = 16
    ocpus         = 1
  }
state = "ACTIVE"
  vnics {
    display_name           = "${var.prefix}-ci"
    is_public_ip_assigned  = "true"
    skip_source_dest_check = "true"
    subnet_id              = oci_core_subnet.cn_study_public_subnet.id
  }
}
