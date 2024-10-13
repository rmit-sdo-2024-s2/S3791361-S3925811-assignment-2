provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
  token      = ""
}


#terraform {
 # backend "local" {}
#}

terraform {
  backend "s3" {
    bucket         = "foostatebucket1"   
    key            = "terraform/state"    
    region         = "us-east-1"
    dynamodb_table = "foostatelock"       
  }
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "foostatebucket1"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "state_bucket_lock" {
  name           = "foostatelock"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
