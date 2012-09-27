require "spec_helper"
require "bigdecimal"
require "date"

describe RDO::SQLite::Driver, "bind params" do
  let(:options) { "sqlite::memory:" }
  let(:db)      { RDO.connect(options) }
  let(:table)   { "" }
  let(:tuple)   { db.execute("SELECT * FROM test").first }

  before(:each) { db.execute(table) }

  describe "nil param" do
    context "against a text field" do
      let(:table)   { "CREATE TABLE test (name text)" }

      before(:each) { db.execute("INSERT INTO test (name) VALUES (?)", nil) }

      it "is inferred correctly" do
        tuple[:name].should be_nil
      end
    end

    context "against an integer field" do
      let(:table)   { "CREATE TABLE test (age integer)" }

      before(:each) { db.execute("INSERT INTO test (age) VALUES (?)", nil) }

      it "is inferred correctly" do
        tuple[:age].should be_nil
      end
    end

    context "against a float field" do
      let(:table)   { "CREATE TABLE test (score float)" }

      before(:each) { db.execute("INSERT INTO test (score) VALUES (?)", nil) }

      it "is inferred correctly" do
        tuple[:score].should be_nil
      end
    end

    context "against a blob field" do
      let(:table)   { "CREATE TABLE test (salt blob)" }

      before(:each) { db.execute("INSERT INTO test (salt) VALUES (?)", nil) }

      it "is inferred correctly" do
        tuple[:salt].should be_nil
      end
    end
  end

  describe "String param" do
    context "against a text field" do
      let(:table)   { "CREATE TABLE test (name text)" }

      before(:each) { db.execute("INSERT INTO test (name) VALUES (?)", "jim") }

      it "is inferred correctly" do
        tuple[:name].should == "jim"
      end
    end

    context "against an integer field" do
      let(:table)   { "CREATE TABLE test (age integer)" }

      before(:each) { db.execute("INSERT INTO test (age) VALUES (?)", "29") }

      it "is inferred correctly" do
        tuple[:age].should == 29
      end
    end

    context "against an float field" do
      let(:table)   { "CREATE TABLE test (score float)" }

      before(:each) { db.execute("INSERT INTO test (score) VALUES (?)", "56.4") }

      it "is inferred correctly" do
        tuple[:score].should == 56.4
      end
    end

    context "against an blob field" do
      let(:table)   { "CREATE TABLE test (salt blob)" }

      before(:each) { db.execute("INSERT INTO test (salt) VALUES (?)", "\x00\x11\x22") }

      it "is inferred correctly" do
        tuple[:salt].should == "\x00\x11\x22"
      end
    end
  end

  describe "Fixnum param" do
    context "against an integer field" do
      let(:table)   { "CREATE TABLE test (age integer)" }

      before(:each) { db.execute("INSERT INTO test (age) VALUES (?)", 29) }

      it "is inferred correctly" do
        tuple[:age].should == 29
      end
    end

    context "against a text field" do
      let(:table)   { "CREATE TABLE test (name text)" }

      before(:each) { db.execute("INSERT INTO test (name) VALUES (?)", 27) }

      it "is inferred correctly" do
        tuple[:name].should == "27"
      end
    end

    context "against an float field" do
      let(:table)   { "CREATE TABLE test (score float)" }

      before(:each) { db.execute("INSERT INTO test (score) VALUES (?)", 56) }

      it "is inferred correctly" do
        tuple[:score].should == 56.0
      end
    end

    context "against an blob field" do
      let(:table)   { "CREATE TABLE test (salt blob)" }

      before(:each) { db.execute("INSERT INTO test (salt) VALUES (?)", 19) }

      it "is inferred correctly" do
        tuple[:salt].should == "19"
      end
    end
  end

  describe "Float param" do
    context "against an float field" do
      let(:table)   { "CREATE TABLE test (score float)" }

      before(:each) { db.execute("INSERT INTO test (score) VALUES (?)", 56.4) }

      it "is inferred correctly" do
        tuple[:score].should == 56.4
      end
    end

    context "against an integer field" do
      let(:table)   { "CREATE TABLE test (age integer)" }

      before(:each) { db.execute("INSERT INTO test (age) VALUES (?)", 29.2) }

      it "is inferred correctly" do
        tuple[:age].should == 29.2 # sqlite type affinity
      end
    end

    context "against a text field" do
      let(:table)   { "CREATE TABLE test (name text)" }

      before(:each) { db.execute("INSERT INTO test (name) VALUES (?)", 27.4) }

      it "is inferred correctly" do
        tuple[:name].should == "27.4"
      end
    end

    context "against an blob field" do
      let(:table)   { "CREATE TABLE test (salt blob)" }

      before(:each) { db.execute("INSERT INTO test (salt) VALUES (?)", 19.2) }

      it "is inferred correctly" do
        tuple[:salt].should == "19.2"
      end
    end
  end

  describe "Boolean param" do
    context "against an boolean (i.e. numeric) field" do
      context "when it is true" do
        let(:table)   { "CREATE TABLE test (rad boolean)" }

        before(:each) { db.execute("INSERT INTO test (rad) VALUES (?)", true) }

        it "is inferred as integer 1" do
          tuple[:rad].should == 1
        end
      end

      context "when it is false" do
        let(:table)   { "CREATE TABLE test (rad boolean)" }

        before(:each) { db.execute("INSERT INTO test (rad) VALUES (?)", false) }

        it "is inferred as integer 0" do
          tuple[:rad].should == 0
        end
      end
    end
  end

  describe "BigDecimal param" do
    context "against an float field" do
      let(:table)   { "CREATE TABLE test (score float)" }

      before(:each) { db.execute("INSERT INTO test (score) VALUES (?)", BigDecimal("56.4")) }

      it "is inferred correctly" do
        tuple[:score].should == 56.4
      end
    end

    context "against an integer field" do
      let(:table)   { "CREATE TABLE test (age integer)" }

      before(:each) { db.execute("INSERT INTO test (age) VALUES (?)", BigDecimal("29.2")) }

      it "is inferred correctly" do
        tuple[:age].should == 29.2 # sqlite type affinity
      end
    end

    context "against a text field" do
      let(:table)   { "CREATE TABLE test (name text)" }

      before(:each) { db.execute("INSERT INTO test (name) VALUES (?)", BigDecimal("27.4")) }

      it "is inferred correctly" do
        tuple[:name].should == "0.274E2"
      end
    end

    context "against an blob field" do
      let(:table)   { "CREATE TABLE test (salt blob)" }

      before(:each) { db.execute("INSERT INTO test (salt) VALUES (?)", BigDecimal("27.4")) }

      it "is inferred correctly" do
        tuple[:salt].should == "0.274E2"
      end
    end
  end

  describe "Date param" do
    context "against an date (numeric) field" do
      let(:table)   { "CREATE TABLE test (dob date)" }

      before(:each) { db.execute("INSERT INTO test (dob) VALUES (?)", Date.new(1983, 5, 3)) }

      it "is inferred correctly" do
        tuple[:dob].should == "1983-05-03"
      end
    end
  end

  describe "Time param" do
    context "against an datetime (numeric) field" do
      let(:table)   { "CREATE TABLE test (created_at datetime)" }

      before(:each) do
        db.execute(
          "INSERT INTO test (created_at) VALUES (?)",
          Time.new(1983, 5, 3, 7, 15, 43)
        )
      end

      it "is inferred correctly" do
        tuple[:created_at].should == "1983-05-03 07:15:43"
      end

      it "is parseable by sqlite" do
        tuple
        db.execute("SELECT date(created_at, '+1 day') FROM test").first_value.should ==
          "1983-05-04"
      end
    end
  end

  describe "DateTime param" do
    context "against an datetime (numeric) field" do
      let(:table)   { "CREATE TABLE test (created_at datetime)" }

      before(:each) do
        db.execute(
          "INSERT INTO test (created_at) VALUES (?)",
          DateTime.new(1983, 5, 3, 7, 15, 43)
        )
      end

      it "is inferred correctly" do
        tuple[:created_at].should == "1983-05-03 07:15:43"
      end

      it "is parseable by sqlite" do
        tuple
        db.execute("SELECT date(created_at, '+1 day') FROM test").first_value.should ==
          "1983-05-04"
      end
    end
  end

  describe "multiple params" do
    let(:table)   { "CREATE TABLE test (name text, age integer)" }

    before(:each) do
      db.execute("INSERT INTO test (name, age) VALUES (?, ?)", "bob", 27)
    end

    it "binds them all" do
      tuple.should == {name: "bob", age: 27}
    end
  end
end
