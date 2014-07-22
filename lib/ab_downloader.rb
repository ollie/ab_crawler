require './lib/object'
require './lib/extension'
require 'json'
require 'fileutils'
require 'pp'

class AbDownloader
  include Extension
  attr_accessor :index, :dryrun

  def initialize
    @dryrun           = true
    @interrupted      = false
    @now              = Time.now.strftime('%Y%m%d%H%M%S')
    @log_path         = File.join('.', 'games', "#{ @now }.log")
    @waiting_interval = 3..10
    detect_interruption

    @skipped_games      = {}
    @agent              = Mechanize.new
    @agent.open_timeout = 600
    @agent.read_timeout = 600
  end

  def uri
    @uri.to_s
  end

  def uri=(value)
    @uri = URI.parse(value)
  end

  def index=(value)
    @index = File.join('.', 'indexes', value)
  end

  def download
    return if @index.blank? || !File.exist?(@index)
    parse_index_file
    return if @categories.empty?
    download_games
  end

  private

  def detect_interruption
    trap('INT') do
      @interrupted = true
      log 'Interruption registered!'
    end
  end

  def parse_index_file
    @categories = JSON.parse(File.open(@index, 'r').read)
  end

  def self.saveable_file_name(game_name)
    "#{ game_name.gsub(/[^a-z0-9]+/i, '-') }.zip"
  end

  def parse_download_href
    matches = @page.body.match(%r{window\.open\("(http://files\.abandonia\.com/download\.php[^"]+)"})
    matches[1].gsub('&amp;', '&') if matches[1].present?
  end

  def download_games
    @categories.each do |category_name, category_options|
      category_path = File.join('.', 'games', category_name)
      FileUtils.mkdir(category_path, verbose: true) unless File.directory? category_path
      category_options['games'].each do |game_name, game_options|
        if @interrupted
          log 'Interrupting...'
          return
        end

        if game_options['download_href'].blank?
          @skipped_games[category_name] ||= {}
          @skipped_games[category_name][game_name] = game_options
          next
        end

        output_file_name = AbDownloader.saveable_file_name(game_name)
        output_file_path = File.join(category_path, output_file_name)

        if File.exist?(output_file_path) && File.size(output_file_path) != 0
          log "Skipping #{ category_name }/#{ game_name } already exists #{ output_file_path }"
          next
        end

        log "Downloading #{ category_name }/#{ game_name } to #{ output_file_path }"

        if !@dryrun
          @page = @agent.get(URI.parse game_options['download_href'])
          download_href = parse_download_href

          unless download_href
            log "Cannot download #{ game_name }"
            next
          end

          File.open(output_file_path, 'wb') do |file|
            file.write @agent.get(download_href).body
          end
        else
          FileUtils.touch(output_file_path)
        end

        wait
      end
    end
  end
end
