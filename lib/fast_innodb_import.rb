$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "mysql2"
class FastInnodbImport
  VERSION = '0.0.2'
  CMD_MAPPING = { "u" => :username, "h" => :host, "d" => :database, "p" => "password" }
  
  attr_accessor :options, :stream
  
  def initialize(options = {})
    self.options = options
  end
  
  def self.execute(argv, stream = nil)
    importer = self.new(options_from_argv(argv))
    importer.stream = stream
    importer.execute
  end
  
  def execute
    print_usage_and_exit_if_missing_options
    file_paths.each do |path|
      import_data_from_file_path(path)
    end
  end
  
  def import_data_from_file_path(path)
    file_path = File.expand_path(path)
    return if !File.exists?(file_path)
    table_name = table_name_from_file_path(file_path)
    wc = `wc -l #{file_path}`.strip.to_i
    started = Time.now
    if stream
      stream.print "import %d rows from %s: " % [wc, file_path] if stream
      stream.flush
    end
    
    # create drop and create statements as long as we can
    drop_statement = index_drop_statement_for_table(table_name)
    create_statement = index_create_statement_for_table(table_name)
    
    query("TRUNCATE `#{table_name}`")
    query(drop_statement) if drop_keys?
    `#{self.class.import_command_prefix_from_options(options)} #{file_path}`
    query(create_statement) if drop_keys?
    
    # print stats if stream given
    if stream
      diff = Time.now - started
      per_sec = wc / diff
      stream.puts "%d (%d/sec)" % [diff, per_sec]
    end
  end
  
  def options
    @options || {}
  end
  
  def self.options_from_argv(argv)
    options = { :db => {} }
    %w(u h d p).each do |key|
      if idx = argv.index("-#{key}")
        value = argv.at(idx + 1)
        options[:db][CMD_MAPPING[key]] = value if !value.match(/^\-/)
        argv.delete_at(idx)
        argv.delete_at(idx)
      end
    end
    options[:drop_keys] = argv.delete("--without-drop-keys").nil?
    options[:file_paths] = argv
    options
  end

private
  def print_usage_and_exit_if_missing_options
    self.class.print_usage_and_exit if missing_options?
  end
  
  def missing_options?
    !file_paths.respond_to?(:empty?) || file_paths.empty? || db_options[:username].nil? || db_options[:database].nil?
  end
  
  def self.print_usage_and_exit
    puts "Usage: #{File.basename(__FILE__)} [OPTIONS] [dumpfile]"
    puts "  -h                    Database Host"
    puts "  -u                    Database User"
    puts "  -d                    Database Schema Name"
    puts "  -p                    Database Password"
    puts "  --without-drop-keys   Do not drop indexes before import"
    exit
  end
  
  def index_definitions_from_table(table)
    query("SHOW CREATE TABLE #{table}").to_a.first["Create Table"].split("\n").map do |line|
      if line.match(/^\s*KEY \`(.*?)\` \((.*?)\)/)
        { :name => $1, :columns => $2 }
      end
    end.compact
  end
  
  def index_drop_statement_for_table(table_name)
    "ALTER TABLE #{table_name} " + index_definitions_from_table(table_name).map { |config| "\nDROP INDEX #{config[:name]}" }.join(", ")
  end
  
  def index_create_statement_for_table(table_name)
    "ALTER TABLE #{table_name} " + index_definitions_from_table(table_name).map { |config| "\nADD INDEX #{config[:name]} (#{config[:columns]})" }.join(", ")
  end
  
  def db_options
    options[:db] || {}
  end
  
  def self.import_command_prefix_from_options(options)
    cmd = "mysqlimport -L"
    if db_options = options[:db]
      cmd << " -u #{db_options[:username]}" if db_options[:username]
      cmd << " -p#{db_options[:password]}" if db_options[:password]
      cmd << " #{db_options[:database]}" if db_options[:database]
    end
    cmd
  end
  
  def table_name_from_file_path(path)
    File.basename(path).gsub(".txt", "")
  end
  
  def file_paths
    options[:file_paths]
  end
  
  def drop_keys?
    options[:drop_keys]
  end
  
  def client
    @client ||= Mysql2::Client.new(db_options || {})
  end
  
  def query(query)
    client.query(query)
  end
end