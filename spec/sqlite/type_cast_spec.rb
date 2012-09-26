require "spec_helper"

describe RDO::SQLite::Driver, "type casting" do
  let(:options) { "sqlite::memory:" }
  let(:db)      { RDO.open(options) }

  after(:each) { db.close rescue nil }

  describe "null cast" do
    before(:each) do
      db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")
      db.execute("INSERT INTO test (name) VALUES (NULL)")
    end

    let(:value) { db.execute("SELECT name FROM test WHERE id = 1").first_value }

    it "returns nil" do
      value.should be_nil
    end
  end

  describe "text cast" do
    before(:each) do
      db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")
      db.execute("INSERT INTO test (name) VALUES ('bob')")
    end

    let(:value) { db.execute("SELECT name FROM test WHERE id = 1").first_value }

    it "returns a String" do
      value.should == "bob"
    end
  end

  describe "integer cast" do
    before(:each) do
      db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")
      db.execute("INSERT INTO test (name) VALUES ('bob')")
    end

    let(:value) { db.execute("SELECT id FROM test WHERE id = 1").first_value }

    it "returns a Fixnum" do
      value.should == 1
    end
  end

  describe "float cast" do
    before(:each) do
      db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY, score FLOAT)")
      db.execute("INSERT INTO test (score) VALUES (56.4)")
    end

    let(:value) { db.execute("SELECT score FROM test WHERE id = 1").first_value }

    it "returns a Float" do
      value.should == 56.4
    end
  end

  describe "blob cast" do
    before(:each) do
      db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY, salt BLOB)")
      db.execute("INSERT INTO test (salt) VALUES (?)", "\x00\x11\x22")
    end

    let(:value) { db.execute("SELECT salt FROM test WHERE id = 1").first_value }

    it "returns a String" do
      value.should == "\x00\x11\x22"
    end
  end
end
