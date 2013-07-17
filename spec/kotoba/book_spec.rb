require "spec_helper"

describe Kotoba::Book do
  describe "#new" do
    subject { Kotoba::Book.new }

    its(:parser) { should be_instance_of Kotoba::Parser }

    it "should load the templates" do
      subject.templates.should be_a(Array)
      subject.templates.should include(be_instance_of(Kotoba::Template))
    end
  end
end
