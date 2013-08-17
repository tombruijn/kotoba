class Kotoba::Layout
  class Margin < Hashie::Dash
    property :top, :default => 2.cm
    property :bottom, :default => 2.cm
    property :inner, :default => 2.cm
    property :outer, :default => 2.cm
  end
end
