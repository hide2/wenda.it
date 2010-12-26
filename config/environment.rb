# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WendaIt::Application.initialize!

# limit par page
LIMIT = 10