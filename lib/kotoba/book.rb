module Kotoba
  class Book
    attr_reader :parser, :templates

    def initialize
      @parser = Parser.new
      @templates = @parser.collect
    end
  end
end
