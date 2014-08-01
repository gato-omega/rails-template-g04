#!/usr/bin/env ruby

# Use your Gemfile's :script group when installing gems for scripts only
# dependencies managed by bundler
require 'bundler/setup'
Bundler.require(:script)
require 'active_support/all'

# Use awesome_print inspection from within pry
# taken from: https://github.com/nixme/jazz_hands/blob/v0.5.2/lib/jazz_hands/railtie.rb#L23
if defined? Pry
  Pry.config.print = ->(output, value) do
    pretty = value.ai(indent: 2)
    Pry::Helpers::BaseHelpers.stagger_output("=> #{pretty}", output)
  end
end

class SetupKnife < HighLine

  attr_accessor :app

  def setup(&block)
    binding.pry
    instance_eval(&block) if block_given?
  end

  #--------- default prompt for setup 'wizard'
  def say_with_setup_prompt(statement)
    #statement = "#{setup_prompt}#{statement.to_str}"
    say_without_setup_prompt(statement.to_str.blue)
  end
  alias_method_chain :say, :setup_prompt
  #--------- default prompt for setup 'wizard'

  def change_app_name!
  end

  private

  # load the Rails application (loads configuration too)
  def load_app
    require File.expand_path(File.join('config', 'application.rb'))
    @app ||= Rails.application
  end

  def save_hash_to_file(path, hash)
    HashWithIndifferentAccess.new(hash).to_hash.to_yaml
  end

  def save_to_project(hash)
    save_hash_to_file('.project', hash)
  end

  # Append a line to a file
  def append_line_to_file(path, line)
    run "echo '#{line}' | #{sudo} tee -a #{path}", options
  end

  # Remove matching lines from a file
  def remove_line_from_file(path, line)
    run "#{sudo} sed -i '/#{escape_sed(line)}/d' #{path}", options
  end

  # Remove and append to not append multiple lines
  def ensure_line_appended_to_file(path, line)
    remove_line_from_file(path, line)
    append_line_to_file(path, line)
  end
end
