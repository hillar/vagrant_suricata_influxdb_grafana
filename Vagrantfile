# -*- mode: ruby -*-
# vi: set ft=ruby :

boxes = [
  { :name => :influxdb,:ip => '192.168.33.111',:forward => 8086,:cpus => 2,:mem => 1024,:provision => 'provision_influxdb.bash' },
  { :name => :grafana,:ip => '192.168.33.112',:forward => 3003,:cpus => 1,:mem => 256, :provision => 'provision_grafana.bash' },
  { :name => :suricata,:ip => '192.168.33.113',:cpus => 1, :mem => 512,:provision => 'provision_suricata.bash'},
  ]

$update_script = <<SCRIPT
date > /etc/vagrant_provisioned_at
SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    boxes.each do |opts|
        config.vm.define opts[:name] do |config|
            config.vm.box       = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
            config.vm.synced_folder ".", "/vagrant", disabled:true
            config.vm.network  "private_network", ip: opts[:ip]
            config.vm.network  "forwarded_port", guest: opts[:forward], host: opts[:forward] if opts[:forward]
            config.vm.hostname = "%s.vagrant" % opts[:name].to_s
            config.vm.provider "virtualbox" do |vb|
                vb.customize ["modifyvm", :id, "--cpus", opts[:cpus] ] if opts[:cpus]
                vb.customize ["modifyvm", :id, "--memory", opts[:mem] ] if opts[:mem]
            end
            config.vm.provision "shell", inline: $update_script
            config.vm.provision "shell", path: opts[:provision] if opts[:provision]
       end
    end
end

