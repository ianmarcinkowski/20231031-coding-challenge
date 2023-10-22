require 'optparse'
require_relative 'app'

class Parser
  def self.parse(options)
    args = {}

    opt_parser = OptionParser.new do |parser|
      parser.banner = "Usage: challenge.rb -c companies.json -u users.json"

      parser.on("-c", "--companies=COMPANIES", String, "Companies JSON file") do |path|
        args[:company_file] = path
      end

      parser.on("-uUSERS", "--users=USERS", String, "Users JSON file") do |path|
        args[:user_file] = path
      end

      parser.on("-h", "--help", "Prints help message") do
        puts parser
        exit
      end
    end

    opt_parser.parse!(options)
    return args
  end
end

def run_challenge(args)
  unless args.has_key?(:company_file)
    puts "Company file required"
    exit(1)
  end

  unless args.has_key?(:user_file)
    puts "User file required"
    exit(1)
  end

  puts args
  app(args[:company_file], args[:user_file])
end

args = Parser.parse(ARGV)
run_challenge(args)