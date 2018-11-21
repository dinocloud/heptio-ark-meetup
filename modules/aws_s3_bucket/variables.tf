variable "bucket_name" {
  description = "Name of new S3 Bucket"
}

variable "tags" {
  description = "A map of additional tags"
  type        = "map"
  default     = {}
}

variable "force_destroy" {
  description = "Delete all objects in bucket on destroy"
  default     = false
}

variable "acl" {
  description = "Whether bucket is public-read or private"
  default     = "private"
}

variable "versioned" {
  description = "Version the bucket"
  default     = false
}
