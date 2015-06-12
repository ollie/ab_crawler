require 'bundler'
Bundler.require

desc 'Start a console'
task :console do
  require 'pry'
  require_relative 'lib/crawler'
  require_relative 'lib/downloader'

  Pry.start
end

desc 'Create new JSON index file and save it to ' \
     'indexes/index_YYYYMMDDHHMMSS.json'
task :index do
  require_relative 'lib/crawler'

  Crawler.new
end

desc 'Continue working last index or specify one with INDEX=path/to/index.json'
task :continue do
  require_relative 'lib/crawler'

  puts "Continuing #{ index_path }"
  Crawler::DownloadsFinder.new(index_path).find
end

desc 'Downloads missing games from last index ' \
     'or specify one with INDEX=path/to/index.json'
task :download do
  require_relative 'lib/downloader'

  puts "Downloading #{ index_path }"
  Downloader.new(index_path).download
end

desc 'Show missing games, duplicates, etc'
task :stats do
  require_relative 'lib/stats'

  Stats.new(index_path).report
end

# Return path to the latest index, or if INDEX was found in ENV, use that.
# Make sure it exists, too.
#
# @return [String]
def index_path
  @index_path ||= begin
    index_path = ENV['INDEX']
    index_path = Dir['indexes/*.json'].sort.last  if index_path.blank?
    abort 'Need an INDEX=indexes/some_index.json' if index_path.blank?
    abort "#{ index_path } is not a file" unless File.file?(index_path)
    index_path
  end
end
