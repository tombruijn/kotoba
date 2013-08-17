require "spec_helper"

describe Kotoba::Layout::Margin do
  before :all do
    @margin = Kotoba::Layout::Margin.new
    @margin.top = 1
    @margin.bottom = 2
    @margin.inner = 3
    @margin.outer = 4
  end
  subject { @margin }

  its(:top) { should == 1 }
  its(:bottom) { should == 2 }
  its(:inner) { should == 3 }
  its(:outer) { should == 4 }
end
