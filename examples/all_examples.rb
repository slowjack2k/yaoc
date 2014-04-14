Dir[File.join(File.expand_path(__dir__), '*.rb')].sort.each do |f|
  unless f =~ /#{__FILE__}$/
    command = %W(ruby #{f})
    puts "executing #{command.join(" ")}"
    system *command
  end
end
