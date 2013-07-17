module Kotoba
  class Book
    attr_reader :parser, :templates

    def initialize
      @parser = Parser.new
      @templates = []
      load
    end

    def load
      return @templates unless @templates.empty?
      @templates = parser.collect
    end
  end
end
