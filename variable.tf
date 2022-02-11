variable "vpc-cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR Block"
  type        = string
}

variable "public-subnet-cidr" {
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
  description = "Public Subnet CIDR Block"
}

variable "private-subnet-cidr" {
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
  description = "Private Subnet CIDR Block"
}
