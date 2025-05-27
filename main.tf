variable "api_url" {}
variable "api_key" {}
variable "secret_key" {}
variable "docker_image_name" {
  description = "Name des Docker-Containers, der gestartet werden soll"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "tfstate28675" # Dein tatsächlicher Name
    container_name       = "tfstate"
    key                  = "terraform/dev.tfstate"
    use_cli = false
  }
}

terraform {
  required_providers {
    cloudstack = {
      source  = "cloudstack/cloudstack"
      version = "0.5.0"
    }
  }
}

provider "cloudstack" {
  api_url    = var.api_url
  api_key    = var.api_key
  secret_key = var.secret_key
}



# Netzwerk definieren
resource "cloudstack_network" "vlan_network" {
  name             = "NetworkTU2"
  display_text     = "VLAN Network for Linux VMs"
  network_offering = "12d4fc87-3718-40b0-9707-2b53b8555cda"  # Beispiel-Network Offering
  zone             = "a4848bf1-b2d1-4b39-97e3-72106df81f09" # Zone-ID
  cidr             = "10.1.1.0/24"
}


resource "cloudstack_egress_firewall" "default" {
  network_id = cloudstack_network.vlan_network.id

  rule {
    cidr_list = ["10.1.1.0/24"]
    protocol  = "all"
  }
}

resource "cloudstack_ipaddress" "public_ip" {
  network_id = cloudstack_network.vlan_network.id
}

resource "cloudstack_port_forward" "nginx_http" {
  ip_address_id = cloudstack_ipaddress.public_ip.id # Referenziert die öffentliche IP-Adresse
  forward {
    protocol          = "tcp"
    private_port      = 80                      # Port der VM
    public_port       = 80                      # Externer Port
    virtual_machine_id = cloudstack_instance.vm2.id # Ziel-VM
  }
}
resource "cloudstack_port_forward" "ssh" {
  ip_address_id = cloudstack_ipaddress.public_ip.id # Referenziert die öffentliche IP-Adresse
  forward {
    protocol          = "tcp"
    private_port      = 22                      # Port der VM
    public_port       = 22                      # Externer Port
    virtual_machine_id = cloudstack_instance.vm2.id # Ziel-VM
  }

}

# Firewall von public ip öffnen für Ports 80, 22 und 3389 für TCP
resource "cloudstack_firewall" "allow_http" {
  ip_address_id = cloudstack_ipaddress.public_ip.id # Öffentliche IP-Adresse
  depends_on = [ cloudstack_port_forward.nginx_http, cloudstack_port_forward.ssh ]

  rule {
    protocol  = "tcp"
    cidr_list = ["0.0.0.0/0"] # Zugriff von überall erlauben
    ports     = ["80","22"]        # Port öffnen
  }
}



# Virtuelle Maschine 1 erstellen
resource "cloudstack_instance" "vm2" {
  name              = "linux-vm2"
  display_name      = "Linux VM 2"
  service_offering  = "Big Instance"
  template          = "f5295a59-8eb5-4c73-9768-cf67dcf3656b"
  zone              = "a4848bf1-b2d1-4b39-97e3-72106df81f09"
  network_id        = cloudstack_network.vlan_network.id
  root_disk_size    = 20
  keypair           = "tuttas"
  expunge           = true
  ip_address        = "10.1.1.100"

  # Cloud-Init für Passwort, Gateway und DNS
  user_data = <<EOT
#cloud-config
datasource:
  None

network:
  config: disabled

password: geheim
chpasswd:
  list: |
    ubuntu:geheim
  expire: False
ssh_pwauth: True

write_files:
  - path: /tmp/test-file.txt
    permissions: '0644'
    content: |
      Hello, this is a test file.
  - path: /etc/netplan/51-cloud-init.yaml
    permissions: '0644'
    content: |
      network:
        version: 2
        ethernets:
          ens3:
            optional: false
            dhcp4: false
            addresses:
              - 10.1.1.100/24
            nameservers:
              addresses:
                - 8.8.8.8
            routes:
              - to: default
                via: 10.1.1.1

bootcmd:
  - ip link set ens3 up

runcmd:
  - netplan generate
  - netplan apply
  - apt-get update -y
  - curl -fsSL https://get.docker.com | sudo bash
  - docker pull tuttas/devops
  - docker run -d -p 80:80 tuttas/devops
EOT
}



# Ausgaben definieren
output "vm1_id" {
  value = cloudstack_instance.vm2.id
}

output "network_id" {
  value = cloudstack_network.vlan_network
}
output "public_ip" {
  value       = cloudstack_ipaddress.public_ip.ip_address
  description = "Die öffentliche IP-Adresse des Netzwerks"
}
