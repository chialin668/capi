#require 'api_summary'
#require 'star_result'
#require 'star_category'
#require 'star_test'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ParameterException < Exception; end


class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_star_session_id'
  
  def authorize
    unless session[:user_id]
      flash[:notice]='Please log in....'
      session[:jumpto]=request.parameters
      redirect_to(:controller=>'user', :action=>'login')
    end
  end  
  
  def current_year
    return '2008'
  end
  
  def url_base
    "http://localhost:3000"
  end
  
  def app_base
#    return '/capi'
    return ''
  end
  

  ###################################################
  def get_polygons_by_state_name(state_name)
    
    states = CnsState.find_all_by_state_name(state_name)
    polygons = []
    
      for state in states
        polygon = CnsStatePolygon.find_all_by_polygon_id(state.polygon_id)
        
        latlngs=[]
        for point in polygon
          if point.geotype=='C'
            # average the map centers (if we have more than one)
            if @map_center #
              @map_center = [(point.lat.to_f+@map_center[0])/2, (point.lng.to_f+@map_center[1])/2] 
            else
              @map_center = [point.lat.to_f, point.lng.to_f]
            end
          elsif point.geotype=='P'
            latlngs << [point.lat.to_f, point.lng.to_f]
          end
        end
        polygons << latlngs
      end
      polygons
  end
  
  def get_polygons_by_county_name(county_name)
    
      counties = CnsCounty.find_all_by_county_name(county_name) 
      polygons=[]
      
      for county in counties 
        polygon = CnsCountyPolygon.find_all_by_polygon_id(county.polygon_id)
        
        latlngs=[]
        for point in polygon
          if point.geotype=='C'
            # average the map centers (if we have more than one)
            if @map_center #
              @map_center = [(point.lat.to_f+@map_center[0])/2, (point.lng.to_f+@map_center[1])/2] 
            else
              @map_center = [point.lat.to_f, point.lng.to_f]
            end
          elsif point.geotype=='P'
            latlngs << [point.lat.to_f, point.lng.to_f]
          end
        end
        polygons << latlngs
      end
      polygons
  end

  def get_polygons_by_district_name(district_name)
    #
    # district polygons (from US Census - school information)
    #
    district_types = "('S', 'U')" if @stype=='H'
    district_types = "('E', 'U')" if @stype=='E' or @stype=='M'

    # NOTE: the length of district_name in cns_schools is 30 (even it's varchar(64))
    dname = district_name[0..29]
    dname = "('#{dname}')" if @stype=='H'
    dname = "('#{dname}', '#{dname} Elementary')" if @stype=='E' or @stype=='M'
    
    district=CnsSchool.find_district_by_name_and_types(dname, district_types)

    district_polygons=[]
    if district.size > 0
      polygon=CnsSchoolPolygon.find_all_by_polygon_id_and_district_type(district[0].polygon_id, district[0].district_type)

      latlngs=[]
      for point in polygon
        if point.geotype=='C'
          if @map_center
            @map_center = [(point.lat.to_f+@map_center[0])/2, (point.lng.to_f+@map_center[1])/2] 
          else
            @map_center = [point.lat.to_f, point.lng.to_f]
          end
        elsif point.geotype=='P'
          latlngs << [point.lat.to_f, point.lng.to_f] 
        end
      end
      # for 'refresh'
      district_polygons << latlngs
    end
    district_polygons
  end


  def get_polygons_by_zipcode(zip)
    polygons=[]
    zipcodes = CnsZipcode.find_all_by_zipcode(zip)
    for zipcode in zipcodes
      polygon = CnsZipcodePolygon.find_all_by_polygon_id(zipcode.polygon_id)
        latlngs=[]
        for point in polygon
          if point.geotype=='C'
            # average the map centers (if we have more than one)
            if @map_center #
              @map_center = [(point.lat.to_f+@map_center[0])/2, (point.lng.to_f+@map_center[1])/2] 
            else
              @map_center = [point.lat.to_f, point.lng.to_f]
            end
          elsif point.geotype=='P'
            latlngs << [point.lat.to_f, point.lng.to_f]
          end
        end
        polygons << latlngs
    end
    polygons
  end
  
  
