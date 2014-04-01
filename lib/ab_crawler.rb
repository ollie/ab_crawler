require './lib/object'
require './lib/extension'
require 'json'
require 'pp'

# Genre      Pages  Games
# -----------------------
# Action      12     222
# Adventure   12     224
# Arcade       9     175
# Board        2      40
# Puzzle       5      89
# Racing       3      53
# RPG          6     111
# Simulation   6     105
# Sports       4      80
# Strategy     9     161
# Unsorted     3      43
# ----------------------
# Total       71    1303
#
# 1 + 71 + 1303 * 3 = 3981 requests
# 3981 * 2 = 7962 s = 2:12:42s

class AbCrawler
  include Extension
  attr_accessor :dryrun

  def initialize
    @dryrun           = true
    @now              = Time.now.strftime '%Y%m%d%H%M%S'
    @log_path         = File.join '.', 'indexes', "index_#{ @now }.log"
    @index_path       = File.join '.', 'indexes', "index_#{ @now }.json"
    @waiting_interval = 3..10

    @categories           = {}
    @categories_selctor   = '#menu--302 ul li:not(.menu-path-game-all) a'
    @games_selector       = '.gamelist .title_beige a'
    @pager_next_selector  = '#pager .pager-list .pager-current + a'
    @game_get_it_selector = 'a[href^="/en/downloadgame"]'
    @agent                = Mechanize.new
    @agent.open_timeout   = 600
    @agent.read_timeout   = 600
  end

  def uri
    @uri.to_s
  end

  def uri=( value )
    @uri = URI.parse value
  end

  def crawl
    return if uri.blank?
    find_categories
    return if @categories.empty?
    find_games
    find_download_links
    save_to_file
  end

  private

    def find_categories
      headline 'Finding categories'
      @page = @agent.get @uri
      @page.search(@categories_selctor).each do |a|
        next if @categories.size == 1 if @dryrun
        key = a.text.strip
        next if key.blank? or a.attribute('href').blank?
        @categories[key] ||= {}
        @categories[key][:href] = make_uri a.attribute('href').value.strip
      end
      log "Found #{ @categories.keys.join ', ' }"
    end

    def find_games
      @categories.each do |category_name, category_options|
        category_options[:games] = find_games_on_this_page category_options[:href]
      end
    end

    def find_games_on_this_page( uri, games = {} )
      @page = @agent.get uri
      log @page.uri.to_s
      @page.search(@games_selector).each do |a|
        key = a.text.strip
        next if key.blank? or a.attribute('href').blank?
        games[key] ||= {}
        games[key][:href] = make_uri a.attribute('href').value.strip
      end
      uri = find_next_page
      wait
      return games if uri.blank? or @dryrun
      find_games_on_this_page uri, games
    end

    def find_next_page
      a = @page.search(@pager_next_selector).first
      return if a.nil?
      make_uri a.attribute('href').value.strip
    end

    def find_download_links
      @categories.each do |category_name, category_options|
        category_options[:games].each do |game_name, game_options|
          @page = @agent.get game_options[:href]
          log @page.uri.to_s
          a = @page.search(@game_get_it_selector).first
          wait
          if a.nil?
            log "Cannot download #{ game_name }"
            wait
            next
          end
          game_options[:download_href] = make_uri a.attribute('href').value.strip
        end
      end
    end

    def save_to_file
      File.open( @index_path, 'w' ) do |file|
        file << @categories.to_json
        log "Saved to #{ @index_path }"
      end
    end
end
