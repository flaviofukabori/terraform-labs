resource "local_file" "pet" {
   filename = "./local-outputs/pets.txt"
   content = "We love pets!! petname is ${var.catname}"

   lifecycle {
     create_before_destroy = true
   }
 
 }
 
resource "local_file" "dog" {
   filename = "./local-outputs/dogs5.txt"
   content = "We very much love dogs! dog name is ${var.dogname}"

   lifecycle {
     create_before_destroy = true
   }
}
 
#resource "local_file" "keys-env-outs" {
#   filename = "./keys-env-outs.txt"
#   content = "output of secret keys is ${var.SECRET_KEY2}"
#}

resource "local_file" "pet-dog" {
  filename = "./local-outputs/pet-dog.txt"
  content = "pet-dog content is here ab"

  depends_on = [
    local_file.dog, local_file.pet
  ]
}

resource "local_file" "reference-to-dog" {
  filename = "./local-outputs/reference-to-dog.txt"
  content = "reference content is ${local_file.dog.content}"
}

resource "local_file" "undestroyable-dog" {
  filename = "./local-outputs/undestroyable-dog2.txt"
  content = "this is a undestroyable-dog ${local_file.pet-dog.id}"

  lifecycle {
    prevent_destroy = false
  }
}

data "local_file" "unmanaged-pet" {
  filename = "./local-outputs/unmanaged-pet.txt"
}

resource "local_file" "pet-refs-unmanaged" {
  filename = "./local-outputs/pet-refs-unmanaged.txt"
  content = "${data.local_file.unmanaged-pet.content}"
}

output "dog-id" {
  value = local_file.dog.id
}