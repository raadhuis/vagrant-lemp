# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 80,    host: 80
  config.vm.network "forwarded_port", guest: 3306,  host: 33306

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "10.4.4.58"
  config.vm.synced_folder "public", "/var/www/", :mount_options => ["dmode=777", "fmode=666"]
  config.vm.hostname = "raadhuis"
  config.ssh.forward_agent = true

  config.vm.provision :shell, path: ENV['provisionscript']

end
