server_count = 1 # 1, 3, or 5
client_count = 1

server_ips = (1..server_count).map {|n| "10.199.0.%d" % [10*n]}
client_ips = (1..client_count).map {|n| "10.199.1.%d" % [10*n]}

Vagrant.configure("2") do |config|
  server_ips.each_with_index do |ip, n|
    id = "server-%02d" % n
    name = "nomad-%s" % id

    config.vm.define name, autostart: true do |server|
      server.vm.box = "krishicks/nomad"
      server.vm.network :private_network, ip: ip

      maybe_replace_nomad(server)

      server.vm.provision "shell",
        name: "consul",
        path: "scripts/consul.sh",
        env: {
          SERVER: true,
          BOOTSTRAP_EXPECT: server_count,
          BIND_ADDR: ip,
          NODE_NAME: id,
          RETRY_JOIN: server_ips.reject { |other| other == ip }.to_s,
        }

      server.vm.provision "shell",
        name: "nomad",
        path: "scripts/nomad.sh",
        env: {
          SERVER: true,
          BOOTSTRAP_EXPECT: server_count,
          ADVERTISE_ADDR: ip,
          NAME: id,
          RETRY_JOIN: server_ips.reject { |other| other == ip }.to_s,
        }
    end
  end

  client_ips.each_with_index do |ip, n|
    id = "client-%02d" % n
    name = "nomad-%s" % id

    config.vm.define name, autostart: true do |client|
      client.vm.box = "krishicks/nomad"
      client.vm.network :private_network, ip: ip

      maybe_replace_nomad(client)

      client.vm.provision "shell",
        name: "consul",
        path: "scripts/consul.sh",
        env: {
          RETRY_JOIN: server_ips.to_s,
          BIND_ADDR: ip,
          NODE_NAME: id,
        }

      client.vm.provision "shell",
        name: "nomad",
        path: "scripts/nomad.sh",
        env: {
          ADVERTISE_ADDR: ip,
          NAME: id,
          RETRY_JOIN: server_ips.map { |ip| ip + ":4647" }.to_s,
        }
    end
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true
end

def maybe_replace_nomad(config)
  # For uploading a custom Nomad binary
  if File.file?("#{Dir.pwd}/nomad")
    config.vm.provision "file",
      source: "nomad",
      destination: "/tmp/nomad"
  end
end