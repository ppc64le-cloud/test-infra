variable "ibmcloud_api_key" {
  description = "IBM api key for the authentication."
  type        = string
}

variable "name" {
  description = "Name of the IKS cluster"
  type        = string
}

variable "vpc_name" {
  description = "VPC that you want to use for your cluster"
  type        = string
}

variable "zones" {
  description = "The zones assign the cluster."
  type        = list(string)
}

variable "worker_count" {
  description = "The number of worker nodes per zone in the default worker pool"
  type        = number
}
