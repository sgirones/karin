class AbiquoInstaller
  PACKAGES = {'abiquo-kvm' => [
		        'kvm',
		        'abiquo-cloud-node',
		        'abiquo-release-ee',
		        'redhat-logos-4.9.99-12.el5.abiquo',
		        'abiquo-sosreport-plugins',
		        'abiquo-release-notes-ee'
		        ],
        'abiquo-server' => [],
        'abiquo-remoteservices' => [],
        'abiquo-v2v' => []
      }

    def install_component comp, req_params
    	return unless PACKAGES.keys.include? comp['id']
		puts "Installing packages for #{comp['id']}..."
		install_packages PACKAGES[comp['id']]
		puts "Done"
		puts "Doing post-install steps..."
		params_to_config = {}
		for param in comp['params']
			puts req_params[param]
			params_to_config[param] = req_params[param] if req_params[param]
		end
		do_post_install comp['id'], params_to_config
		puts "Done"
    end

    def install_packages packages
    	%x(yum install -y --nogpgcheck #{packages.join(" ")})
    	return $?.exitstatus
    end

    def do_post_install comp_id, params
    	case comp_id
	   		when "abiquo-kvm" then
	   			params.each do |key, value|
	   				case key
		   				when "abiquo-kvm-nfs-path" then
		   					File.open("/etc/fstab", "a") do |fstab|
			   					fstab.puts "#{value}	/opt/vm_repository nfs    defaults        0 0"
			   				end
		   				when "abiquo-kvm-rs-ip" then
		   					File.open("/etc/abiquo-aim.ini", "w") do |config|
		   						config.puts "[server]
port = 8889

[monitor]
uri = \"qemu+unix:///system\"
redisHost = #{value}
redisPort = 6379

[rimp]
repository = /opt/vm_repository
datastore = /var/lib/virt

[vlan]
ifconfigCmd = /sbin/ifconfig
vconfigCmd = /sbin/vconfig
brctlCmd = /usr/sbin/brctl"
		   					end
	   				end
	   			end
	   		else
	   			puts "no post-install"
	   	end
    end
end