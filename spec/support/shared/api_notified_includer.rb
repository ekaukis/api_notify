shared_examples "an Api Notified includer" do |opts={}|

  let(:klass) { described_class }
  let(:instance) { klass.new }

  describe "ClassMethods" do
    it "defines .notify_attributes" do
      expect(instance.notify_attributes.class).to eq(Array)
    end

    it "defines .identificators" do
      expect(instance.identificators.class).to eq(Hash)
    end
  end

end
