require './lib/ab_crawler'
require './lib/ab_downloader'
require 'fileutils'

RED = "\e[0;31m"
GREEN = "\e[0;32m"
RESET = "\e[0m"

desc 'Download games index.'
task :index do
  c = AbCrawler.new
  c.dryrun = false
  c.uri = 'http://www.abandonia.com/'
  c.open_log
  c.crawl
  c.close_log
end

desc 'Download games, for example rake download INDEX=20110807120722.'
task :download do
  d = AbDownloader.new
  d.dryrun = false
  d.uri = 'http://www.abandonia.com/'
  d.index = "index_#{ ENV['INDEX'] }.json"
  d.open_log
  d.download
  d.close_log
end

desc 'Find duplicates and remove them, use DRYRUN=0 to really delete.'
task :duplicates do
  all_game_paths = []

  latest_index_file = Dir['indexes/*.json'].sort.last
  categories = JSON.parse File.open( latest_index_file, 'r' ).read
  categories.each do |category_name, category_options|
    category_path = File.join( 'games', category_name )
    category_options['games'].each do |game_name, game_options|
      output_file_name = AbDownloader.saveable_file_name game_name
      output_file_path = File.join category_path, output_file_name
      all_game_paths << output_file_path
    end
  end

  stats = {}
  files = Dir['games/**/*.zip']
  files.each do |file|
    game = File.basename file
    stats[game] ||= []
    stats[game] << file
  end

  # stats will now be array!
  stats = stats.sort { |a, b| b[1].size <=> a[1].size }
  duplicates = stats.find_all { |stat| stat[1].size > 1 }

  unless duplicates.empty?
    longest_name = duplicates.max_by { |stat| stat[0].length }[0].length

    duplicates.each do |stat|
      line = "#{ stat[0].ljust longest_name } #{ stat[1].size }"
      puts line
      puts '-' * line.length
      stat[1].each do |game_path|
        if all_game_paths.include? game_path
          puts "#{ GREEN }#{ game_path }#{ RESET }"
        else
          puts "#{ RED }#{ game_path }#{ RESET }"
          if ENV['DRYRUN'] == '0'
            FileUtils.rm game_path, :verbose => true
          else
            FileUtils::DryRun.rm game_path, :verbose => true
          end
        end
      end
      puts
    end
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