# frozen_string_literal: true

require "bundler/setup"

require "csv"
require "thor"
require "zeitwerk"

loader = Zeitwerk::Loader.new
loader.push_dir("lib")
loader.setup

require_relative "tt_magic_items" # Manualls load the TTMagicItems class with non-Zeitwerk capitalization
