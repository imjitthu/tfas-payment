terraform {
  backend "s3" {
    bucket = "terraform-state-jithendar"
    key    = "rs-instances/paymant.tfstate"
    region = "us-east-1"
  }
}