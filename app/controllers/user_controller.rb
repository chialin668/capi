require 'digest/sha1'

class UserController < ApplicationController

  before_filter :authorize, :only=>:change_password
  #before_filter :authorize, :except=>:new, :except=>:login ????

  def initialize
    @app_base=app_base
    @app_name='USER'
    @title='My Account'
    @tagline='User Account'
    @theme='aqualicious'
  end

  def new
    @title='Register'      
    if request.get?
      @user=User.new
    else # post
      if params[:user][:email] != params[:verify_user][:verify_email] then
        flash[:error]="Email addresses don't match!"
        render :action => 'new'
      elsif params[:user][:password] != params[:verify_user][:verify_password] then
        flash[:error]="Passwords don't match!"
        render :action => 'new'
      else
        @user = User.new(params[:user])
        if @user.save
          flash[:notice] = 'User was successfully created.'
          redirect_to :controller=>'api', :action=>'index'
        else
          render :action => 'new'
        end
      end
    end
  end

  def login
    if request.get?
      session[:user_id]=nil
      @user=User.new
    else
      @user=User.new(params[:user])
      logged_in_user=@user.try_to_login
      
      if logged_in_user then
        session[:user_id]=logged_in_user.id
        @user.password=nil
        jumpto=session[:jumpto] || {:controller=>'api', :action=>'index'}
        redirect_to(jumpto)
      else
        flash[:warning]='Invalid email/password combination.'
        @user.password=nil
      end
    end
  end

  def logout
    session[:user_id]=nil
    session[:my_school]=nil
    redirect_to :controller=>'api', :action=>'index'
  end

  def change_password
    
  end

  def password

    if params[:user][:email]=='' || 
          params[:verify_user][:old_password]=='' ||
          params[:user][:password]=='' || 
          params[:verify_user][:verify_password]==''
        flash[:error]="At least one of the fields is empty!"
        render :action => 'change_password'
    else
      @user=User.find(session[:user_id])
      if !@user 
         @user=nil
        flash[:error]="User not found!"
        render :action => 'new'
      else
        if Digest::SHA1.hexdigest(params[:verify_user][:old_password]) != @user.password
          @user=nil
          flash[:error]="Invalid password!"
          render :action => 'change_password'
        else
          if params[:user][:password] != params[:verify_user][:verify_password]
            @user=nil
            flash[:error]="Passwords don't match!"
            render :action => 'change_password'
          else
            # save it to db
            @user.update_attributes(:password=>Digest::SHA1.hexdigest(params[:user][:password]))
            @user=nil
            flash[:notice]="Password successfully changed!"
            render :action => 'change_password'
          end
        end
      end
    end
  end

end
