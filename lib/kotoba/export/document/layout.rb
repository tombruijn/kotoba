class Kotoba::Export::Document
  # Returns header y coordinate.
  # Should be called from within a Prawn canvas block so it will return the
  # absolute top of the page rather than the top of its parent bounding_box.
  #
  # @return [Integer] y coordinate for the header
  #
  def header_top_position
    bounds.top
  end

  # Returns the footer y coordinate.
  # Should be called from within a Prawn canvas block so it will return the
  # correct position rather than one based on its parent bounding_box.
  #
  # It takes the absolute bottom of the page and adds the bottom margin to
  # position the footer correctly.
  #
  # @return [Integer] y coordinate for the footer
  #
  def footer_top_position
    bounds.bottom + layout.margin.bottom
  end

  # Returns the x position for a content box.
  # Should be called from within a Prawn canvas block so it will return the
  # correct position based on the absolute left rather than the left of its
  # parent bounding_box.
  #
  # @return [Integer] x coordinate for the content box
  #
  def left_position
    if page_number.even?
      bounds.left + layout.margin.outer
    else
      bounds.left + layout.margin.inner
    end
  end
end
