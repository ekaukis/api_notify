require "spec_helper"

describe ApiNotify::ActiveRecord::Main do

  describe "Allowed methods" do
    it "returns post, delete, get and put" do
      expect(subject::METHODS).to eq(%w[post get delete put])
    end
  end

end
