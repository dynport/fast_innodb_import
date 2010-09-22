require File.dirname(__FILE__) + '/../spec_helper.rb'
require "fileutils"

# Time to add your specs!
# http://rspec.info/
describe "Place your specs here" do
  { { :username => "root" } => "-u root",
    { :username => "root", :database => "some_db" } => "-u root some_db",
    { :username => "root", :password => "secret", :database => "some_db" } => "-u root -psecret some_db",
  }.each do |db_options, string|
    it "should constract the correct mysqlimport command prefix for db_options #{db_options.inspect}" do
      FastInnodbImport.send(:import_command_prefix_from_options, { :db => db_options }).should == "mysqlimport -L #{string}"
    end
  end
  
  describe "import from a file" do
    before(:each) do
      @database = "fast_innodb_import_test"
      @username = "root"
      @client = Mysql2::Client.new(:database => @database, :username => @username)
      @client.query("TRUNCATE albums")
      violated if @client.query("SELECT * FROM albums").to_a.length != 0
    end
    
    it "should import a dummy file" do
      importer = FastInnodbImport.new(:db => { :username => @username, :database => @database })
      importer.import_data_from_file_path("spec/fixtures/albums.txt")
      @client.query("SELECT * FROM albums ORDER BY id").to_a.should == [
        { "id" => 1, "artist_name" => "Jay-Z", "title" => "Black Album" },
        { "id" => 2, "artist_name" => "Mos Def", "title" => "Black on Both Sides" },
      ]
    end
    
    it "should write log to stream" do
      FileUtils.rm_f("tmp/import.log")
      stream = File.open("tmp/import.log", "w")
      importer = FastInnodbImport.new(:db => { :username => @username, :database => @database })
      importer.stream = stream
      importer.import_data_from_file_path("spec/fixtures/albums.txt")
      stream.close
      File.read("tmp/import.log").should match(/import 2 rows .*?\/spec\/fixtures\/albums\.txt: \d+ \(\d+\/sec\)/)
      FileUtils.rm_f("tmp/import.log")
    end
    
    it "should import data when called with ARGV options" do
      FastInnodbImport.execute(["-u", @username, "-d", @database, "spec/fixtures/albums.txt"])
      @client.query("SELECT * FROM albums").to_a.length.should == 2
    end
  end
end
