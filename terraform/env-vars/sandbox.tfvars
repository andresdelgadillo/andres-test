
aws_region_1   = "us-west-2"
aws_account    = "416572346136"
environment    = "sandbox"
s3_bucket      = "andres-test-terraform-sandbox"
s3_key         = "terraform/tfresources/tfstate"
dynamodb_table = "andres-test-terraform"
app_name       = "andres-test"
allowed_cidr   = ["191.107.11.232/32", "191.107.11.233/32"]

tags = {
  product-family   = "Blankfactor"
  application-name = "andres-test"
  account-name     = "sandbox"
  environment      = "sandbox"
  managed-by       = "https://mock.blankfactor.com/andres-test"
}

vpc_1 = {
  cidr = "10.0.0.0/16"

  subnets = {
    private = {
      snapp1a = {
        az         = "a"
        cidr       = "10.0.0.0/24"
        nat_subnet = "snpub1a"
      }
      snapp1b = {
        az         = "b"
        cidr       = "10.0.1.0/24"
        nat_subnet = "snpub1b"
      }
    }
    private_rds = {
      snrds1a = {
        az         = "a"
        cidr       = "10.0.2.0/24"
        nat_subnet = "snpub1a"
      }
      snrds1b = {
        az         = "b"
        cidr       = "10.0.3.0/24"
        nat_subnet = "snpub1b"
      }
    }
    public = {
      snpub1a = {
        az   = "a"
        cidr = "10.0.128.0/24"
      }
      snpub1b = {
        az   = "b"
        cidr = "10.0.129.0/24"
      }
    }
  }
}
instances = {
  desired_capacity = "1"
  max_size         = "4"
  min_size         = "1"
}
rds = {
  instance_class = "db.t3.micro"
  multi_az       = false
}
