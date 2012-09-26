require "spec_helper"

describe RDO::SQLite::Driver, "type casting" do
  let(:options) { "sqlite::memory:" }
  let(:db)      { RDO.open(options) }

  after(:each) { db.close rescue nil }

  describe "null cast" do
    let(:value) { db.execute("SELECT NULL").first_value }

    it "returns nil" do
      value.should be_nil
    end
  end

  describe "text cast" do
    let(:value) { db.execute("SELECT CAST(42 AS TEXT)").first_value }

    it "returns a String" do
      value.should == "42"
    end
  end

  describe "integer cast" do
    let(:value) { db.execute("SELECT CAST('57' AS INTEGER)").first_value }

    it "returns a Fixnum" do
      value.should == 57
    end
  end

  describe "float cast" do
    let(:value) { db.execute("SELECT CAST('56.4' AS FLOAT)").first_value }

    it "returns a Float" do
      value.should == 56.4
    end
  end

  describe "blob cast" do
    let(:value) { db.execute("SELECT CAST(x'001122' AS BLOB)").first_value }

    it "returns a String" do
      value.should == "\x00\x11\x22"
    end
  end
end
