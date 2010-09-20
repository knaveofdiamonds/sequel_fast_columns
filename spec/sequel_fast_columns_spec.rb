require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Fast column queries" do
  before :each do
    @dataset = TEST_DB[:a]
    @dataset.should_not_receive(:unfiltered)
  end

  it "should just return the selected column symbols" do
    @dataset.select(:foo).columns.should == [:foo]
  end

  it "should return the column name from symbols with __" do
    @dataset.select(:a__foo).columns.should == [:foo]
  end

  it "should return the aliased column name from symbols with ___" do
    @dataset.select(:a__foo___baz).columns.should == [:baz]
    @dataset.select(:foo___baz).columns.should == [:baz]
  end

  it "should return the aliased column name from aliased expressions" do
    @dataset.select(:foo.as(:baz)).columns.should == [:baz]
  end

  it "should return the column name from qualified expressions" do
    @dataset.select(:foo.qualify(:b)).columns.should == [:foo]
  end

  it "should return the column name from qualified aliased expressions" do
    @dataset.select(:a__foo.as(:bar)).columns.should == [:bar]
    @dataset.select(:foo.qualify(:a).as(:bar)).columns.should == [:bar]
  end

  it "should return the columns from the schema if no columns specified" do
    @dataset.columns.should == [:id, :foo]
  end

  it "should return all columns from the schema if :* specified" do
    @dataset.select(:*).columns.should == [:id, :foo]
  end

  it "should return all columns from the schema if qualfied :* specified" do
    @dataset.select(:*.qualify(:a)).columns.should == [:id, :foo]
  end

  it "should return the value as the column" do
    @dataset.select("hello", 1).columns.should == [:hello, :"1"]
  end

  it "should return the SQL for the column for unaliased calculated values" do
    # doesn't work with Sqlite
    # @dataset.select(:sum[:foo]).columns.should == [:"SUM(`foo`)"]
  end
end

describe "Falling back to database query" do
  it "should return all columns when select_append is used" do
    TEST_DB[:a].select_append(:foo).columns.should == [:id, :foo, :foo]
  end

  it "should fall back to querying the db if the dataset is derived" do
    TEST_DB[TEST_DB[:a]].columns.should == [:id, :foo]
  end

  it "should fall back if unqualfied * is used and there are joins" do
    # Again can't get this working with sqlite.
    # TEST_DB.join(:b, :id => :id).columns.should == [:id, :foo, :id, :bar]
  end
end
