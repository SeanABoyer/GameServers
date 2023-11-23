resource "random_password" "password" {
  length = 16
  special = false
}

locals {
    gamename = "CS2"
    lgsmfilename = "cs2server"
    username = "GameAdmin"
}