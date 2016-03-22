# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/rails'
require 'capistrano/bundler'
require 'capistrano/rvm'
require 'capistrano/puma'

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
