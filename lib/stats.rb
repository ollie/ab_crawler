require_relative 'helpers'

# Show missing games, duplicates, etc.
class Stats
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

  # Show missing games, duplicates, etc.
  def report
    puts 'Games not yet downloaded'
    puts '------------------------'
    puts games_not_downloaded.join("\n")
    puts
    puts 'Unknown games, maybe garbage'
    puts '----------------------------'
    puts games_not_in_index.join("\n")
    puts
    puts 'Duplicates'
    puts '----------'

    duplicates.each do |_, files|
      files.each do |file|
        color = file.fetch(:known) ? :green : :red
        puts Rainbow(file.fetch(:message)).color(color)
      end
    end
  end

  private

  # Find downloadable games that have not been downloaded yet.
  #
  # @return [Array<String>]
  def games_not_downloaded
    downloadable_games_in_index - games_on_system
  end

  # Find unknown games.
  #
  # @return [Array<String>]
  def games_not_in_index
    games_on_system - games_in_index
  end

  # Find games with same name.
  #
  # @return [Array<String>]
  def duplicates
    @duplicates ||= begin
      hash = {}

      games_on_system.each do |file_path|
        file_name = File.basename(file_path)
        file_size = File.size(file_path)
        files     = hash[file_name] ||= []

        files << {
          message: "#{ file_path } (#{ file_size } B)",
          known:   downloadable_games_in_index.include?(file_path)
        }
      end

      hash.select { |_, file_paths| file_paths.size > 1 }
    end
  end

  # Map all games in index as a flat array of file paths.
  #
  # @return [Array<String>]
  def games_in_index
    games.map { |game| game.fetch('file_path') }.sort
  end

  # Map all downloadable games in index as a flat array of file paths.
  #
  # @return [Array<String>]
  def downloadable_games_in_index
    @downloadable_games_in_index ||= begin
      games
        .select { |game| game.fetch('downloadable') }
        .map { |game| game.fetch('file_path') }.sort
    end
  end

  # Find all games on disc as a flat array of file paths.
  #
  # @return [Array<String>]
  def games_on_system
    @games_on_system ||= Dir[Helpers::GAMES_DIR.join('**/*.zip')].sort
  end

  # Map all games as a simple array, also add file paths.
  #
  # @return [Array<Hash>]
  def games
    @games_list ||= begin
      [].tap do |list|
        data.each do |category_name, category_options|
          category_path = Helpers::GAMES_DIR.join(category_name)

          category_options['games'].map do |game_name, game|
            file_name = Helpers.sanitize_file_name(game_name)
            file_path = category_path.join(file_name)

            game['file_path'] = file_path.to_s

            list << game
          end
        end
      end
    end
  end

  # Load up categories and games index.
  #
  # @return [Hash]
  def data
    @data ||= MultiJson.load(File.read(index_path))
  end
end
