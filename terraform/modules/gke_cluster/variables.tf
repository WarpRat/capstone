variable "name" {
  description = "(Required) A name for the GKE cluster."
}

variable "location" {
  description = "(Required) The location for the cluster. Defining a zone here will create a single-zone cluster. Defining a region here will create a regional cluster"
}

variable "dashboard_enabled" {
  description = "(Optional) Enable the kubernetes dashboard."
  default     = true
}

variable "monitoring" {
  description = "(Optional) What type of monitoring to use. Options are 'monitoring.googleapis.com', 'monitoring.googleapis.com/kubernetes', or 'none'"
  default     = "monitoring.googleapis.com/kubernetes"
}

variables "min_node_count" {
  description = "(Optional) The minimum number of nodes in the autoscaling node group."
  default     = 1
}

variable "max_node_count" {
  description = "(Optional) The maximum number of nodes in the autoscaling node group."
  default     = 10
}

variable "preemptible" {
  description = "(Optional) Use preemptible nodes. Only suitable for workloads that can be inturrupted."
  default     = false
}

variable "machine_type" {
  description = "(Optional) The type of Compute Engine instances to deploy for the nodes. Can be a preset GCE type or in the format 'custom-$CPU-$MEMORYMB' (e.g. custom-6-10240)"
  default     = "n1-standard-1"
}

variable "disk_size" {
  description = "(Optional) The size of the local disk to attach to nodes in GB."
  default     = 50
}

variable "disk_type" {
  description = "(Optional) The type of disk to attach to nodes, options are 'pd-standard' or 'pd-ssd'"
  default     = "pd-standard"
}

variable "node_labels" {
  description = "(Optional) A map of kubernetes labels to add to nodes in this node pool"
  default     = {}
  type        = "map"
}

variable "image_type" {
  description = "(Optional) What image to use on the nodes, options are 'COS', 'COS_CONTAINERD', or 'UBUNTU'"
  default     = "COS"
}

variable "auto_repair" {
  description = "(Optional) Enable auto-repair on nodes."
  default     = true
}

variable "auto_update" {
  description = "(Optional) Enable auto-update on nodes."
  default     = true
}
