module Kotoba::Formatting
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
    if style[:style]
      element = inline_format_italic(element) if style[:style].include?(:italic)
      element = inline_format_bold(element) if style[:style].include?(:bold)
    end
    element = inline_format_color(element, style[:color]) if style[:color]
    inline_format_font(element, style)
  end

  protected

  def inline_format_italic(element)
    "<i>#{element}</i>"
  end

  def inline_format_bold(element)
    "<b>#{element}</b>"
  end

  def inline_format_color(element, color)
    "<color rgb='#{color}'>#{element}</color>"
  end

  def inline_format_font(element, style)
    style_mapping = {
      name: :style,
      size: :size,
      character_spacing: :character_spacing
    }
    string = "<font".tap do |s|
      style_mapping.each do |name, key|
        s << " #{name}='#{style[key]}'" if style[key]
      end
    end
    string << ">#{element}</font>"
  end
end
