shared_examples "an Api Notified includer" do |opts={}|

  let(:klass) { described_class }
  let(:subject) { klass.new }

  it { expect(subject).to have_one(:api_notify_log) }
  it { expect(subject).to have_many(:api_notify_tasks) }

  describe "ClassMethods" do
    it "defines .notify_attributes" do
      expect(subject.notify_attributes.class).to eq(Array)
    end

    it "defines .identificators" do
      expect(subject.identificators.class).to eq(Hash)
    end
  end

  describe ".method_missing" do
    context "when after_create triggered" do
      it "receivs post_via_api" do
        expect(subject).to receive(:post_via_api)
        subject.save!
      end
    end

    context "when after_update triggered" do
      it "receivs post_via_api" do
        expect(subject).to receive(:post_via_api)
        subject.save!
      end
    end

    context "when after_destroy triggered" do
      it "receivs delete_via_api" do
        expect(subject).to receive(:delete_via_api)
        subject.destroy
      end
    end

  end


end
