class Kotoba::Layout
  class Styling
    # page_range is used to call the default style fallback defined for that
    # page range.
    attr_reader :page_range

    OPTIONS = %w(font size color align direction character_spacing line_height
      style indent prefix)

    OPTIONS.each do |option|
      attr_writer option
      define_method option do
        instance_variable_get("@#{option}") || default.send(option)
      end
    end

    def initialize(page_range = :all, options = {})
      @page_range = page_range
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # @return [Hash] Hash containing prawn compatible keys and values for style
    #   objects.
    #
    def to_h
      {}.tap do |hash|
        # OPTIONS.each do |option|
        #   value = send(option)
        #   puts value.inspect
        #   hash[option.to_sym] = value if (value.respond_to?(:empty?) && !value.empty?) || value > 0
        # end
        hash[:font] = font if font_available?
        hash[:size] = size
        hash[:color] = color unless color.empty?
        hash[:align] = align
        hash[:direction] = direction
        hash[:character_spacing] = character_spacing if character_spacing > 0
        hash[:leading] = line_height
        # hash[:style] = style unless style.empty?
        hash[:indent_paragraphs] = indent
        hash[:prefix] = prefix unless prefix.empty?
      end
    end

    protected

    def default
      Kotoba.config.layout_for(page_range).default
    end

    def font_available?
      using_prawn_font? || font_registered?
    end

    def using_prawn_font?
      Prawn::Font::AFM::BUILT_INS.include?(font)
    end

    def font_registered?
      Kotoba.config.fonts.key?(font)
    end
  end

  # Default styling class that is called when a style is undefined.
  # Define the default styling through the layout object like any other styling
  # using `Kotoba.config.layout.default { |d| ... }`
  #
  class DefaultStyling < Styling
    def initialize(*args)
      super(args)
      @font = "Times-Roman"
      @size = 12.pt
      @color = ""
      @align = :left # left/right/center/justify
      @direction = :ltr # ltr/rtl
      @character_spacing = 0
      @line_height = 12.pt
      @style = []
      @indent = 0.0
      @prefix = ""
    end
  end
end