end


######################################################
# pagitation 
######################################################
module ActiveRecord
    class Base
        
        # sql
        def self.find_by_sql_with_limit(sql, offset, limit)
            sql = sanitize_sql(sql)
            add_limit!(sql, {:limit => limit, :offset => offset})
            find_by_sql(sql)
        end

        def self.count_by_sql_wrapping_select_query(sql)
            sql = sanitize_sql(sql)
            count_by_sql("select count(*) from (#{sql}) as my_table")
        end

        # ferret 
        def self.full_text_search(q, options = {})
           return nil if q.nil? or q==""
           default_options = {:limit => 10, :page => 1}
           options = default_options.merge options

           # get the offset based on what page we're on
           options[:offset] = options[:limit] * (options.delete(:page).to_i-1)  

           # now do the query with our options
           results = self.find_by_contents(q, options)
           return [results.total_hits, results]
        end  
   end

end

# 
class ApplicationController < ActionController::Base
  
    # sql pagination
    def paginate_by_sql(model, sql, per_page, options={})
       if options[:count]
           if options[:count].is_a? Integer
               total = options[:count]
           else
               total = model.count_by_sql(options[:count])
           end
       else
           total = model.count_by_sql_wrapping_select_query(sql)
       end

       object_pages = Paginator.new self, total, per_page, params['page']
       objects = model.find_by_sql_with_limit(sql, object_pages.current.to_sql[1], per_page)
       return [object_pages, objects]
     end

    # Ferret patination
    def pages_for(size, options = {})
      default_options = {:per_page => 10}
      options = default_options.merge options
      pages = Paginator.new self, size, options[:per_page], (params[:page]||1)
      return pages
    end

 end

 ######################################################
 # Parameter
 ######################################################
 
 module GetParameter

  def method_name
    caller[0] =~ /`([^']*)'/ and $1
  end  

  def set_title(title='', tagline='')
    @title=title
    @tagline=tagline
  end

  def get_parameters
    @html_type = params[:html_type]
    @school_type = params[:school_type]
    @year = params[:year]
    @grade = params[:grade]
    @school_code = params[:school_code]
    @district_code = params[:district_code]
    @county_code = params[:county_code]
    @show_map = params[:show_map]

    # we have codes, not get the names
    @school_hash, @school_name, @district_name, @county_name = StarCategory.get_names(@school_code, @district_code, @county_code)
    set_title
    
  end

  def parse_xml_params
    xml_params=params[:xml_params]
    parameters=xml_params.split('|')
    for parameter in parameters
      data=parameter.split('=')
      @school_type=data[1] if data[0]=='school_type'
      @year=data[1] if data[0]=='year'
      @grade=data[1] if data[0]=='grade'
      @school_code=data[1] if data[0]=='school_code'
      @district_code=data[1] if data[0]=='district_code'
      @county_code=data[1] if data[0]=='county_code'
      @test_id=data[1] if data[0]=='test_id'
      @test_name=data[1] if data[0]=='test_name'
      @score_type=data[1] if data[0]=='score_type'
    end  

    @school_hash, @school_name, @district_name, @county_name = StarCategory.get_names(@school_code, @district_code, @county_code)
    
  end

  
  ###################################################################
  # Charts
  ###################################################################
  module Chart  
    
    def line_data(xml, min=0, max=1000, explode=true)

      if explode 
        explode_str=%Q(
            <series_explode>
              <number>300</number>
              <number>170</number>
              <number>170</number>
              <number>170</number>
              <number>170</number>
              <number>170</number>
            </series_explode>
        ) 
      else
        explode_str=%Q(
            <series_explode>
              <number>170</number>
              <number>170</number>
              <number>170</number>
              <number>170</number>
              <number>170</number>
              <number>170</number>
            </series_explode>
        ) 
      end      
    
      data=%Q(
        <chart>
        
          <axis_category size='12' color='0a0f55' alpha='75' skip='0' orientation='horizontal' />
          <axis_ticks value_ticks='false' category_ticks='true' 
                        major_thickness='2' minor_thickness='1' minor_count='1' 
                        major_color='000000' minor_color='222222' position='inside' />
                        
          <axis_value min='#{min}' max='#{max}' size='15' color='0f0000' alpha='50' steps='3' prefix='' 
              suffix='' decimals='0' separator='' show_min='false' />
          
          #{xml}        
          
          <chart_grid_h alpha='10' color='000000' thickness='1' />
          <chart_pref line_thickness='2' point_shape='circle' fill_shape='false' />
          <chart_rect x='50' y='75' width='320' height='200' positive_color='ffffff' positive_alpha='50' 
                                                              negative_color='000000' negative_alpha='10' />
          <!--chart_transition type='slide_left' delay='.5' duration='0.5' order='series' /-->
          <chart_type>Line</chart_type>
          <chart_value position='cursor' size='12' color='000000' background_color='ffffff' alpha='80' />
          
          <legend_label layout='horizontal' bullet='line' font='arial' bold='true' size='13' color='220033' alpha='65' />
          <legend_rect x='50' y='5' width='320' height='5' margin='5' fill_color='e0e0ee' fill_alpha='40' 
                                    line_color='000000' line_alpha='0' line_thickness='0' />
          <legend_transition type='dissolve' delay='0' duration='0.5' />
          
          <series_color>
            <color>7D053F</color>
            <color>347C17</color>
            <color>1589FF</color>
            <color>F76541</color>
            <color>F660AB</color>
            <color>87F717</color>
          </series_color>
          
          #{explode_str}
         
        </chart>
      ) #'
    
      data      
    end
    
        
    def column(xml, min=400, max=1000)
      data=%Q(
        <chart>
        
          <axis_category font='arial' bold='true' size='11' color='000000' alpha='50' skip='2' />
          <axis_ticks value_ticks='false' category_ticks='true' major_thickness='2' minor_thickness='1' minor_count='3' major_color='000000' minor_color='888888' position='outside' />
          <axis_value min='#{min}' max='#{max}' font='arial' bold='true' size='10' color='000000' alpha='50' steps='4' prefix='' suffix='' decimals='0' separator='' show_min='true' />
        
          <chart_border color='000000' top_thickness='1' bottom_thickness='2' left_thickness='0' right_thickness='0' />

          #{xml}
          
          <chart_grid_h alpha='10' color='0066FF' thickness='28' />
          <chart_grid_v alpha='10' color='0066FF' thickness='1' />
          <chart_rect x='30' y='70' width='350' height='200' positive_color='FFFFFF' positive_alpha='40' />
          <chart_value color='ffffff' alpha='85' font='arial' bold='true' size='10' 
                    position='middle' prefix='' suffix='' decimals='0' separator='' as_percentage='false' />
        
          <legend_label layout='horizontal' font='arial' bold='true' size='12' color='333355' alpha='90' />
          <legend_rect x='30' y='5' width='350' height='15' margin='5' fill_color='000066' fill_alpha='8' 
                    line_color='000000' line_alpha='0' line_thickness='0' />
        
          <series_color>
            <color>cccc66</color>
            <color>cc66cc</color>
            <color>cc6666</color>
            <color>66cccc</color>
            <color>66cc66</color>
            <color>6666cc</color>
            <color>666666</color>
          </series_color>
          <series_gap set_gap='30' bar_gap='0' />
        
        </chart>
        
      )
      data
    end

   
   
    # w in (x, y, z)
    def line_on_column(xmlparams)

      xml = xmlparams[:xml]
      min = xmlparams[:min] ? xmlparams[:min] : 400
      max = xmlparams[:max] ? xmlparams[:max] : 1000
      explode = xmlparams[:explode] ? xmlparams[:explode] : false

      explode_str=''
      if explode
        explode_str=%Q(
            <series_explode>
              <number>200</number>
            </series_explode>
        )
      end
        

      # data string for the chart
      data=%Q(
          <chart>
          
            <axis_value min='#{min}' max='#{max}' font='arial' bold='true' size='10' 
                  color='000000' alpha='50' steps='4' prefix='' suffix='' decimals='0' separator='' show_min='true' />
  
            <chart_border color='000000' top_thickness='1' bottom_thickness='2' left_thickness='0' right_thickness='0' />
  
           #{xml}
  
            <chart_grid_h alpha='20' color='000000' thickness='1' type='dashed' />
            <chart_rect x='55' y='70' width='300' height='200' positive_color='ffffff' negative_color='000000' 
                      positive_alpha='10' negative_alpha='30' />
            <!--chart_transition type='scale' delay='.5' duration='0.5' order='series' /-->
            <chart_value color='ffffff' alpha='85' font='arial' bold='true' size='10' 
                      position='middle' prefix='' suffix='' decimals='0' separator='' as_percentage='false' />
  
            <legend_label layout='horizontal' font='arial' bold='true' size='12' color='333355' alpha='90' />
            <legend_rect x='55' y='5' width='300' height='15' margin='5' fill_color='000066' fill_alpha='8' 
                      line_color='000000' line_alpha='0' line_thickness='0' />
          
            <chart_type>
              <string>column</string>
              <string>line</string>
              <string>line</string>
              <string>line</string>
            </chart_type>
            
            <series_color>
              <color>050222</color>
              <color>41A317</color>
              <color>FFF380</color>
              <color>F660AB</color>
            </series_color>
            <series_gap set_gap='40' bar_gap='-5' />
  
            #{explode_str}
            
          </chart>
      ) #'
  
      data
    end
  end


  def staked_column_1(xml)
    data=%Q(
      <chart>
        <axis_value min='0' max='102' font='arial' bold='true' size='15' color='00254f' steps='5' prefix='' suffix='' decimals='0' separator='' show_min='false' />
        <chart_border color='000000' top_thickness='0' bottom_thickness='3' left_thickness='0' right_thickness='0' />

        #{xml}

        <chart_grid_h alpha='20' color='000000' thickness='1' type='solid' />
        <chart_grid_v alpha='20' color='000000' thickness='1' type='dashed' />
        <chart_rect x='55' y='65' width='300' height='200' positive_color='ffffff' negative_color='000000' positive_alpha='75' negative_alpha='15' />
        <chart_type>stacked column</chart_type>
        <chart_value position='cursor' size='12' color='000000' background_color='ffffff' alpha='80' />
      
        <draw>
          <text delay='0' duration='0.5' color='000033' alpha='15' font='arial' rotation='-90' bold='true' size='64' 
                    x='0' y='395' width='300' height='50' h_align='right' v_align='middle'>%</text>
          <text delay='0' duration='0.5' color='ffffff' alpha='40' font='arial' rotation='-90' bold='true' size='25' 
                x='10' y='330' width='300' height='30' h_align='right' v_align='middle'>Report</text>
        </draw>
      
        <legend_label layout='horizontal' font='arial' bold='true' size='13' color='444466' alpha='90' />
        <legend_rect x='55' y='10' width='300' height='5' margin='5' fill_color='000000' fill_alpha='7' 
                                  line_color='000000' line_alpha='0' line_thickness='0' />
      
        <series_color>
          <color>191970</color>
          <color>224033</color>
          <color>ffd733</color>
          <color>ff6347</color>
          <color>900000</color>
        </series_color>
      
      </chart>
      ) 
      data    
  end
  
  
  def staked_area(xml)
    data=%Q(
      <chart>
      
        <axis_category size='12' color='000000' alpha='75' font='arial' bold='true' skip='0' orientation='horizontal' />
        <axis_value font='arial' bold='true' size='10' color='332200' alpha='60' steps='6' prefix='' suffix='' decimals='0' separator='' show_min='false' />
      
        <chart_border color='000000' top_thickness='1' bottom_thickness='2' left_thickness='1' right_thickness='1' />

        #{xml}

        <chart_grid_h color='000000' thickness='1' />
        <chart_rect x='50' y='75' width='320' height='175' positive_color='ffffff' positive_alpha='30' negative_color='ff0000' negative_alpha='10' />
        <chart_type>stacked area</chart_type>
      
        <draw>
          <text transition='dissolve' delay='0' duration='1' color='ffffff' alpha='15' font='arial' rotation='-5' bold='true' size='60' x='10' y='-10' width='400' height='150' h_align='center' v_align='middle'>stacked regions</text>
          <text transition='dissolve' delay='0' duration='1' color='000066' alpha='5' font='arial' rotation='0' bold='true' size='45' x='0' y='-15' width='200' height='50' h_align='left' v_align='top'>report</text>
        </draw>
      
        <legend_label layout='horizontal' font='arial' bold='true' size='13' color='444466' alpha='90' />
        <legend_rect x='55' y='10' width='300' height='5' margin='5' fill_color='000000' fill_alpha='7' 
                                  line_color='000000' line_alpha='0' line_thickness='0' />
      
        <series_color>
          <color>222280</color>
          <color>224033</color>
          <color>ffd733</color>
          <color>bb4511</color>
          <color>ff2222</color>
        </series_color>
      
      </chart>
    )
    data
  end
  
  
  def area_1(xml)
    data = %Q(
        <chart>
        
          <axis_category size='16' color='000000' alpha='75' font='arial' bold='true' skip='0' orientation='horizontal' />
          <axis_ticks value_ticks='false' category_ticks='true' major_thickness='2' minor_thickness='1' minor_count='1' 
                major_color='000000' minor_color='222222' position='inside' />
          <axis_value min='0' max='100' font='arial' bold='true' size='10' color='0000ff' alpha='50' steps='5' prefix='' suffix='' decimals='0' separator='' show_min='false' />
        
          <chart_border color='000000' top_thickness='1' bottom_thickness='2' left_thickness='1' right_thickness='1' />
        
          #{xml}
          
          <chart_grid_h alpha='5' color='000000' thickness='5' />
          <chart_rect x='50' y='50' width='320' height='200' positive_color='ffffff' positive_alpha='50' negative_color='ff0000' negative_alpha='10' />
          <chart_type>area</chart_type>
          <chart_value position='cursor' size='12' color='000000' background_color='ffffff' alpha='80' />
          
          <draw>
            <text color='0000aa' alpha='10' font='arial' rotation='0' bold='true' size='30' x='0' y='140' width='400' height='150' 
                        h_align='center' v_align='bottom'>|||||||||||||||||||||||||||||||||||||||||||||||</text>
          </draw>
        
          <legend_label layout='horizontal' font='arial' bold='true' size='13' color='ab23ff' alpha='50' />
          <legend_rect x='25' y='15' width='350' height='5' margin='3' fill_color='ffffff' fill_alpha='10' line_color='000000' line_alpha='0' line_thickness='0' />
        
          <series_color>
            <color>0088ff</color>
            <color>88ff00</color>
            <color>ff8800</color>
            <color>564546</color>
            <color>784e3a</color>
            <color>677b75</color>
          </series_color>
        
        </chart>

    ) #'
    data    
  end
  
  def polar_1(xml, min, max)
    data=%Q(
      <chart>
        <axis_category size='12' color='000000' alpha='25' orientation='circular' />
        <axis_ticks value_ticks='1' category_ticks='1' major_color='444444' major_thickness='2' minor_count='0' />
        <axis_value min='#{min}' max='#{max}' size='11' alpha='90' color='ffffff' show_min='' background_color='446688' />
        
        <chart_border bottom_thickness='2' left_thickness='2' color='444444' />

        #{xml}

       <chart_grid_h alpha='20' color='000000' thickness='1' type='solid' />
        <chart_grid_v alpha='10' color='000000' thickness='2' type='dotted' />
        <chart_pref point_shape='none' point_size='0' fill_shape='' line_thickness='2' type='line' grid='circular' />
        <chart_rect x='-20' y='40' width='350' height='200' positive_color='ffffff' positive_alpha='10' />
        <chart_type>polar</chart_type>
        
        <draw>
          <text color='000033' alpha='25' rotation='0' size='30' x='0' y='0' width='390' height='295' h_align='right' v_align='bottom'>By Subject</text>
          <circle layer='background' x='155' y='140' radius='170' fill_alpha='0' line_color='000000' line_alpha='5' line_thickness='40' />
        </draw>
        
        <legend_label layout='vertical' bullet='line' size='12' color='ffffff' alpha='90' />
        <legend_rect x='290' y='180' width='20' height='70' margin='5' fill_alpha='10' />
        
        <series_color>
          <color>ff4400</color>
          <color>ffff00</color>
          <color>88ffff</color>
          <color>88ff00</color>
        </series_color>
        
      </chart>
    
    )
    data
  end
  
  def three_d_pie(xml)
    data=%Q(
        <chart>

          #{xml}
          
          <chart_grid_h thickness='0' />
          <chart_pref rotation_x='60' />
          <chart_rect x='100' y='50' width='300' height='200' positive_alpha='0' />
          <!--chart_transition type='spin' delay='.5' duration='0.75' order='category' /-->
          <chart_type>3d pie</chart_type>
          <chart_value color='000000' alpha='65' font='arial' bold='true' size='10' position='inside' prefix='' suffix='' decimals='0' separator='' as_percentage='true' />
        
          <draw>
            <text color='000000' alpha='4' size='40' x='-50' y='260' width='500' height='50' h_align='center' v_align='middle'>56789012345678901234</text>
          </draw>
        
          <legend_label layout='horizontal' bullet='circle' font='arial' bold='true' size='12' color='333388' alpha='85' />
          <legend_rect x='0' y='45' width='50' height='210' margin='10' fill_color='ffffff' fill_alpha='10' line_color='000000' line_alpha='0' line_thickness='0' />
          <legend_transition type='dissolve' delay='0' duration='1' />
        
          <series_color>
            <color>cccc66</color>
            <color>cc66cc</color>
            <color>cc6666</color>
            <color>66cccc</color>
            <color>66cc66</color>
            <color>6666cc</color>
            <color>a5f222</color>
            <color>ffffff</color>
          </series_color>
        </chart>
    )
    data
  end

  
    def line_data_tru(xml, min=0, max=1000, explode=true)

      if explode 
        explode_str=%Q(
            <series_explode>
              <number>300</number>
              <number>170</number>
              <number>170</number>
              <number>170</number>
              <number>170</number>
              <number>170</number>
            </series_explode>
        ) 
      else
        explode_str=%Q(
            <series_explode>
              <number>170</number>
              <number>170</number>
              <number>170</number>
              <number>170</number>
              <number>170</number>
              <number>170</number>
            </series_explode>
        ) 
      end      
    
      data=%Q(
        <chart>
        
          <axis_category size='12' color='0a0f55' alpha='75' skip='0' orientation='horizontal' />
          <axis_ticks value_ticks='false' category_ticks='true' 
                        major_thickness='2' minor_thickness='1' minor_count='1' 
                        major_color='000000' minor_color='222222' position='inside' />
                        
          <axis_value min='#{min}' max='#{max}' size='15' color='0f0000' alpha='50' steps='3' prefix='' 
              suffix='' decimals='0' separator=',' show_min='false' />
          
          #{xml}        
          
          <chart_grid_h alpha='10' color='000000' thickness='1' />
          <chart_pref line_thickness='2' point_shape='circle' fill_shape='false' />
          <chart_rect x='70' y='75' width='520' height='200' positive_color='ffffff' positive_alpha='50' 
                                                              negative_color='000000' negative_alpha='10' />
          <!--chart_transition type='slide_left' delay='.5' duration='0.5' order='series' /-->
          <chart_type>Line</chart_type>
          <chart_value position='cursor' size='12' separator=',' color='000000' background_color='ffffff' alpha='80' />
          
          <legend_label layout='horizontal' bullet='line' font='arial' bold='true' size='13' color='220033' alpha='65' />
          <legend_rect x='70' y='5' width='520' height='5' margin='5' fill_color='e0e0ee' fill_alpha='40' 
                                    line_color='000000' line_alpha='0' line_thickness='0' />
          <legend_transition type='dissolve' delay='0' duration='0.5' />
          
          <series_color>
            <color>7D053F</color>
            <color>347C17</color>
            <color>1589FF</color>
            <color>F76541</color>
            <color>F660AB</color>
            <color>87F717</color>
          </series_color>
          
          #{explode_str}
         
        </chart>
      ) #'
    
      data      
    end
    
    def column_tru(xml, min, max)
      data=%Q(
        <chart>
        
          <axis_value min='#{min}' max='#{max}' font='arial' bold='true' size='10' color='000000' alpha='50' steps='4' prefix='' suffix='' decimals='0' separator='' show_min='true' />
          <chart_border color='000000' top_thickness='1' bottom_thickness='2' left_thickness='0' right_thickness='0' />
        

          #{xml}

          <chart_grid_h alpha='20' color='000000' thickness='1' type='dashed' />
          <chart_rect x='75' y='50' width='520' height='200' positive_color='000066' negative_color='000000' positive_alpha='10' negative_alpha='30' />
          <!--chart_transition type='scale' delay='.5' duration='0.5' order='series' /-->
          <chart_value color='ffffff' alpha='85' font='arial' bold='true' size='10' position='middle' prefix='' suffix='' decimals='0' separator='' as_percentage='false' />
        
          <draw>
            <text color='000000' alpha='10' font='arial' rotation='-90' bold='true' size='75' x='-20' y='300' width='520' height='200' h_align='left' v_align='top'>Growth</text>
            <text color='000033' alpha='50' font='arial' rotation='-90' bold='true' size='16' x='7' y='230' width='520' height='50' h_align='center' v_align='middle'>(millions)</text>
          </draw>
        
          <legend_label layout='horizontal' font='arial' bold='true' size='12' color='333355' alpha='90' />
          <legend_rect x='75' y='27' width='520' height='20' margin='5' fill_color='000066' fill_alpha='8' line_color='000000' line_alpha='0' line_thickness='0' />
        
          <series_color>
            <color>666666</color>
            <color>768bb3</color>
          </series_color>
          <series_gap set_gap='40' bar_gap='-25' />
          
        </chart>
      )    
      
      data
    end
    

    def line_on_column_tru(xml, min, max)

      # data string for the chart
      data=%Q(
          <chart>
          
            <axis_value min='#{min}' max='#{max}' font='arial' bold='true' size='10' 
                  color='000000' alpha='50' steps='4' prefix='' suffix='' decimals='0' separator=',' show_min='true' />
  
            <chart_border color='000000' top_thickness='1' bottom_thickness='2' left_thickness='0' right_thickness='0' />
  
           #{xml}
  
            <chart_grid_h alpha='20' color='000000' thickness='1' type='dashed' />
            <chart_rect x='55' y='70' width='520' height='200' positive_color='ffffff' negative_color='000000' 
                      positive_alpha='10' negative_alpha='30' />
            <!--chart_transition type='scale' delay='.5' duration='0.5' order='series' /-->
            <chart_value color='ffffff' alpha='85' font='arial' bold='true' size='10' 
                      position='middle' prefix='' suffix='' decimals='0' separator=',' as_percentage='false' />
  
            <legend_label layout='horizontal' font='arial' bold='true' size='12' color='333355' alpha='90' />
            <legend_rect x='55' y='5' width='520' height='15' margin='5' fill_color='000066' fill_alpha='8' 
                      line_color='000000' line_alpha='0' line_thickness='0' />
          
            <chart_type>
              <string>column</string>
              <string>line</string>
              <string>line</string>
              <string>line</string>
            </chart_type>
            
            <series_color>
              <color>050222</color>
              <color>41A317</color>
              <color>FFF380</color>
              <color>F660AB</color>
            </series_color>
            <series_gap set_gap='40' bar_gap='-5' />
  
            <series_explode>
              <number>100</number>
            </series_explode>
            
          </chart>
      ) #'
  
      data
    end
  
end
