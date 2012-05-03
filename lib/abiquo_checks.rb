module AbiquoChecks
	def check_installed_components
		comps = []
		#Check KVM
		%x(rpm -qa|grep kvm)
		if $?.exitstatus == 0
			aim_ver = %x(rpm -qa|grep aim).split('-')[2]
			comps.push ['abiquo-kvm', aim_ver] if aim_ver
		end

		#Check Abiquo Server
		%x(rpm -qa|grep abiquo-server)
		if $?.exitstatus == 0
			comps.push ['abiquo-server', %x(rpm -qa|grep abiquo-server).split('-')[2]]
		end

		#Check Abiquo Remote Services
		%x(rpm -qa|grep abiquo-remote-services)
		if $?.exitstatus == 0
			comps.push ['abiquo-rs', %x(rpm -qa|grep abiquo-remote-services).split('-')[3]]
		end

		#Check Abiquo V2V
		%x(rpm -qa|grep abiquo-v2v)
		if $?.exitstatus == 0
			comps.push ['abiquo-v2v', %x(rpm -qa|grep abiquo-v2v).split('-')[2]]
		end

		#Check NFS Repo
		%x(grep "/opt/vm_repository" /etc/exports)
		if $?.exitstatus == 0
			comps.push ['nfs-repo', %x(rpm -qa|grep nfs-utils|grep -v lib).split('-')[2]]
		end

		return comps
	end
end