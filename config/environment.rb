# Load the rails application
require 'digest'
require 'fileutils'
require 'RMagick'
require File.expand_path('../application', __FILE__)

Haml::Template.options[:format] = :xhtml

MAX_PICTURE_SIZE = 3000000
ALLOWED_PICTURE_TYPES = ['image/png', 'image/jpeg', 'image/gif']

# Initialize the rails application
Sigma::Application.initialize!
