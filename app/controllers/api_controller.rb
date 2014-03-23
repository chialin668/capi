require 'api_growth'

class ApiController < ApplicationController

  # flash[:error] = 'Parameter Error!'
  # "Error: One of the parameter is nil: #{params[:year]}, #{params[:school_type]}")
  
  attr_accessor :app_name, :mysql_row_limit, :theme
#  before_filter :authorize, :except=>:index
  
  #######################################
  def initialize
    @app_base=app_base
    @app_name='API'
    @title='Carlifornia API Summary'
    @tagline=%Q(Academic Performance Index)
    @theme='aqualicious'
    @mysql_row_limit=20
    @current_year=current_year
    @year=@current_year
  end
  
  #######################################
  def check_params
    raise ParameterException, "ParameterException!\n#{params.to_yaml}" if params[:year].nil? or params[:school_type].nil?
    raise ParameterException, "ParameterException!\n#{params.to_yaml}" unless ['H', 'M', 'E'].include?(params[:school_type])     
    years=[]
    @current_year.to_i.downto(2001) { |year| years << year.to_s}
    raise ParameterException, "ParameterException!\n#{params.to_yaml}" unless years.include?(params[:year])     
  end

  #######################################
  def get_rows_per_page
    my_profile=MyProfile.find_by_user_id(session[:user_id])
    if my_profile
      @mysql_row_limit=my_profile.rows_per_page
    else 
      @mysql_row_limit=20
    end
  end

  #######################################
  def find_my_schools # and save them to session hash
    unless session[:my_school]
      my_schools=MySchool.find(:all, :conditions => %Q(user_id='#{session[:user_id]}')) #"     
      
      # can only have 1 school per school type!!!
      type2school={}
      for school in my_schools
        type2school[school.school_type]=school
      end
      session[:my_school]=type2school
    end
  end

  #######################################
  def index

    @year=params[:year] if params[:year]

    @hrecords=ApiGrowth.find(:all,
                            :conditions => %Q(school_type='H' and year='#{@year}'),
                            :order =>"api_score desc, school_name",
                            :limit => "0,5") #"
 
    @mrecords=ApiGrowth.find(:all,
                            :conditions => %Q(school_type='M' and year='#{@year}'),
                            :order =>"api_score desc, school_name",
                            :limit => "0,5") #"

    @erecords=ApiGrowth.find(:all,
                            :conditions => %Q(school_type='E' and year='#{@year}'),
                            :order =>"api_score desc, school_name",
                            :limit => "0,5") #"
  end

  #######################################
  def all_schools
    check_params
    get_rows_per_page

    @year = params[:year] 
    @school_type=params[:school_type]
    @title="Carlifornia API Summary"
    @tagline="#{@year} Academic Performance Index"

    sql=%Q( 
      select * 
      from api_growths
      where school_type='#{@school_type}' 
      and year='#{@year}'
      order by api_score desc, school_name
    ) #'
    @record_pages, @records = paginate_by_sql ApiGrowth, sql, get_rows_per_page
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :action=>'index'
  end
  
  #######################################
  def regions
    check_params
    get_rows_per_page

    @region=params[:region]
    @year = params[:year] 
    @school_type=params[:school_type]

    if @region=='SF' then
      counties=%Q('Santa Cruz', 'Santa Clara', 'Alameda', 'Contra Costa', 'Solano', 
                'Napa', 'Sonoma', 'Marin', 'San Francisco', 'San Mateo') 
    elsif @region=='LA' then
      counties=%Q('Ventura', 'Los Angeles', 'Orange', 'Riverside', 'San Bernardino')
    end

    sql=%Q(
      select * 
      from api_growths
      where school_type='#{@school_type}' 
      and year='#{@year}' 
      and county_name in (#{counties})
      order by api_score desc, school_name
    ) #'
    @record_pages, @records = paginate_by_sql ApiGrowth, sql, get_rows_per_page
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :action=>'index'
  end
  
  #######################################
  def counties
    check_params
    get_rows_per_page
    
    @year = params[:year] 
    @school_type=params[:school_type]
    @county_name=params[:county_name] 
    
    if !@county_name 
      sql = %Q(
        select distinct county_name
        from api_growths
        where school_type='#{@school_type}'
        and county_name != ''
        and year='#{@year}'
        order by county_name;
      ) #'
      @counties=ApiGrowth.find_by_sql(sql)
    else
      sql=%Q(
        select * 
        from api_growths
        where school_type='#{@school_type}' 
        and year='#{@year}' 
        and county_name='#{@county_name}'
        order by api_score desc, school_name
      ) #'
      @record_pages, @records = paginate_by_sql ApiGrowth, sql, get_rows_per_page
    end
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :action=>'index'
  end

  #######################################
  def districts
    check_params
    get_rows_per_page
    
    @year = params[:year] 
    @school_type=params[:school_type]
    @county_name=params[:county_name]
    @district_name=params[:district_name]

    if !@county_name and !@district_name
      sql = %Q(
        select distinct county_name 
        from api_growths
        where school_type='#{@school_type}'
        and county_name != ''
        and year='#{@year}'
        order by county_name;
      ) #'
      @counties=ApiGrowth.find_by_sql(sql)

    elsif @county_name and !@district_name
      sql = %Q(
        select distinct district_name 
        from api_growths
        where school_type='#{@school_type}'
        and county_name = '#{@county_name}'
        and year='#{@year}'
        order by district_name;
      ) #'
      @districts=ApiGrowth.find_by_sql(sql)
      
    else
      sql=%Q(
        select *
        from api_growths
        where school_type='#{@school_type}' 
        and year='#{@year}' 
        and county_name='#{@county_name}' 
        and district_name='#{@district_name}'
        order by api_score desc, school_name
      ) #'
      @record_pages, @records = paginate_by_sql ApiGrowth, sql, get_rows_per_page   
    end 
 
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :action=>'index'
  end
  
end
