class TruController < ApplicationController

=begin
  508  cp tru_controller.rb abc_controller.rb
  509  cd ../views/
  512  cp -rp tru/ abc
  513  cd layouts/
  515  cp tru.rhtml abc.rhtml
  516  cd ../templates/aqualicious/
  518  cp -rp tru/ abc
=end

=begin
  A 'set' for action 'county' & 'refresh_county'

      controller:
        - tru_controller.rb
      model:
        - tru_summary.rb
      view:
        - refresh_county.rjs
        - county.rhtml
        - _county.rhtml (sidebar)
      helper:
        - tru_helper.rb
=end

  def initialize
    @app_base=app_base
    @app_name='TRU'
    @title='State of California'
    @tagline='iFanSee.com'
    @theme='aqualicious'
    @rows_per_page = 40
    @all_geopoints = [] # for getting geo center (polygon & geo points)
    
    @price_boundaries = [ 500000, 1000000, 1500000 ]
    @num_boundaries = [ 50, 100, 500 ]

  end

  def get_parameters
    @page_type = params[:page_type]
    @state_id = params[:state_id] || '5'
    @county_id = params[:county_id] || '167'
    @city_id = params[:city_id] || '1555'
    @html_type = params[:html_type] 
    @year = params[:year] || current_year
    @month = params[:month] || '1'
    @bedroom = params[:bedroom] || '0'
    @stat_type = params[:stat_type] || 'city'
    @record_type = params[:record_type] || 'num_listed' # num_listed, median_price, average_price
    @show_map = params[:show_map]=='true' ? true : false
  end

  def index; end

  def state
    get_parameters
    refresh_state
  end

  def refresh_state
    get_parameters 
    @counties = TruCounty.find_all_by_state_id(@state_id, :order => 'name')
    state = TruState.find_by_id(@state_id)
    @polygons = get_polygons_by_state_name(state.name)
    
    #puts @polygons
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :action=>'index'  
  end

  def county_list
    @counties = TruCounty.get_county_names(5)
    get_parameters
  end

  def county
    get_parameters
    refresh_county 
  end

  def refresh_county
    get_parameters

    if @show_map
      @ajax_div = nil
      @refresh_method = 'refresh_county'
      @show_map = true
    else  
      @ajax_div = 'ajax_div'
      @refresh_method = 'county'
      @show_map = false
    end

    county = TruCounty.find_by_id(@county_id)
    @county_name = county.name
    
    @stat_type =' city' if not @stat_type
    
    calc_type = 'sum' if @record_type == 'num_listed'
    calc_type = 'avg' if @record_type == 'median_price' or @record_type == 'average_price'

    if @stat_type == 'city'
      sql=%Q(
         # stat_type = city
         select i.id id, i.name city, #{calc_type}(#{@record_type}) data
         from tru_summaries s, tru_zipcodes z, tru_cities i, tru_counties o
         where year = #{@year}
         and s.month = #{@month}
         and bedroom = #{@bedroom}
         and s.stat_type = 'zipcode'
         and s.reference_id = z.id
         and z.city_id = i.id
         and z.county_id = o.id
         and o.name = '#{@county_name}'
         group by city
         order by data desc, city
      ) #'
    else  
      sql= %Q(
         # stat_type = zip
         select z.id id, z.name zipcode, i.name city, #{calc_type}(#{@record_type}) data
         from tru_summaries s, tru_zipcodes z, tru_cities i, tru_counties o
         where year = #{@year}
         and s.month = #{@month}
         and bedroom = #{@bedroom}
         and s.stat_type = 'zipcode'
         and s.reference_id = z.id
         and z.city_id = i.id
         and z.county_id = o.id
         and o.name = '#{@county_name}'
         group by zipcode, city
         order by data desc, zipcode, city
      ) #'

    end  
    
    if @show_map 
      @records = TruSummary.find_by_sql(sql)
    else  
      @record_pages, @records = paginate_by_sql TruSummary, sql, @rows_per_page  
    end

    # google map
    if @show_map 
      if @stat_type == 'city'
        @geopoints = TruCounty.get_city_geoinfo_by_county_name(@year, @month, @bedroom, @county_name)
      else
        @geopoints = TruCounty.get_zipcode_geoinfo_by_county_name(@year, @month, @bedroom, @county_name)
      end
      
      @polygons = get_polygons_by_county_name(@county_name)
    end
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :action=>'index'
  end
  
  def city
    get_parameters
    refresh_city
  end

  def refresh_city
    get_parameters

    if @show_map
      @ajax_div = nil
      @refresh_method = 'refresh_city'
      @show_map = true
    else  
      @ajax_div = 'ajax_div'
      @refresh_method = 'city'
      @show_map = false
    end

    calc_type = 'sum' if @record_type == 'num_listed'
    calc_type = 'avg' if @record_type == 'median_price' or @record_type == 'average_price'

    sql = %Q(
      select z.name zipcode, i.name city, #{calc_type}(#{@record_type}) data
      from tru_summaries s, tru_zipcodes z, tru_cities i, tru_counties o
      where year = #{@year}
        and s.month = #{@month}
        and s.bedroom = #{@bedroom}
        and s.stat_type = 'zipcode'
      and s.reference_id = z.id
      and z.city_id = i.id
      and z.county_id = o.id
      and o.id = #{@county_id}
      and i.id = #{@city_id}
      group by zipcode, city
      order by data desc, zipcode, city
    )
    @records = TruSummary.find_by_sql(sql)
    
    @polygon_hash = {}
#    @polygon_center_hash = {}
    for record in @records
      @polygon_hash[record.zipcode] = get_polygons_by_zipcode(record.zipcode)
#      @polygon_center_hash[record.zipcode] = @map_center
    end
    
    city = TruCity.find_by_id(@city_id)
    @city_name = city.name
    @title = @city_name
    
    county = TruCounty.find_by_id(@county_id)
    @county_name = county.name
    @tagline = "#{@county_name} County"
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :action=>'index'
  end

  def zipcode
    get_parameters
    refresh_zipcode
  end
  
  def refresh_zipcode
    
  end
  
  def table
    get_parameters
    
    if @stat_type == 'zipcode'
      sql=%Q(
        select bedroom, s.name, c.name city, u.name county, #{@record_type} data
        from tru_summaries s, ifs_zipcodes z, ifs_cities c, ifs_counties u
        where year = #{@year}
        and s.month = #{@month}
        and bedroom = #{@bedroom}
        and s.stat_type = '#{@stat_type}'
        and s.name = z.zipcode
        and z.city_id = c.id
        and c.county_id = u.id
        order by data desc
      )    
    else
      sql=%Q(
        select bedroom, name, #{@record_type} data
        from tru_summaries
        where year = #{@year}
        and month = #{@month}
        and bedroom = #{@bedroom}
        and stat_type = '#{@stat_type}'
        order by data desc
      ) 
    end
        
    @record_pages, @records = paginate_by_sql TruSummary, sql, @rows_per_page
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :action=>'index'
  end

end
