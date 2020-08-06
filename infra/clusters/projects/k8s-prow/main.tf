module "prow_build_cluster" {
  source = "../../modules/iks-cluster"
  ibmcloud_api_key = var.ibmcloud_api_key
  name = var.name
  vpc_name = var.vpc_name
  zones = var.zones
  worker_count = var.worker_count
}
