# frozen_string_literal: true

require "minitest/test_task"

Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.extra_args << "--pride"
  t.warning = false
  t.test_globs = ["test/**/*_test.rb"]
end

# Rake task to automatically run something (i.e. specs) when code files are changed
# By Peter Çoopér
#
# Examples:
#      # rake on_update "rake"
#      # rake on_update "spec spec/user_spec.rb"
#
# License: Public domain.

desc "Automatically run something when code is changed"
task :on_update do
  require "find"
  files = {}

  loop do
    changed = false
    Find.find(File.dirname(__FILE__)) do |file|
      next unless file.match?(/\.rb$/)

      ctime = File.ctime(file).to_i

      if ctime != files[file]
        files[file] = ctime
        changed = true
      end
    end

    if changed
      system ARGV[1]
      puts "=" * 80
      puts "Waiting for a *.rb change"
    end

    sleep 1
  end
end

task default: :test
