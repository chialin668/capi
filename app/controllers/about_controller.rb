
#
# Create a new controller 
#   ./script/generate controller about
#   Add initialize method (Make sure you have @app_name and @theme defined)
# Create a new layout - about.rhtml under views/layout
# Create _sidebar.rhtml under views/templates/aqualicious/about
# Create index.rhtml under views/about
#

class AboutController < ApplicationController
  
  def initialize
    @app_base=app_base
    @app_name='ABOUT'
    @title='About'
    @tagline='iFanSee.com'
    @theme='aqualicious'
  end

  def index
    
  end
end
