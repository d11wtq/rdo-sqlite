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

  describe "#execute" do
    let(:options) { "sqlite::memory:" }

    before(:each) do
      db.execute <<-SQL
      CREATE TABLE test (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(32)
      )
      SQL
    end

    context "with a bad query" do
      let(:result) { db.execute("SELECT * FROM bad_table") }

      it "raises an RDO::Exception" do
        expect { result }.to raise_error(RDO::Exception)
      end

      it "provides a meaningful error message" do
        begin
          result && fail("RDO::Exception should be raised")
        rescue RDO::Exception => e
          e.message.should =~ /bad_table/
        end
      end
    end

    context "with an insert" do
      let(:result) { db.execute("INSERT INTO test (name) VALUES ('bob')") }

      it "returns a RDO::Result" do
        result.should be_a_kind_of(RDO::Result)
      end

      it "provides the #insert_id" do
        result.insert_id.should == 1
      end
    end

    context "with a select" do
      before(:each) do
        db.execute("INSERT INTO test (name) VALUES ('bob')")
        db.execute("INSERT INTO test (name) VALUES ('jane')")
      end

      let(:result) { db.execute("SELECT * FROM test") }

      it "returns a RDO::Result" do
        result.should be_a_kind_of(RDO::Result)
      end

      it "provides the #count" do
        result.count.should == 2
      end

      it "allows enumeration of the rows" do
        rows = []
        result.each {|row| rows << row}
        rows.should == [{id: 1, name: "bob"}, {id: 2, name: "jane"}]
      end

      context "using bind parameters" do
        let(:result) { db.execute("SELECT * FROM test WHERE name = ?", "bob") }

        it "returns a RDO::Result" do
          result.should be_a_kind_of(RDO::Result)
        end

        it "provides the #count" do
          result.count.should == 1
        end
      end
    end
  end
end
