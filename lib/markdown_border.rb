# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "tty-table"
end

class MarkdownBorder < TTY::Table::Border
  def_border do
    left         "| "
    center       " | "
    right        " |"
    mid         "-"
    mid_mid     " | "
    mid_left    "| "
    mid_right   " |"
  end
end
