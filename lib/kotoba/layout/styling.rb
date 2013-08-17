class Kotoba::Layout
  class Styling
    attr_reader :page_range

    OPTIONS = %w(font size color align direction character_spacing line_height
      style prefix)

    OPTIONS.each do |option|
      attr_writer option
      define_method option do
        instance_variable_get("@#{option}") || default.send(option)
      end
    end

    def initialize(page_range = :all)
      @page_range = page_range
    end

    def to_hash
      {}.tap do |hash|
        hash[:font] = font if using_prawn_font?
        hash[:size] = size
        hash[:color] = color
        hash[:style] = style unless style.empty?
        hash[:leading] = line_height
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
      @prefix = ""
    end
  end
end
