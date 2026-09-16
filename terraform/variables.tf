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

variable "vm_name" {
  description = "Azure VM name for hybrid networking"
  type        = string
  default     = "cloud-vm"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1ls"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for the VM admin user"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+HKN7gcOxo+asgsGs1+wd766cNy7s2K0jUQ3tfz28DW3YTEF7j2mVNNagEyMfuw7DwQtLlQvZt98dOsAPHJZryz8F+egmD1ViAaGntPKf6XqnQdLoVzIlEWM8kpYtt5XxR7m/NGT6kRVtmbYTcthJgL9TaM8OhvYsgNrhNevHTNeEzK2E65HYQaWWv7jF/G3eDmX/p/rG446LPrWhZUzP2OmGg5YdG42Q8IiWhEgwxw6W376Vq8M6KiMWf8sRDPchlFQgQmah4W95tKm5joAbBHX2Vqg2mpOIHmd2zBse6CAN5lA+aDHyVAtb9EqivlAC75IWRKuJbT50Xs8O+x5nc2BrJi4OahsUcEPfz8pZLQUyMH4Pj+PeMxjZYJAv7MKXUS1ujM/9UG/yHDyFy133NPJ+uRnv+g2xyGgdVhHcbrKS9K2MaqA4rDT1M+I/vazCvbuqydiAT00FajRBJVVHJutNYgTc3wa+3BGrtFMNrr6aGzC240j63f5kniwxf6mZEN4TjQ89hKeBUOs3oVxpswVKLHpdE4g9Tih4fpNZi5FJ4+VzSfDZ/g4rWw60+CBnwvCxtspIghjg5W8QO99qkw83A+tebUpTwGLPDWMxqO0fLAX9ksJZ2OsqnsnEw6ZLCPlHk7xDs2fXEfQxwygx9ydK8LuwtWU6b72weeYs3Q== terraform-provisioning"
}

variable "ssh_source_ip" {
  description = "Source IP (CIDR) allowed to SSH into the VM"
  type        = string
  default     = "108.94.142.34/32"
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key to join the tailnet"
  type        = string
  sensitive   = true
  default     = ""
}
