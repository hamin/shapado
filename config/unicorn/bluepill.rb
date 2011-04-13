Rails.root = ENV["Rails.root"] || ENV["PWD"] || File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
rails_env = ENV["Rails.env"] || 'production'

puts ">> Starting bluepill with Rails.root=#{Rails.root} and Rails.env=#{rails_env}"

Bluepill.application("shapado", :log_file => Rails.root+"/log/bluepill.log") do |app|
  app.process("unicorn-shapado") do |process|
    process.pid_file = File.join(Rails.root, 'tmp', 'pids', 'unicorn.pid')
    process.working_dir = Rails.root

    process.start_command = "unicorn_rails -Dc #{Rails.root}/config/unicorn/unicorn.rb -E #{rails_env}"
    process.stop_command = "kill -QUIT {{PID}}"
    process.restart_command = "kill -USR2 {{PID}}"

    process.start_grace_time = 8.seconds
    process.stop_grace_time = 5.seconds
    process.restart_grace_time = 13.seconds

    process.monitor_children do |child_process|
      child_process.stop_command = "kill -QUIT {{PID}}"

      child_process.checks :mem_usage, :every => 15.seconds, :below => 165.megabytes, :times => [3,4], :fires => :stop
      child_process.checks :cpu_usage, :every => 15.seconds, :below => 90, :times => [3,4], :fires => :stop
    end
  end
end

