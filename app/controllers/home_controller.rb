class HomeController < ApplicationController
  layout "home"
  def index
    
  end
  def unknown
    @route = params[:other]
  end
end
