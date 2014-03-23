require 'rubygems'
#require_gem 'ym4r'
require 'ym4r'

class CnsController < ApplicationController

  def initialize
    @app_base=app_base
    @app_name='CNS'
    @title='iFanSee.com'
    @tagline='Beta 1 (Date: 03/11/08)'
    @theme='aqualicious'
    @current_year=current_year
#    @capi_url_base="http://www.ifansee.com"
#    @capi_api_app_base="/capi"
    @capi_url_base=url_base
    @capi_api_app_base=app_base
    @all_geopoints = [] # for getting geo center (polygon & geo points)
  end

  def get_parameters
    @html_type = params[:html_type]
    @cds=params[:cds]
    @county_name = params[:county_name] 
    @district_name = params[:district_name] 
    @stype = params[:stype]
    @scount = params[:scount]
    @region = params[:region]
    @district_cds = params[:district_cds]
    @mtype = params[:mtype]
    @show_map=params[:show_map]
    @app_base=app_base
    
    ################
    session[:controller] = controller_name
    session[:county_name] = @county_name
    session[:stype] = @stype
    session[:mtype] = @mtype
  end

  def index
    get_parameters
  end
  
  
  def state
    get_parameters
    
    @title='California'
    @tagline='www.ifansee.com'

    refresh_state
  end

  def refresh_state
    get_parameters

    if @scount != ''

      @schools = ApiGrowth.get_state_top_x_schools(@stype, @current_year, @scount)
      
      cdslist = []
      for school in @schools
        cds= "%02d%05d%07d" % [school.county_code, school.district_code, school.school_code]
        cdslist << cds
      end
      
      @school_cds2geo = IfsSchool.get_school_geo_by_cds(@stype, cdslist.join(','))
    end  
  end


  def region
    get_parameters
    refresh_region
  end

  def refresh_region
    get_parameters

    if @region and @mtype and @scount != '' 

      @schools = ApiGrowth.get_state_top_x_schools_in_region(@stype, @current_year, @region, @scount) if @mtype=='state'
      @schools = ApiGrowth.get_region_top_x_schools(@stype, @current_year, @region, @scount) if @mtype=='region'
      
      cdslist = []
      for school in @schools
        cds= "%02d%05d%07d" % [school.county_code, school.district_code, school.school_code]
        cdslist << cds
      end
      
      @school_cds2geo = IfsSchool.get_school_geo_by_cds(@stype, cdslist.join(','))
    end  
  end

  def county
    get_parameters

    @title="#{@county_name} County"
    @tagline='www.ifansee.com'
   # @polygons = get_polygons_by_county_name(@county_name)
    
    refresh_county
  end

  def refresh_county
    get_parameters

    #
    # Regrieve county polygons
    #
    @polygons = get_polygons_by_county_name(@county_name)
    
    # 
    # Retrieve markers
    #
    case @mtype
      when 'district'
        @districts = ApiSummary.get_district_apis(@stype, @current_year, @county_name)
        @district_cds2gso=IfsSchool.get_district_geo_info(@stype, @county_name)
      when 'county'  
        @schools = ApiGrowth.get_county_top10_schools(@stype, @current_year, @county_name)
        @school_cds2geo = IfsSchool.get_school_geo_info(@stype, @county_name)
      when 'state50'  
        @schools = ApiGrowth.get_state_top50_in_county(@stype, @current_year, @county_name)
        @school_cds2geo = IfsSchool.get_school_geo_info(@stype, @county_name)
      when 'state99'  
        @schools = ApiGrowth.get_state_top100_in_county(@stype, @current_year, @county_name)
        @school_cds2geo = IfsSchool.get_school_geo_info(@stype, @county_name)
    end    
  end


  def county_list
    get_parameters
  end

  def county_list_1
  end

  def district
    get_parameters

    @title="#{@county_name} County"
    @tagline='www.ifansee.com'
    # @polygons = get_polygons_by_county_name(@county_name)
    
    refresh_district
  end

  def refresh_district
    get_parameters

    @polygons = get_polygons_by_county_name(@county_name)

    if @district_cds 
      district_code = @district_cds[2..6]
      @schools = ApiGrowth.find_school_by_district_code(@stype, @current_year, district_code)
  
      cdslist = []
      for school in @schools
        cds= "%02d%05d%07d" % [school.county_code, school.district_code, school.school_code]
        cdslist << cds
      end
      
      @district_name = @schools[0].district_name
      @district_polygons = get_polygons_by_district_name(@district_name)
      
      @school_cds2geo = IfsSchool.get_school_geo_by_cds(@stype, cdslist.join(','))
    else
      # to avoid exceptions (???????)
      @district_polygons = []
      @schools = []
    end  
  end


end
    

