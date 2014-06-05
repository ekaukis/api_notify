shared_examples "an Api Notified includer" do |opts={}|

  let(:klass) { described_class }
  let(:subject) { klass.new }

  it { expect(subject).to have_many(:api_notify_logs) }
  it { expect(subject).to have_many(:api_notify_tasks) }

  describe "ClassMethods" do
    it "defines .notify_attributes" do
      expect(subject.notify_attributes.class).to eq(Array)
    end

    it "defines .identificators" do
      expect(subject.identificators.class).to eq(Hash)
    end

    it "defines .endpoints" do
      expect(subject.endpoints.class).to eq(Hash)
    end
  end

  describe ".method_missing" do

    context "when before_create triggered" do
      it "receivs post_gather_changes" do
        expect(subject).to receive(:post_gather_changes)
        subject.save!
      end
    end

    context "when before_update triggered" do
      it "receivs post_gather_changes" do
        expect(subject).to receive(:post_gather_changes)
        subject.save!
      end
    end

    context "when before_destroy triggered", pending: "You cannot call create unless the parent is saved" do
      it "receivs delete_gather_changes" do
        expect(subject).to receive(:delete_gather_changes)
        subject.destroy
      end
    end

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
