require "spec_helper"
require "uri"

describe RDO::SQLite::Driver do
  let(:options) { connection_uri }
  let(:db)      { RDO.open(options) }

  after(:each) { db.close rescue nil }

  describe "#initialize" do
    context "with a relative path to a database" do
      let(:path)   { "./tmp/test.db" }
      let(:options) { "sqlite:#{path}" }

      before(:each) { File.delete(path) if File.exist?(path) }
      after(:each)  { File.delete(path) if File.exist?(path) }

      it "opens a database file" do
        db.should be_open
      end

      it "creates the database file" do
        db
        File.should exist(path)
      end
    end

    context "with an absolute path to a database" do
      let(:path)   { "/tmp/test.db" }
      let(:options) { "sqlite:#{path}" }

      before(:each) { File.delete(path) if File.exist?(path) }
      after(:each)  { File.delete(path) if File.exist?(path) }

      it "opens a database file" do
        db.should be_open
      end

      it "creates the database file" do
        db
        File.should exist(path)
      end
    end

    context "with an in-memory database" do
      let(:options) { "sqlite::memory:" }

      it "opens a database in memory" do
        db.should be_open
      end
    end

    context "with a temporary file database" do
      let(:options) { "sqlite:" }

      it "opens a database file" do
        db.should be_open
      end
    end

    context "with an unusable path" do
      let(:options) { "sqlite:/some/bad/path/to/a.db" }

      it "raises an RDO::Exception" do
        expect { db }.to raise_error(RDO::Exception)
      end

      it "provides a meaningful error message" do
        begin
          db && fail("RDO::Exception should be raised")
        rescue RDO::Exception =>e
          e.message.should =~ /sqlite.*file/i
        end
      end
    end
  end

  describe "#close" do
    it "closes the database" do
      db.close
      db.should_not be_open
    end

    it "returns true" do
      db.close.should == true
    end

    context "called multiple times" do
      it "has no negative side-effects" do
        5.times { db.close }
        db.should_not be_open
      end
    end
  end

  describe "#open" do
    it "opens the database" do
      db.close && db.open
      db.should be_open
    end

    it "returns true" do
      db.close
      db.open.should == true
    end

    context "called multiple times" do
      it "has no negative side-effects" do
        db.close
        5.times { db.open }
        db.should be_open
      end
    end
  end
end
