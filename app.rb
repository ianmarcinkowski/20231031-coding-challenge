require_relative 'file_utils'

# Create an entrypoint to separate the concerns of running this application
# as a script from the interesting business logic.
def entry_point(companies_file, users_file)
  puts "companies file: #{companies_file}"
  puts "users file: #{users_file}"

  raw_companies = read_file_content(companies_file)
  raw_users = read_file_content(users_file)
  app(raw_companies, raw_users)
end

def app(companies_string, users_string)

end
