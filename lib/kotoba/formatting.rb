module Kotoba::Formatting
  # Remap tag names that are not supported by prawn
  TAG_MAP = { em: :i, italic: :i, strong: :b, bold: :b }

  # Formats a prefix.
  # If a {n} is found it is replaced with the value of the :count key found
  # in the style param.
  #
  # @param prefix [String]
  # @param style [Hash] checks count key.
  # @return [String] formatted prefix.
  #
  def format_prefix(prefix, style)
    count = style[:count]
    (prefix || "").gsub("{n}", count.to_s)
  end

  # Remove html tags from a string.
  # _Not_ the perfect, catch all, method for this, but only meant to remove
  # prawn inline formatting as created by the Prawn converter.
  #
  # @param string [String] string to remove html tags from.
  # @return [String] string with html tags removed.
  #
  def strip_tags(string)
    string.gsub(/<[^>]+>([^<\/]+)<\/[^>]+>/, '\1')
  end

  # Add inline formatting to the given element.
  # The inline formatting is meant to be interpreted by prawn.
  #
  # @param element [String] text to surround with prawn inline formatting.
  # @param style [Hash] hash of style options, see Kotoba::Layout::Styling.to_h.
  # @return [String] text surrounded with prawn inline formatting.
  #
  def inline_format(element, style = {})
    (Array(style[:style]) || []).each do |s|
      element = content_tag(element, tag_name(s))
    end
    # TODO: CYMK support
    element = content_tag(element, :color, rgb: style[:color]) if style[:color]
    inline_format_font(element, style)
  end

  # Wrap the element in a tag.
  #
  # @param element [String] content inside the tag.
  # @param tag [String/Symbol] tag name, @see also `tag_name`.
  # @param attributes [Hash] hash with attribues of tag, @see also
  #   `inline_format_font`.
  #
  # @return [String] string wrapped in a tag.
  #
  def content_tag(element, tag, attributes = {})
    tag = tag_name(tag)
    "<#{tag}#{attributes_html(attributes)}>#{element}</#{tag}>"
  end

  protected

  def tag_name(tag)
    TAG_MAP.key?(tag) ? TAG_MAP[tag] : tag
  end

  def attributes_html(attributes)
    "".tap do |string|
      attributes.each do |key, value|
        string << " #{key}='#{value}'"
      end
    end
  end

  def inline_format_font(element, style)
    font_style = style.dup
    font_attributes = [:name, :size, :character_spacing]
    font_style[:name] = font_style.delete(:font)
    font_style.select! { |key, value| font_attributes.include?(key) }
    content_tag(element, :font, font_style)
  end
end
