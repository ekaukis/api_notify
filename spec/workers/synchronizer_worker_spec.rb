require 'spec_helper'

describe ApiNotify::Workers::SynchronizerWorker do

  # let(:application) do
  #   stub_request(:post, "https://mogo-lv.cubesystems.lv/api/v1/dealermodule/applications").
  #     to_return(status: 201, body: '{ "id": "10", "loan.amount": "3000,20", "client_consent_id": "ab1" }')
  #
  #   FactoryGirl.create(:application)
  # end
  #
  # it "pushes job into queue" do
  #   Sidekiq::Testing.fake!
  #   expect{ described_class.perform_in(15.minutes.from_now, application.id) }.to change(described_class.jobs, :size).by(1)
  # end
  #
  # describe "#perform" do
  #   it "changes application status to ADDITIONL_CHECKING" do
  #     application.inner_status = Application::STATUS_STARTED_CLIENT_CHECK
  #     application.save
  #
  #     expect { described_class.new.perform(application.id) }.to change{application.reload.inner_status}.
  #       from(Application::STATUS_STARTED_CLIENT_CHECK).to(Application::STATUS_ADDITIONAL_CHECKING)
  #   end
  # end

end
