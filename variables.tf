variable "instance_count" {
  default = [{count=1,name="dse"}, {count=0,name="opsc"}]
}

variable "instance_type" {
  default = ["i3.8xlarge","t2.2xlarge"]
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "ami_id" {
  default = "ami-06b263d6ceff0b3dd"
}

variable "key_name" {
  default = "djoy"
}