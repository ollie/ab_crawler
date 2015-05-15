require_relative 'helpers'

# Download missing games.
class Downloader
  # Regex to find a download link in a script tag.
  DOWNLOAD_URL_REGEX = %r{
    window\.open\("(?<url>http://files\.abandonia\.com/download\.php[^"]+)"
  }x

  # Path to the JSON index.
  #
  # @return [String, Pathname]
  attr_accessor :index_path

  # Setup.
  #
  # @param index_path [String, Pathname] Path to the JSON index.
  def initialize(index_path)
    self.index_path = index_path
  end

  # Download missing games.
  def download
    detect_interruption

    catch :interrupted do
      DurationEstimate.each(downloadable_games) do |game, e|
        throw :interrupted if interrupted?
        print "#{ DurationEstimate::TerminalFormatter.format(e) }, "
        download_game(game)
        Helpers.wait
      end
    end
  end

  private

  # Visit the download page, find the real download link and do the download.
  #
  # @param game [Hash]
  def download_game(game)
    page         = agent.get(game.fetch(:page_url))
    download_url = find_download_url(page)

    unless download_url
      puts "Cannot download #{ game.fetch(:name) }"
      return
    end

    Helpers.wait
    throw :interrupted if interrupted?
    print "#{ download_url } -> #{ game.fetch(:file_path) }"

    File.open(game.fetch(:file_path), 'wb') do |file|
      file << agent.get(download_url).body
    end

    puts
  end

  # Select all games that are not +downloadable+.
  #
  # @return [Array<Hash>]
  def downloadable_games
    [].tap do |all_games|
      data.each do |category_name, category|
        games = category.fetch('games').select do |_, game|
          game['downloadable']
        end

        category_path = category_path_for(category_name)

        games.each do |game_name, hash|
          game_path = category_path.join(Helpers.sanitize_file_name(game_name))
          next if game_path.exist? && !game_path.size.zero?

          all_games << {
            name:      game_name,
            file_path: game_path,
            page_url:  hash['download_url']
          }
        end
      end
    end
  end

  # Find a download link.
  #
  # @param page [Mechanize::Page]
  #
  # @return [String, nil]
  def find_download_url(page)
    matches = page.body.match(DOWNLOAD_URL_REGEX)
    return unless matches || matches[:url].blank?
    matches[:url].gsub('&amp;', '&')
  end

  # Compose a path name for given category and make sure it exists.
  #
  # @param category_name [String] Name of the category.
  #
  # @return [Pathname]
  def category_path_for(category_name)
    Helpers::GAMES_DIR.join(category_name).tap do |path|
      FileUtils.mkdir_p(path) unless path.directory?
    end
  end

  # When CTRL+C is hit, do not raise an error but let it finish the current
  # file.
  def detect_interruption
    trap('INT') do
      interrupted!
      puts
      puts 'Hold on, let me finish this file...'
    end
  end

  # Was CTRL+C hit?
  #
  # @return [Bool]
  def interrupted?
    @interrupted ||= false
  end

  def interrupted!
    @interrupted = true
  end

  # Load up categories and games index.
  #
  # @return [Hash]
  def data
    @data ||= MultiJson.load(File.read(index_path))
  end

  # Create a new Mechanize agent.
  #
  # @return [Mechanize]
  def agent
    @agent ||= Helpers.agent
  end
end
