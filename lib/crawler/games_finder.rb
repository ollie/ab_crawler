class Crawler
  # Find links to all games.
  class GamesFinder
    # Selector for Game's submenu items except for the "All" one.
    CATEGORIES_SELECTOR = '#menu--302 ul li:not(.menu-path-game-all) a'

    # Selector for game links on current page.
    GAMES_SELECTOR = '.gamelist .title_beige a'

    # Selector for the next page link.
    PAGER_NEXT_SELECTOR = '#pager .pager-list .pager-current + a'

    # Path to the JSON index.
    #
    # @return [String, Pathname]
    attr_accessor :index_path

    # Contains categories and games links.
    #
    # @return [Hash]
    attr_accessor :data

    # Setup.
    #
    # @param index_path [String, Pathname] Path to the JSON index.
    def initialize(index_path)
      self.index_path = index_path
      self.data       = {}
    end

    # Look up the categories and find all games on those pages.
    def find
      puts 'Finding all categories and games, this may take a minute or two.'
      find_categories
      Helpers.save_data_as_json(index_path, data)
      find_games
      Helpers.save_data_as_json(index_path, data)
    end

    private

    # Visit the website page and store links to the categories.
    def find_categories
      page = agent.get(WEBSITE_URL)

      page.search(CATEGORIES_SELECTOR).each do |a|
        category_name = a.text.strip
        path          = a.attribute('href').value.strip

        next if category_name.blank? || path.blank?

        data[category_name] = {
          'url' => URI.join(WEBSITE_URL, path).to_s
        }
      end

      Helpers.wait
    end

    # Visit each category and click all the pagination links to find links
    # to all games.
    def find_games
      data.each do |_, category|
        category['games'] = find_games_on_this_page(category.fetch('url'))
      end
    end

    # Load a page with this url, find all games there, then continue
    # searching on the next page until there are no pages left.
    #
    # @param url   [String] Page URL to load.
    # @param games [Hash]   Store all game links here.
    #
    # @return [Hash] Stored game links.
    def find_games_on_this_page(url, games = {})
      page = agent.get(url)
      puts url

      page.search(GAMES_SELECTOR).each do |a|
        game_name = a.text.strip
        path      = a.attribute('href').value.strip

        next if game_name.blank? || path.blank?

        games[game_name] = {
          'url' => URI.join(WEBSITE_URL, path).to_s
        }
      end

      url = link_to_next_page(page)
      Helpers.wait
      return games if url.blank?

      find_games_on_this_page(url, games)
    end

    # Find a link to the next page or nil if not found.
    #
    # @param page [Mechanize::Page]
    #
    # @return [String, nil]
    def link_to_next_page(page)
      a = page.search(PAGER_NEXT_SELECTOR).first
      return unless a
      path = a.attribute('href').value.strip
      URI.join(WEBSITE_URL, path).to_s
    end

    # Create a new Mechanize agent.
    #
    # @return [Mechanize]
    def agent
      @agent ||= Helpers.agent
    end
  end
end
