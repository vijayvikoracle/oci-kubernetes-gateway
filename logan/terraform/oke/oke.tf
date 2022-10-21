locals {
  cluster_details_map = jsondecode(data.local_file.cluster_details.content)
  cluster_name        = tostring(local.cluster_details_map["data"]["name"])
}

data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = var.oke_cluster_ocid
}

data "local_file" "cluster_details" {
  filename   = "${path.module}/local/clusterDetails.json"
  depends_on = [null_resource.cluster_details]
}

# kubeconfig when using Terraform locally. Not used by Oracle Resource Manager
resource "local_file" "oke_kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.oke.content
  filename = "${path.module}/local/kubeconfig"
}

# This resource generates /local/clusterDetails.json which is used to parse OKE Cluster Name
resource "null_resource" "cluster_details" {

  triggers = {
    #cluster_id = var.oke_cluster_ocid
    whenOkeConfigUpdates = data.oci_containerengine_cluster_kube_config.oke.content
  }

  provisioner "local-exec" {
    command = "oci ce cluster get --cluster-id=$CLUSTER_ID > $OUTPUT_FILE"
    environment = {
      CLUSTER_ID  = "${var.oke_cluster_ocid}"
      OUTPUT_FILE = "${path.module}/local/clusterDetails.json"
    }
  }
}