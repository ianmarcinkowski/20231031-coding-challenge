require 'json'
require_relative 'file_utils'

# Create an entrypoint to separate the concerns of running this application
# as a script from the domain logic.
def entry_point(companies_path, users_path)
  puts "companies file: #{companies_path}"
  puts "users file: #{users_path}"

  companies_file = File.open companies_path
  users_file = File.open users_path

  companies = JSON.load companies_file
  users = JSON.load users_file
  app(companies, users)
end

end
