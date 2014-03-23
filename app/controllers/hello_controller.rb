class HelloController < ApplicationController

  def initialize
    @app_base=app_base
    @app_name='HELLO'
    @title='Hello'
    @tagline='iFanSee.com'
    @theme='aqualicious'
  end

  def index
  end

  def ajax
    @html_type = params[:html_type] 
  end
 
  def ajax_form
    @html_type = params[:html_type] 
  end
  
  def gmap_js; end

  def gmap_ruby; end

  def gmap_polygon; end

  def gmap_marker; end

  def gmap_marker_custom; end

  def gmap_refresh
    @html_type = params[:html_type] 
  end

  def gmap_refresh_form
    @html_type = params[:html_type] 
  end

  def gmap_create
  end
  
  
end
