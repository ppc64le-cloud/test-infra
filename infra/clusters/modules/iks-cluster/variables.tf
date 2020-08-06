variable "ibmcloud_api_key" {
  description = "IBM api key for the authentication."
  type        = string
}

variable "generation" {
  description = "IBM VPC generation"
  type        = string
  default     = 2
}

variable "name" {
  description = "Name of the IKS cluster"
  type        = string
}

variable "resource_group" {
  description = "The resource group where you want to provision your cluster"
  type        = string
  default     = "Default"
}

variable "vpc_name" {
  description = "VPC that you want to use for your cluster"
  type        = string
}

variable "zones" {
  description = "The zones assign the cluster."
  type        = list(string)
}

variable "flavor" {
  description = "The flavor of the VPC worker node that you want to use. Run 'ibmcloud ks flavors --zone <zone name>'"
  type        = string
  default     = "bx2.8x32"
}

variable "worker_count" {
  description = "The number of worker nodes per zone in the default worker pool"
  type        = number
  default     = 1
}

variable "kube_version" {
  description = "Specify the Kubernetes version to be installed. To see available versions, run 'ibmcloud ks versions'"
  type        = string
  default     = "1.17.7"
}

variable "wait_till" {
  description = "Supported stages are: MasterNodeReady, OneWorkerNodeReady and IngressReady(default)"
  default = "IngressReady"
}
