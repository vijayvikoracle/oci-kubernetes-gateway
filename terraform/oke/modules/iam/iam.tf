# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  # Compartments
  la_compartment_name  = data.oci_identity_compartment.oci_la_compartment.name
  oke_compartment_name = data.oci_identity_compartment.oke_compartment.name

  # Dynmaic Group
  uuid_dynamic_group            = md5(var.oke_cluster_ocid)
  dynamic_group_name            = "oci-kubernetes-monitoring-${local.uuid_dynamic_group}"
  dynamic_group_desc            = "Auto generated by Resource Manager Stack - oci-kubernetes-monitoring. Required for monitoring OKE Cluster - ${var.oke_cluster_ocid}"
  instances_in_compartment_rule = ["ALL {instance.compartment.id = '${var.oke_compartment_ocid}'}"]
  clusters_in_compartment_rule  = ["ALL {resource.type = 'cluster', resource.compartment.id = '${var.oke_compartment_ocid}'}"]
  management_agent_rule = ["ALL {resource.type='managementagent', resource.compartment.id='${var.macs_agent_compartment_ocid}'}"]
  dynamic_group_matching_rules  = concat(local.instances_in_compartment_rule, local.clusters_in_compartment_rule, local.management_agent_rule)
  complied_dynamic_group_rules  = "ANY {${join(",", local.dynamic_group_matching_rules)}}"

  # Policy
  uuid_policy       = md5("${local.dynamic_group_name}${local.la_compartment_name}")
  policy_name       = "oci-kubernetes-monitoring-${local.uuid_policy}"
  policy_desc       = "Auto generated by Resource Manager Stack - oci-kubernetes-monitoring. Allows OKE Dynamic Group - ${local.dynamic_group_name} to upload data to Logging Analytics Service in ${local.la_compartment_name} compartment."
  policy_scope      = var.root_compartment_ocid == var.oci_la_logGroup_compartment_ocid ? "tenancy" : "compartment ${local.la_compartment_name}"
  macs_agent_policy = ["Allow dynamic-group ${local.dynamic_group_name} to use METRICS in ${local.policy_scope} WHERE target.metrics.namespace = 'mgmtagent_kubernetes_metrics'"]
  fluentd_agent_policy = ["Allow dynamic-group ${local.dynamic_group_name} to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in ${local.policy_scope}"]
  policy_statements = concat(local.fluentd_agent_policy, local.macs_agent_policy)
}

# Logging Analytics Compartment
data "oci_identity_compartment" "oci_la_compartment" {
  id = var.oci_la_logGroup_compartment_ocid
}

# OKE Compartment
data "oci_identity_compartment" "oke_compartment" {
  id = var.oke_compartment_ocid
}

# Dynmaic Group
resource "oci_identity_dynamic_group" "oke_dynamic_group" {
  name           = local.dynamic_group_name
  description    = local.dynamic_group_desc
  compartment_id = var.root_compartment_ocid
  matching_rule  = local.complied_dynamic_group_rules
  #provider       = oci.home_region
}

# Policy
resource "oci_identity_policy" "oke_monitoring_policy" {
  name           = local.policy_name
  description    = local.policy_desc
  compartment_id = var.oci_la_logGroup_compartment_ocid
  statements     = local.policy_statements
  #provider       = oci.home_region

  depends_on = [oci_identity_dynamic_group.oke_dynamic_group]
}
