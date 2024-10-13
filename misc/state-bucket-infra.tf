provider "aws" {
  region     = "us-east-1"
  access_key = "ASIA6GF37BXSYLHYOYPA"
  secret_key = "iZLnX9/gxZvlIHWkeLnFxtsgfsTpydYxvv4hymWm"
  token      = "IQoJb3JpZ2luX2VjEC8aCXVzLXdlc3QtMiJIMEYCIQCuH+EYk6vL3edQDlySyLV0Evr2XnWZZZXI7seFW6OIawIhALrE+bEheyUbegk/pOBH0t6I3X/mDKuxh6umEaAK3uvxKq4CCIj//////////wEQABoMOTc1MzUxNzc4Nzg5IgzRe7rRw6qdq2pwo8kqggKwR46HpJLHGQOESYGJHuE+XBzmwiTNJ7ISiEWr+KpJ5LeW4EvsPnZG/+NHnVpOr+OHJZZTx5D9JnlFJCafEEVF0E763FCxpYvHAK+nvTuF8yhLeuQoQs6kwWgDVCSountrHcO9iKUXzppdWf0tm4Qn+2bkMrhkRCUVoNBVrJkaxMs+bSBC9Oiq62hdC16KARXI2K8DH5763lfp8SlShGCSH2PPrq4HAN72vB1o+Olb+MilVJExVxFM76dGVqMo8OIrMGYm5vdGs4l7P6Hb2oLiKKb2aGnz5Yjhe1K/IprlmLzeWqIYVC99UpsXW8fYQqrRRN9yrAICHYTnHEkSkyHbElowiJKjuAY6nAFYn6msQY6fOybnKdAwRy9VWXWcJ9EW+VkbH7VEqKPrgK8qP9pf8R5eYH3ZWHRJA74QeCFdkHhJpTam94TsBP6RjNjVC9nCTiPkmT3X5Mdww4izw2ratmMRBtrY+cb+G/UElXxeFWF2tGhd1iMDdpaCD2OIf2KXwlzKG7AIUhHg/xMeFK09R3rEh6evOzYsCe48j+1zHFwOZue+C7Q="
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
