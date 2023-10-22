# frozen_string_literal: true

def read_file_content(path)
  content = ''

  begin
    # Open the file and read its content
    File.open(path, 'r') do |file|
      content = file.read
    end
  rescue => e
    # TODO: Refactor opportunity: Raise an exception
    # this is simply to get the skeleton of the app off the ground
    puts "An error occurred while reading '#{path}': #{e.message}"
    return nil
  end

  content
end
