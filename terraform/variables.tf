variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "arc-hybrid-lab"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "koreacentral"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    env = "lab"
  }
}

variable "workspace_name" {
  description = "Log Analytics workspace name (must be globally unique)"
  type        = string
  default     = "arc-hybrid-lab-ws"
}
