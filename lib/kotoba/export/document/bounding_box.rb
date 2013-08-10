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
  def bounding_box_on(options={})
    canvas do
      bounding_box([left_position, options[:top].call], options) do
        yield
      end
    end
  end
end
