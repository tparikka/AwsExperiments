variable "account_id" {
  type = string
  description = "The 12-digit AWS account number."
  default = "597933701843"
}

variable "github_repository" {
  type = string
  description = "The GitHub repo to be permitted to interact with AWS."
  default = "tparikka/AwsExperiments"
}

variable "idp_thumbprint" {
  type = string
  description = "The thumbprint of the IDP to be trusted."
  default = "d89e3bd43d5d909b47a18977aa9d5ce36cee184c"
}