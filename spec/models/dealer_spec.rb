require 'spec_helper'

describe Dealer do
  it_behaves_like "an Api Notified includer"

  describe "ActiveRecord associations" do
    it { expect(subject).to have_many(:vehicles) }
  end
end
