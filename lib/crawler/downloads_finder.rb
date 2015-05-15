class Crawler
  # Find download links for all games.
  class DownloadsFinder
    # Selector for download page.
    GET_IT_SELECTOR  = 'a[href^="/en/downloadgame"]'

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

    # Visit each game's page and try to find a download page URL.
    def find
      DurationEstimate.each(pending_games) do |game, e|
        print "\r#{ DurationEstimate::TerminalFormatter.format(e) }"
        find_download_link(game.last)
        Helpers.save_data_as_json(index_path, data)
        Helpers.wait
      end

      puts
    end

    private

    # Visit the game's page and look up the download page URL.
    #
    # @param game [Hash]
    def find_download_link(game)
      page = agent.get(game.fetch('url'))
      a    = page.search(GET_IT_SELECTOR).first

      if a
        href                 = a.attribute('href').value.strip
        game['download_url'] = URI.join(WEBSITE_URL, href).to_s
        game['downloadable'] = true
      else
        game['downloadable'] = false
      end
    end

    # Select all games that do not have a +downloadable+ flag.
    #
    # @return [Hash]
    def pending_games
      {}.tap do |all_games|
        data.each do |_, category|
          pending_games = category.fetch('games').select do |_, game|
            game['downloadable'].nil?
          end
          all_games.merge!(pending_games)
        end
      end
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
end
