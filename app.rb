require 'json'

# Create an entrypoint to separate the concerns of running this application
# as a script from the domain logic.
def entry_point(companies_path, users_path, output_path)
  puts "companies file: #{companies_path}"
  puts "users file: #{users_path}"
  puts "output file: #{output_path}"

  companies_file = File.open companies_path
  users_file = File.open users_path

  companies = JSON.load companies_file
  users = JSON.load users_file
  companies_file.close
  users_file.close
  report = app(companies, users)

  output_file = File.open(output_path, 'w')
  output_file.write(report)
  output_file.close
end

def app(companies, users)
  database = build_database(companies, users)
  process_token_top_ups!(database)
  report = ""
  database.map do |id, company|
    report += build_company_report(company)
  end
  report
end

def build_database(companies, users)
  database = {}
  companies.map do |company|
    company = symbolize_keys(company)
    company[:users] = []
    company_id = company[:id]
    database[company_id] = company
  end
  users.map do |user|
    user = symbolize_keys(user)
    company_id = user[:company_id]
    database[company_id][:users].append user
  end
  # TODO: Not loving this.  Sorting is a presentation issue
  # I'm going to leave it as an example of a trade-off made during
  # a refactoring, but call it out as a future improvement
  # I would much prefer to sort at the moment I am consuming the DB,
  # like I am with the users
  database = database.sort
end

def process_token_top_ups!(database)
  database.map do |id, company|
    unless company[:top_ups_given]
      company[:top_ups_given] = 0
    end
    top_up_amount = company[:top_up]
    company[:users].filter { |user| user[:active_status] }.map do |user|
      update_user_tokens!(user, top_up_amount)
      company[:top_ups_given] += top_up_amount
    end
  end
  database
end

def update_user_tokens!(user, amount)
  unless user[:token_history]
    user[:token_history] = []
  end
  current_tokens = user[:tokens]
  user[:token_history].unshift(current_tokens)
  user[:tokens] = current_tokens + amount
end

def build_company_report(company)
  header = <<-REPORT.chomp

Company Id: #{company[:id]}
Company Name: #{company[:name]}
  REPORT

  # TODO: Leaving the duplication of sorting logic here for now
  # due to time constraints.
  # I would expect a comment about this on a code review ;)
  if company[:email_status]
    emailed_users = company[:users].filter {
      |user| user[:email_status] && user[:active_status]
    }.sort_by { |user| [user[:last_name], user[:first_name]] }
    not_emailed_users = company[:users].filter {
      |user| !user[:email_status] || !user[:active_status]
    }.sort_by { |user| [user[:last_name], user[:first_name]] }
  else
    emailed_users = []
    not_emailed_users = company[:users].sort_by {
      |user| [user[:last_name], user[:first_name]] }
  end

  section_emailed = <<~REPORT
    Users Emailed:
  REPORT
  emailed_users.map do |user|
    section_emailed += build_user_report(user)
  end

  section_not_emailed = <<~REPORT
    Users Not Emailed:
  REPORT
  not_emailed_users.map do |user|
    section_not_emailed += build_user_report(user)
  end

  section_top_ups_given = <<~REPORT
    Total amount of top ups for #{company[:name]}: #{company[:top_ups_given]}
  REPORT

  # TODO: Some trial and error with heredoc and whitespace
  # This is slightly imperfect compared to the provided example output.
  # Notice that the section for top ups given is 2 spaces less indented than
  # it should be.  I'm calling it an MVP ;)
  report = <<~REPORT
    #{header.strip}
    #{section_emailed.strip}
    #{section_not_emailed.strip}
    #{section_top_ups_given.strip}
  REPORT
  report
end

def build_user_report(user)
  if user[:token_history]
    previous_balance = user[:token_history].first
  else
    previous_balance = ""
  end
  current_balance = user[:tokens]
  report = <<-REPORT
    #{user[:last_name]}, #{user[:first_name]}, #{user[:email]}
      Previous Token Balance, #{previous_balance}
      New Token Balance #{current_balance}
  REPORT
end

def symbolize_keys(a_hash)
  a_hash.transform_keys(&:to_sym)
end
