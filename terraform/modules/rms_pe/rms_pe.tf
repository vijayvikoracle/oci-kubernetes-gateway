# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  # OKE Cluster Metadata
  all_clusters_in_compartment = data.oci_containerengine_clusters.oke_clusters.clusters
  cluster_data                = [for c in local.all_clusters_in_compartment : c if c.id == var.oke_cluster_ocid][0]
  oke_vcn_id                  = local.cluster_data.vcn_id

  is_public_ip_enabled = local.cluster_data.endpoint_config[0].is_public_ip_enabled

  private_endpoint_ocid = var.private_endpoint_ocid == null ? oci_resourcemanager_private_endpoint.rms_pe[0].id : var.private_endpoint_ocid
}

data "oci_containerengine_clusters" "oke_clusters" {
  compartment_id = var.oke_compartment_ocid
  lifecycle {
    postcondition {
      condition = [for c in self.clusters : c if c.id == var.oke_cluster_ocid][0
      ].endpoint_config[0].is_public_ip_enabled == false
      error_message = <<-EOT
        User Input Error:
          RMS Private Endpoint Module is called with public cluster.
          Check: did you check the "is private OKE cluster?" checkbox to monitor a public cluster?
      EOT
    }
  }
}

resource "oci_resourcemanager_private_endpoint" "rms_pe" {
  count          = var.private_endpoint_ocid == null ? 1 : 0
  compartment_id = var.pe_compartmnet_ocid
  display_name   = "oke-monitoring-solution"
  vcn_id         = local.oke_vcn_id
  subnet_id      = var.oke_subnet_ocid

  #tags
  defined_tags  = var.tags.definedTags
  freeform_tags = var.tags.freeformTags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
    precondition {
      condition     = var.oke_subnet_ocid != null
      error_message = <<-EOT
        Private endpoint creation failed due to missing data:
                var.oke_subnet_ocid = ${var.oke_subnet_ocid}
      EOT
    }
  }
}

data "oci_core_subnet" "oke_subnet" {
  count     = var.oke_subnet_ocid != null ? 1 : 0
  subnet_id = var.oke_subnet_ocid

  lifecycle {
    postcondition {
      condition     = self.vcn_id == local.oke_vcn_id
      error_message = <<-EOT
        Subnet ERROR:
          Subnet OCID is not part of OKE VCN: ${local.oke_vcn_id}
      EOT
    }
  }
}

data "oci_resourcemanager_private_endpoint" "rms_pe" {
  count               = var.private_endpoint_ocid != null ? 1 : 0
  private_endpoint_id = var.private_endpoint_ocid

  lifecycle {
    postcondition {
      condition     = self.vcn_id == local.oke_vcn_id
      error_message = <<-EOT
        Private Endpoint ERROR:
          Private Endpoint OCID is not configured with OKE VCN: ${local.oke_vcn_id}
      EOT
    }
  }
}

data "oci_resourcemanager_private_endpoint_reachable_ip" "rechable_ip" {
  private_endpoint_id = local.private_endpoint_ocid
  private_ip          = var.private_ip_address
}