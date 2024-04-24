#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/inline"
require "csv"

gemfile do
  source "https://rubygems.org"
  gem "thor", "~> 1.2.1"
end

class DocxToCSV < Thor
  desc "convert FILE_NAME", "Convert a docx file dump to a CSV file"
  def convert(file_name)
    file_name = Pathname.new(file_name)
    name = file_name.basename.sub(/\.[^.]+\z/, "")
    dirname = file_name.dirname
    csv_file_name = dirname.join("#{name}.csv")

    input = File.open(file_name)
    csv_file = CSV.open(csv_file_name, "w")
    puts "Converting #{file_name} to #{csv_file_name}..."

    line = [nil, nil, nil, nil, nil]
    input.each_line.with_index do |l, index|
      data = l.chomp.gsub(/\s+/, " ").strip
      line[index % 5] = data unless data.empty?
      csv_file.puts line if index % 5 == 4
    end
    csv_file.close
  end
end

DocxToCSV.start(ARGV)
