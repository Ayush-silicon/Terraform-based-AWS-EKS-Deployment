terraform {
  backend "s3" {
    bucket         = "my-tf-state-bucket"
    key            = "eks/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tf-state-lock"
  }
}
