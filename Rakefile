require './lib/ab_crawler'
require './lib/ab_downloader'
require 'fileutils'

desc 'Download games index.'
task :index do
	c = AbCrawler.new
	c.dryrun = false
	c.uri = 'http://www.abandonia.com/'
	c.open_log
	c.crawl
	c.close_log
end

desc 'Download games.'
task :download do
	d = AbDownloader.new
	d.dryrun = false
	d.uri = 'http://www.abandonia.com/'
	d.index = "index_#{ ENV['index'] }.json"
	d.open_log
	d.download
	d.close_log
end

namespace :clear do
	desc 'Delete indexes.'
	task :indexes do
		FileUtils.rm Dir.glob('./indexes/*'), :verbose => true
	end

	desc 'Delete games.'
	task :games do
		FileUtils.rm_r Dir.glob('./games/*'), :verbose => true
	end

	desc 'Delete indexes and games.'
	task :all do
		FileUtils.rm Dir.glob('./indexes/*'), :verbose => true
		FileUtils.rm_r Dir.glob('./games/*'), :verbose => true
	end
end

namespace :log do
	desc 'Diff two logs. For example rake log:diff TOOL=meld FILE1=./indexes/index_20110228005550.log FILE2=./indexes/index_20110527123321.log.'
	task :diff do
		rm_r './tmp', :verbose => true if File.directory? './tmp'
		mkdir './tmp', :verbose => true unless File.directory? './tmp'
		tool = ENV['TOOL'] || 'diff -u'
		file1 = ENV['FILE1']
		file2 = ENV['FILE2']
		tmp_logs = []

		if file1 and file2
			logs = [ file1, file2 ]
		else
			all_logs = Dir.glob('./indexes/*.log').sort
			logs = [ all_logs.pop, all_logs.pop ].reverse
		end

		logs.each do |filepath|
			tmppath = filepath.gsub 'indexes', 'tmp'
			tmp_logs << tmppath
			File.open( tmppath, 'w' ) do |file|
				puts "Saving diff to #{ tmppath }"
				file << File.read( filepath ).split("\n").map { |line| line unless line.match( /^Waiting.*/ ) }.delete_if { |item| item.nil? }.join("\n")
			end
		end
		sh "#{ tool } #{ tmp_logs.join ' ' }"
	end
end
