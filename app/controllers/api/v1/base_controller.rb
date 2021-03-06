# ================================================
# RUBY->API->V1->BASE-CONTROLLER =================
# ================================================
class Api::V1::BaseController < ApplicationController
  before_action :cors_set_access_control_headers

  # ----------------------------------------------
  # CONCERNS -------------------------------------
  # ----------------------------------------------
  include Authenticable

  # ----------------------------------------------
  # ----------------------------------------------
  # ----------------------------------------------
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
  
end
