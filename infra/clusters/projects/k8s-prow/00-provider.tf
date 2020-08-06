terraform {
  required_version = "~> 0.12.20"
  required_providers {
    ibm = "~> 1.9"
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  generation = 2
}
