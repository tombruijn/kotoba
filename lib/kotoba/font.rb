module Kotoba
  class Font < Asset
    FONTS_DIR = "fonts"

    attr_reader :name, :types

    def initialize(name, types)
      @name = name
      @types = complete_filenames_for_types(types)
    end

    # Returns the path of the font.
    #
    # @return [String] path of the font.
    #
    def asset_path(filename)
      super(File.join(FONTS_DIR, filename))
    end

    protected

    def complete_filenames_for_types(types)
      types.each do |name, filename|
        types[name] = asset_path(filename)
      end
    end
  end
end
