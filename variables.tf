variable location {
	type = string
	default = "westeurope"
}

variable prefix {
    type = string
    default = "team6Workspace"
}

variable tags {
  type = map

  default = {
    Environment = "Terraform"
    Dept        = "DevOps"
  }
}

variable subscription_id {
	type = string
}

variable client_appId {
	type = string
}  

variable client_password {
	type = string
} 

variable tenant_id  {
	type = string
}

variable admin_username {
  default = "pf-team-6"
}

variable admin_password {
  default = "xaki6"
}
