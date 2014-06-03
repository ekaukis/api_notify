require 'spec_helper'

describe Dealer do
  it_behaves_like "an Api Notified includer"

  describe "ActiveRecord associations" do
    it { expect(subject).to have_many(:vehicles) }

    it { expect(subject).to have_one(:api_notify_log) }
    it { expect(subject).to have_many(:api_notify_tasks) }
  end
end
