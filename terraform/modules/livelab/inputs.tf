# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# OCID of user running the marketplace app / Resoruce Manager stack
variable "current_user_ocid" {
  type = string
}

variable "debug" {
  type    = bool
  default = false
}