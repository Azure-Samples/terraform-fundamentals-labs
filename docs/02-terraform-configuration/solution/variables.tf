# variables.tf

variable prefix {
    type = string
    default = "contoso"
}

variable region {           
    type = string
    default = "UK South"
}

variable tags {
    type = map
}
