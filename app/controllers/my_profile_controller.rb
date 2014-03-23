class MyProfileController < ApplicationController

  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  before_filter :authorize

  def initialize
    @app_base=app_base
    @app_name='MY_PROFILE'
    @title='My Profile'
    @tagline='About Me'
    @theme='aqualicious'
  end

  def find_my_profile(user_id)
    # Make sure only I can access my profile!  
  end
  
  def index
    list
    render :action => 'list'
  end
  
  def list
    @my_profile=MyProfile.find_by_user_id(session[:user_id])
    @user=User.find(session[:user_id])
  end
  
  def new
    @my_profile=MyProfile.new
  end

  def create
    @my_profile=MyProfile.find_by_user_id(session[:user_id])
    if @my_profile then
      if @my_profile.update_attributes(params[:my_profile]) then
        flash[:notice] = 'My profile was successfully updated.'
        redirect_to :action => 'list'
      end
    else
      params[:my_profile][:user_id]=session[:user_id]
      @my_profile=MyProfile.new(params[:my_profile])
      if @my_profile.save
        flash[:notice] = 'My profile was successfully created.'
        redirect_to :action => 'list'
      else
        render :action => 'new'
      end
    end
  end
  
  def edit
    @my_profile=MyProfile.find_by_user_id(session[:user_id])
  end
  
  def update
    
  end
    
  
end
