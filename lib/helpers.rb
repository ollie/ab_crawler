require 'fileutils'

require_relative 'object'

# Some common methods.
module Helpers
  module_function

  # Directory containing games.
  GAMES_DIR = Pathname.new('games')

  # Waiting range in seconds.
  WAIT_INTERVAL = (1..5).to_a

  # Sleep a while.
  def wait
    sleep WAIT_INTERVAL.sample
  end

  # Serialize data hash to a JSON file.
  #
  # @param file_path [String] Where to save the data.
  # @param data      [Hash]   Data to save.
  def save_data_as_json(file_path, data)
    directory = File.dirname(file_path)
    FileUtils.mkdir(directory) unless File.directory?(directory)

    File.open(file_path, 'w') do |f|
      f << MultiJson.dump(data, pretty: true)
    end
  end

  # Create a new Mechanize agent.
  #
  # @return [Mechanize]
  def agent
    Mechanize.new.tap do |agent|
      agent.open_timeout = 600
      agent.read_timeout = 600
    end
  end

  # Convert game name into a file name.
  #
  # @param game_name [String] Dangerous name.
  #
  # @return [String] Dasherized, lowercase file name.
  def sanitize_file_name(game_name)
    file_name = game_name.gsub(/[^a-z0-9]+/i, '-')
    "#{ file_name }.zip"
  end
end
