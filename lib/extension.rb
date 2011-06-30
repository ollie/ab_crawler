module Extension
	def open_log
		@log_file = File.open @log_path, 'a'
	end

	def close_log
		@log_file.close
	end

	private

		def log( value )
			if @log_path.blank? or @now.blank?
				puts value
				return
			end
			@log_file.puts value
			puts value
		end

		def make_uri( url )
			return URI.join uri, url
		end

		def wait
			if @waiting_interval.nil?
				interval = 1
			else
				interval = @waiting_interval.to_a.sample
			end

			log "Waiting #{ interval } seconds..."
			sleep interval unless @dryrun
		end

		def headline( msg )
			log msg
			msg.size.times { print '=' }
			print "\n"
		end
end