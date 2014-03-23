class MySchoolController < ApplicationController

  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  before_filter :authorize

  def initialize
    @app_base=app_base
    @app_name='MY_SCHOOL'
    @title='My Schools'
    @tagline='List of my schools.'
    @theme='aqualicious'
  end

  # Make sure it's my school before I can modify 
  def find_this_school(id)
    my_school = MySchool.find_by_id_and_user_id(id, session[:user_id]) 

    unless my_school 
      flash[:error] = 'School not found!'
      redirect_to :action => 'list'      
    end
    my_school
  end
  
  def index
    list
    render :action => 'list'
  end

  def list
    sql=%Q(
      select *
      from my_schools
      where user_id=#{session[:user_id]}
      order by school_type, school_name
    ) #"
    @my_school_pages, @my_schools = paginate_by_sql MySchool, sql, 5
  end

  def new
    @my_school = MySchool.new
  end

  def get_api_scores

    condition_string=%Q(
      year='07'
      and school_type    = '#{params[:my_school][:school_type]}'
      and county_name   = '#{params[:my_school][:county_name]}'
      and district_name = '#{params[:my_school][:district_name]}'
      and school_name   = '#{params[:my_school][:school_name]}'
    ) #'
    school=ApiGrowth.find(:first, :conditions=> condition_string ) 

    if school then
      params[:my_school][:user_id]=session[:user_id]
      params[:my_school][:state_rank]=school.state_rank
      params[:my_school][:county_rank]=school.county_rank
      params[:my_school][:district_rank]=school.district_rank
      params[:my_school][:api_score]=school.api_score
    end  
  end

  def create
    get_api_scores
    @my_school = MySchool.new(params[:my_school])
    
    if @my_school.save
      flash[:notice] = 'My school was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
    session[:my_school]=nil
  end

  def edit
    @my_school=find_this_school(params[:id])
  end

  def update
    get_api_scores
    @my_school=find_this_school(params[:id])
    
    if @my_school.update_attributes(params[:my_school])
      flash[:notice] = 'My school was successfully updated.'
      #redirect_to :action => 'list', :id => @my_school
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
    session[:my_school]=nil
  end

  def destroy
    @my_school=find_this_school(params[:id])
    @my_school.destroy
    redirect_to :action => 'list'
    session[:my_school]=nil
  end
  
  def add_item
    #puts params[:my_school][:school_type]
    #puts params[:my_school][:district_name]
    # render_text "<li>" +  obj[:county_name] + "</li>"
    render :partial  => 'my_school/form'
  end

end
