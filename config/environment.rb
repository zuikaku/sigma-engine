# Load the rails application
require 'digest'
require 'fileutils'
require 'RMagick'
require File.expand_path('../application', __FILE__)

Haml::Template.options[:format] = :xhtml

MAX_PICTURE_SIZE      = 3000000
ALLOWED_PICTURE_TYPES = ['image/png', 'image/jpeg', 'image/gif']
THREADS_PER_PAGE      = 10
BOARD_LIMIT           = 100
BUMP_LIMIT            = 500

# Initialize the rails application
Sigma::Application.initialize!
