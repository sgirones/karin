module AbiquoUpdater
	def extract_from_localfile filename
		raise Exception.new "File not found" unless File.exists? "/opt/abiquo/updates/#{filename}"		
		puts "Extract packages..."
		result = %x(tar xvf /opt/abiquo/updates/#{filename} -C /tmp/)
		puts result
		raise Exception.new result unless $?.exitstatus == 0
		puts "Done"
	end

	def extract_from_url url
		require 'net/http'
		uri = URI.parse(url)
		filename = uri.path.split('/')[-1]
		puts "Downloading #{url}"
		Net::HTTP.start(uri.host, uri.port) do |http|
    		resp = http.get(uri.path)
    		open("/tmp/#{filename}", "wb") do |file|
        		file.write(resp.body)
    		end
		end
		puts "Done."

		puts "Extract packages..."
		result = %x(tar xvf /tmp/#{filename} -C /tmp/)
		puts result
		raise Exception.new result unless $?.exitstatus == 0
		puts "Done"
	end

	def do_upgrade
		puts "Stopping tomcat..."
		result = %x(service abiquo-tomcat stop)
		puts result
		puts "Done"

		puts "Prepare environment..."
		result = %x(cp /tmp/abiquo_upgrade_repo/abiquo_local_upgrade.repo /etc/yum.repos.d/)
		puts result
		raise Exception.new result unless $?.exitstatus == 0
		result = %x(sed -i "s,REPOURL,tmp/abiquo_upgrade_repo/," /etc/yum.repos.d/abiquo_local_upgrade.repo)
		puts result
		raise Exception.new result unless $?.exitstatus == 0
		puts "Done"

		puts "Start packages upgrade..."
		result = %x(yum upgrade -y --disablerepo='*' --enablerepo='abiquo-local-upgrade')
		puts result
		raise Exception.new result unless $?.exitstatus == 0
		puts "Done"

		result = %x(ls /tmp/abiquo_upgrade_database/kinton*delta*)
		puts "Applying delta..."
		if result.split.count == 0
			puts "No delta to apply"
		else
			result.split.each do |delta|
				result_delta = %x(mysql kinton < #{delta})
				raise Exception.new result unless $?.exitstatus == 0
				puts "Applied delta: #{delta}"
			end
		end
		puts "Done"
	end

	def clean_upgrade_data
		%x(rm -rf /tmp/abiquo*)
	end


end