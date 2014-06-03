require 'spec_helper'

describe ApiNotifyLog do
  describe "ActiveRecord associations" do
    it { expect(subject).to belong_to(:api_notify_logable) }
  end
end
