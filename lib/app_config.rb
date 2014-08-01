# Loads the application configuration at /config/app_config.yml
# This option is chosen in favor of ENV since it does not override any ENV variable.
app_config = Hash.new

rails_env = Rails.env
rails_root = Rails.root.present? ? Rails.root : Bundler.root # If Rails.root wasn't defined, we can always use Bundler.root

config_filename = 'app_config.yml'
config_file_path = rails_root.join('config', config_filename).to_s

if File.exists? config_file_path
  yaml_config = YAML.load(File.read(config_file_path))
  if yaml_config[rails_env].present?
    puts "[INFO] Loading #{rails_env} configuration settings from #{config_file_path}..."
    app_config = yaml_config[rails_env]
  else
    puts "[WARNING] Environment: '#{rails_env}' is not defined in #{config_file_path} or does not contain any settings"
  end
else
  puts "[WARNING] - Could not find '#{config_file_path}' for configuration settings"
end

# Holds configuration in a class to encapsulate extracting it from various sources
class AppConfig

  attr_accessor :config

  # Initialize on the passed config
  # @param [Hash] config
  def initialize(config)
    @config = HashWithIndifferentAccess.new(config)
  end

  # get the value from given config OR ENV variables set directly on server
  def [](key)
    @config[key] || env_config(key)
  end

  # configuration from environment variables
  def env_config(key)
    ENV[key.to_s] || ENV[key.to_s.upcase]
  end

  # retrieve all configuration key value pairs
  def all
    @config.merge ENV
  end

  def to_s
    @config.map{|k,v| "#{k}=#{v}"}.join("\n")
  end

  # for console output
  def inspect
    to_hash
  end

  def print
    puts to_s
  end

  def to_hash
    @config
  end
end

# Set the constant APP_CONFIG to the AppConfig instance
APP_CONFIG = AppConfig.new(app_config)
