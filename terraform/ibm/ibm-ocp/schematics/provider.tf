# optional, but beware Schematics use default region which may be not the onne you intent
provider "ibm" {
  region = var.region
  zone   = var.zone
}
