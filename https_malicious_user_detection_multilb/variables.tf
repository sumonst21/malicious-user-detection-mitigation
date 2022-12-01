variable "api_p12_file" {
	type = string	
	default = "../api-cert.p12"
}

variable "api_url" {
	type = string
	default = "https://your_tenant.console.ves.volterra.io/api"
}

variable "namespace" {
	type = string
	default = "default"
}

variable "domain" {
	type = string
	default = ""
}

variable "originip" {
	type = string
	default = "127.0.0.1"
}

variable "originport" {
	type = string
	default = "80"	
}
