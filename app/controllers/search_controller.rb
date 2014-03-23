class SearchController < ApplicationController
  
#  before_filter :authorize, :except=>:index

  include GetParameter
  include GeoKit::Geocoders

  def initialize
    @app_base=app_base
    @app_name='SEARCH'
    @title='Search'
    @tagline='iFanSee Search Engine'
    @theme='aqualicious'
    @current_year=current_year
    @rec_per_page=10
    # @year=current_year
    @all_geopoints = []
  end
  
  def index
    @search_type = params[:search_type]
  end

  def search
    @search_type = params[:search_type]
    @query = "#{params[:query]}"
    @school_type = params[:school_type]
    @distance = params[:distance]
    @show_map = params[:show_map]=='true'? true : false
    @page = params[:page] || 1
    @api_from = (params[:api_from] == '' ? 200 : params[:api_from])
    @api_to = (params[:api_to] == '' ? 9999 : params[:api_to]) # looks like it's text (so I can't put 1000 here)

    # search on current year only
    if @search_type == 'city' or @search_type == 'zip' or @search_type == 'address'

      if @search_type == 'city'
        @ret_recs = IfsSchool.find(:all, :conditions => "stype = '#{@school_type}' and city = '#{@query}'") 
        
      elsif @search_type == 'zip' or @search_type == 'address'     
        begin 
          @ret_recs = IfsSchool.find(:all, 
                                      :origin => "#{@query}", 
                                      :within => @distance.to_i, 
                                      :conditions => "stype = '#{@school_type}'", 
                                      :order=>'distance asc') 
        rescue GeoKit::Geocoders::GeocodeError
          # do something here!!
          @ret_recs = {}
        end  
        
        if @show_map
          @polygons = get_polygons_by_zipcode(@query) if @search_type == 'zip' 

          # district (my own pagination)
          #                                          
          # NOTE: should use will_paginate
          # http://github.com/mislav/will_paginate/wikis
          #
          district_names = []          
          @total = @ret_recs.length   
          page = (params[:page]||1)
          for i in (0..9)
            recnum = (page.to_i-1)*@rec_per_page.to_i + i
            district_names << @ret_recs[recnum].district_name if @ret_recs[recnum]
          end
          @stype = @school_type
          
          # puts district_names.uniq!
          @name2polygons = {}
          for district_name in district_names
            @name2polygons[district_name] = get_polygons_by_district_name(district_name)
          end
          
          # for Map
          loc = GoogleGeocoder.geocode(@query)
          if loc.success
            @geocenter = {:lat => loc.lat, :lng => loc.lng, :address => loc.full_address }
          else 
            @geocenter = {:lat => 37.350408, :lng => -122.056942, :address => 'CA' } # center of CA
          end
        end                                          

      end

      #                                          
      # NOTE: should use will_paginate
      # http://github.com/mislav/will_paginate/wikis
      #
      @total = @ret_recs.length   

      @records = []
      page = (params[:page]||1)
      for i in (0..9)
        recnum = (page.to_i-1)*@rec_per_page.to_i + i
        @records << @ret_recs[recnum] if @ret_recs[recnum]
      end
        
    elsif @search_type == 'school'
      @total, @records=FerretApiGrowth.full_text_search(
                                      "year:#{@current_year} AND school_type:#{@school_type} AND school_name:#{@query}", 
                                      {:page => (params[:page]||1),
                                       :sort=>['year DESC', 'county_name', 'district_name', 'county_name']})
    elsif @search_type == 'district'
      @total, @records=FerretApiGrowth.full_text_search(
                                      "year:#{@current_year} AND school_type:#{@school_type} AND district_name:#{@query}", 
                                      {:page => (params[:page]||1),
                                       :sort=>['year DESC', 'county_name', 'district_name', 'county_name']})

    elsif @search_type == 'api'
      puts "From: #{@api_from}"
      puts "to: |#{@api_to}|"
      @total, @records=FerretApiGrowth.full_text_search(
                                      "year:#{@current_year} AND school_type:#{@school_type} AND (api_score:>=#{@api_from} AND api_score:<=#{@api_to})", 
                                      {:page => (params[:page]||1),
                                       :sort=>['year DESC', 'api_score DESC', 'county_name', 'district_name', 'county_name']})

    elsif @search_type == 'advanced'
      @total, @records=FerretApiGrowth.full_text_search(
                                      "year:#{@current_year} AND (#{@query})", 
                                      {:page => (params[:page]||1),
                                       :sort=>['year DESC', 'county_name', 'district_name', 'county_name']})
    end
    @pages = pages_for(@total)

  end
  
end
