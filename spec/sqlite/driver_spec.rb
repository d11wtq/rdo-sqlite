require "spec_helper"
require "uri"

describe RDO::SQLite::Driver do
  let(:options)    { connection_uri }
  let(:connection) { RDO.connect(options) }

  after(:each) { connection.close rescue nil }

  describe "#initialize" do
    context "with valid settings" do
      it "opens a database file" do
        connection.should be_open
      end
    end

    context "with invalid settings" do
      let(:options) { "sqlite:/some/bad/path/to/a.db" }

      it "raises an RDO::Exception" do
        expect { connection }.to raise_error(RDO::Exception)
      end

      it "provides a meaninful error message" do
        begin
          connection && fail("RDO::Exception should be raised")
        rescue RDO::Exception =>e
          e.message.should =~ /sqlite.*file/i
        end
      end
    end
  end
end
