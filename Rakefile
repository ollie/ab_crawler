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

# Return path to the latest index, or if INDEX was found in ENV, use that.
# Make sure it exists, too.
#
# @return [String]
def index_path
  @index_path ||= begin
    index_path = ENV['INDEX']
    index_path = Dir['indexes/*.json'].sort.last if index_path.blank?
    abort 'Need an INDEX=indexes/some_index.json'  if index_path.blank?
    abort "#{ index_path } is not a file" unless File.file?(index_path)
    index_path
  end
end

desc 'Find duplicates and remove them, use DRYRUN=0 to really delete.'
task :duplicates do
  require_relative 'lib/helpers'

  games_in_index = []
  games_found    = []
  data           = JSON.parse(File.open(index_path, 'r').read)

  data.each do |category_name, category_options|
    category_path = Helpers::GAMES_DIR.join(category_name)

    category_options['games'].each do |game_name, game|
      next unless game.fetch('downloadable')

      output_file_name = Helpers.sanitize_file_name(game_name)
      output_file_path = category_path.join(output_file_name)

      games_in_index << output_file_path.to_s
    end
  end

  stats = {}

  Dir['games/**/*.zip'].each do |file_path|
    game_name          = File.basename(file_path)
    stats[game_name] ||= []
    stats[game_name] << file_path
    games_found      << file_path
  end

  # games_missing      = games_in_index - games_found
  # games_not_in_index = games_found - games_in_index
  duplicates         = stats.select { |_, files| files.size > 1 }

  exit if duplicates.empty?

  duplicates.each do |game_name, files|
    line = "#{ game_name } #{ files.size }"
    puts line
    puts '-' * line.length

    files.each do |game_path|
      message = "#{ game_path } (#{ File.size(game_path) } B)"

      if games_in_index.include?(game_path)
        puts Rainbow(message).green
      else
        puts Rainbow(message).red

        if ENV['DRYRUN'] == '0'
          FileUtils.rm(game_path, verbose: true)
        else
          FileUtils::DryRun.rm(game_path, verbose: true)
        end
      end
    end

    puts
  end
end
