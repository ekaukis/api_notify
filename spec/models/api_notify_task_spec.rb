require 'spec_helper'

describe ApiNotifyTask do
  describe "ActiveRecord associations" do
    it { expect(subject).to belong_to(:api_notifiable) }
  end
end
