require "io/console"

namespace :users do
  desc "Create the first admin user when the database has no users"
  task bootstrap_admin: :environment do
    if User.exists?
      puts "Aborted: at least one user already exists."
      puts "This task only bootstraps the first admin user."
      exit 1
    end

    email = ENV["EMAIL"] || prompt("Email")
    first_name = ENV["FIRST_NAME"] || prompt_optional("First name")
    last_name = ENV["LAST_NAME"] || prompt_optional("Last name")
    password = ENV["PASSWORD"] || prompt_password("Password")
    password_confirmation = ENV["PASSWORD_CONFIRMATION"] || prompt_password("Confirm password")

    user = User.new(
      email: email,
      first_name: first_name,
      last_name: last_name,
      password: password,
      password_confirmation: password_confirmation,
      admin: true
    )

    if user.save
      puts "Created admin user: #{user.email}"
    else
      puts "Failed to create admin user:"
      user.errors.full_messages.each { |message| puts "- #{message}" }
      exit 1
    end
  end

  def prompt(label)
    if $stdin.tty?
      print "#{label}: "
      value = $stdin.gets&.strip
      return value if value.present?
      puts "#{label} is required."
      exit 1
    end

    puts "#{label} is required in non-interactive mode. Provide it via environment variables."
    exit 1
  end

  def prompt_optional(label)
    return "" unless $stdin.tty?

    print "#{label} (optional): "
    $stdin.gets&.strip
  end

  def prompt_password(label)
    if $stdin.tty?
      print "#{label}: "
      value = $stdin.noecho(&:gets)&.strip
      puts
      return value if value.present?
      puts "#{label} is required."
      exit 1
    end

    puts "#{label} is required in non-interactive mode. Provide it via environment variables."
    exit 1
  end
end
