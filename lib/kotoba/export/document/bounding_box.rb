class Kotoba::Export::Document
  # Creates a bounding box at a given top position.
  # It places it at the given top coordinate and left coordinate depending on
  # the page number (even/odd) and layout.
  # A block must be given to be executed inside the bounding box.
  #
  # @param options [Hash] options hash. Expected keys:
  #                                           :top (proc that returns number)
  #                                           :width (number)
  #                                           :height (number)
  # @yield block that should be called inside the bounding box
  #
  def bounding_box_for(element)
    canvas do
      options = bounding_box_options_for(element)

      x_coordinate = left_position(element.at[1])
      y_coordinate = if element.type == :header
        header_top_position(element.at[0])
      else
        footer_top_position(element.at[0])
      end

      bounding_box([x_coordinate, y_coordinate], options) do
        yield
      end
    end
  end

  def bounding_box_options_for(element)
    element_layout = layout
    height = if element.type == :header
      element_layout.margin.top
    else
      element_layout.margin.bottom
    end
    { :width => element_layout.content_width, :height => height }
  end
end
