require_relative 'helpers'
require_relative 'crawler/games_finder'
require_relative 'crawler/downloads_finder'

# Find all categories and game pages, then look up their download pages.
class Crawler
  # URL to the games website.
  WEBSITE_URL = 'http://www.abandonia.com/'

  # Find all categories and game pages, then look up their download pages.
  def initialize
    GamesFinder.new(index_path).find
    DownloadsFinder.new(index_path).find
  end

  private

  # Path to the JSON index.
  #
  # @return [String, Pathname]
  def index_path
    @index_path ||= "indexes/index_#{ now }.json"
  end

  # Time now.
  #
  # @return [String]
  def now
    @now ||= Time.now.strftime('%Y%m%d%H%M%S')
  end
end
