variable "resource_group_id" {
  description = "Resource group ID for the policy assignments"
  type        = string
}

variable "required_tag_name" {
  description = "Tag name required by the tag policy"
  type        = string
  default     = "env"
}

variable "allowed_locations" {
  description = "Regions allowed by the location policy"
  type        = list(string)
  default     = ["koreacentral"]
}
