require 'spec_helper'

describe ApiNotify::Log do
  describe "ActiveRecord associations" do
    it { expect(subject).to belong_to(:api_notify_logable) }
  end

  #Need to check if there is only one record for one instance, by endpoint
end
