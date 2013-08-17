class Kotoba::Layout
  class RecurringElement < Styling
    attr_reader :numbering
    attr_accessor :content

    def initialize(*args)
      super(args)
      @numbering = PageNumbering.new
    end

    def content(&block)
      @content = block if block_given?
      @content
    end

    def page_numbering
      yield(@numbering) if block_given?
      @numbering
    end

    class PageNumbering < Hashie::Dash
      property :active, :default => false # true/false
      property :string, :default => "<page>" # page <page> of <total>
      property :align, :default => :center # left, center, right, position
      property :start_count_at, :default => 0

      # Creates a string with the current page number and page count based on
      # the string set by the user.
      #
      # @example
      #     p = PageNumbering.new
      #     p.string = "Page <page> of <total>"
      #     p.format(1, 2) # => "Page 1 of 2"
      #
      # @param page_number [Integer] Page number, used to replace <page>
      # @param page_count [Integer] Total page count, used to
      #  replace <total>
      #
      # @return [String] formatted string with page number and/or count
      #
      def format(page_number, page_count=nil)
        formatted_string = string.dup
        formatted_string.gsub!("<page>", page_number.to_s)
        formatted_string.gsub!("<total>", page_count.to_s) if page_count
        formatted_string
      end
    end
  end
end
