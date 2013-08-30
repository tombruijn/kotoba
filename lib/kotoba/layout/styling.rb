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
        hash[:font] = font if using_prawn_font?
        hash[:size] = size
        hash[:color] = color
        hash[:align] = align
        hash[:direction] = direction
        hash[:character_spacing] = character_spacing
        hash[:leading] = line_height
        hash[:style] = style unless style.empty?
        hash[:indent_paragraphs] = indent
        hash[:prefix] = prefix unless prefix.empty?
      end
    end

    protected

    def default
      Kotoba.config.layout_for_page(page_range).default
    end

    def using_prawn_font?
      Prawn::Font::AFM::BUILT_INS.include?(font)
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
      @color = "000000"
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
