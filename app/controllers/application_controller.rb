class ApplicationController < ActionController::Base
  # The Authentication concern provides an interface for logging the user in and out. We load it into
  # the ApplicationController so that it will be used across the whole application
  include Authentication
end
