require 'api_summary'
require 'api_result'
require 'star_result'
require 'star_category'
require 'star_test'


class SchoolController < ApplicationController
  
#  before_filter :authorize

  include GetParameter
  include Chart

  def initialize
    @app_base=app_base
    @app_name='SCHOOL'
    @title=''
    @tagline=''
    @theme='aqualicious'
    @state_name='California'
    @current_year=current_year
    @year=@current_year
  end

  #############################################
  
  def star_distribution
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    render :partial => "templates/#{@theme}/form_distribution"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end

  def distribution_value_xml

    parse_xml_params

    records=StarResult.distribution_values(@grade, @year, @school_code, @district_code, @county_code)

    xml= "<chart_data>\n"
    xml += "<row>\n"
    xml += "<null/>\n"
    for record in records
      xml += "<string>#{record.test_name.gsub(/ /, '\r')}</string>\n"
    end
    xml += "</row>\n"

    xml += "<row>\n"
    xml += "<string>#{@year}</string>\n"
    
    number_array=[]
    for record in records
          number_array << record.mean_scaled_score.to_i if record.mean_scaled_score
      xml += "<number>#{record.mean_scaled_score}</number>\n"
    end
    xml += "</row>\n"
    
    xml += "</chart_data>\n"
    
    min = (number_array.min and number_array.min >0) ? number_array.min-50 : 0
    max = number_array.max ? number_array.max+10 : 1000

    render_text polar_1(xml, min, max)

  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end
  
  
  #############################################
  def star_summary_pct
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    render :partial => "templates/#{@theme}/form_pct"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end
  
  def pct_value_xml

    parse_xml_params

    records=StarResult.pct_values(@test_id, @grade, @school_code, @district_code, @county_code)

    xml= "<chart_data>\n"
    year_xml= "<row>\n" + "<null />\n"
    advanced_xml= "<row>\n" + "<string>Advanced</string>\n"
    proficient_xml= "<row>\n" + "<string>Proficient</string>\n"
    basic_xml= "<row>\n" + "<string>Basic</string>\n"
    below_basic_xml= "<row>\n" + "<string>Below Basic</string>\n"
    far_below_basic_xml= "<row>\n" + "<string>Far Below Basic</string>\n"

    year2score={}
    2004.upto(@current_year.to_i) do |year|
      year2score[year] = {'cst_pct_advanced'=>'0', 'cst_pct_proficient'=>'0', 'cst_pct_basic'=>'0',
                                'cst_pct_below_basic'=>'0', 'cst_pct_far_below_basic'=>'0'}
    end
    
    for record in records
      h=year2score[record.year]
      h['cst_pct_advanced']=record.send('cst_pct_advanced')
      h['cst_pct_proficient']=record.send('cst_pct_proficient')
      h['cst_pct_basic']=record.send('cst_pct_basic')
      h['cst_pct_below_basic']=record.send('cst_pct_below_basic')
      h['cst_pct_far_below_basic']=record.send('cst_pct_far_below_basic')
    end

    years=year2score.keys.sort
    for year in years
      h=year2score[year]
      year_xml += "<string>#{year}</string>\n"
      advanced_xml += "<number>#{h['cst_pct_advanced']}</number>\n"
      proficient_xml += "<number>#{h['cst_pct_proficient']}</number>\n"
      basic_xml += "<number>#{h['cst_pct_basic']}</number>\n"
      below_basic_xml += "<number>#{h['cst_pct_below_basic']}</number>\n"
      far_below_basic_xml += "<number>#{h['cst_pct_far_below_basic']}</number>\n"
    end
    
=begin    
    for record in records
      year_xml += "<string>#{record.year}</string>\n"
      advanced_xml += "<number>#{record.cst_pct_advanced}</number>\n"
      proficient_xml += "<number>#{record.cst_pct_proficient}</number>\n"
      basic_xml += "<number>#{record.cst_pct_basic}</number>\n"
      below_basic_xml += "<number>#{record.cst_pct_below_basic}</number>\n"
      far_below_basic_xml += "<number>#{record.cst_pct_far_below_basic}</number>\n"
    end
=end
    
    year_xml += "</row>\n"
    advanced_xml += "</row>\n"
    proficient_xml += "</row>\n"
    basic_xml += "</row>\n"
    below_basic_xml += "</row>\n"
    far_below_basic_xml += "</row>\n"
    
    xml += year_xml
    xml += advanced_xml
    xml += proficient_xml
    xml += basic_xml
    xml += below_basic_xml
    xml += far_below_basic_xml
    xml += "</chart_data>\n"

    render_text staked_column_1(xml)
#    render_text staked_area(xml)
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end
  
  #############################################
  def star_summary_pac
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    render :partial => "templates/#{@theme}/form_pac"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end

  def pac_value_xml
    
    parse_xml_params

    records=StarResult.pac_values(@test_id, @grade, @school_code, @district_code, @county_code)

    xml= "<chart_data>\n"
    year_xml= "<row>\n" + "<null />\n"
    pac75_xml= "<row>\n" + "<string>pac75</string>\n"
    pac50_xml= "<row>\n" + "<string>pac50</string>\n"
    pac25_xml= "<row>\n" + "<string>pac25</string>\n"
    
    for record in records
      year_xml += "<string>#{record.year}</string>\n"
      pac75_xml += "<number>#{record.pac75}</number>\n"
      pac50_xml += "<number>#{record.pac50}</number>\n"
      pac25_xml += "<number>#{record.pac25}</number>\n"
    end
    
    year_xml += "</row>\n"
    pac75_xml += "</row>\n"
    pac50_xml += "</row>\n"
    pac25_xml += "</row>\n"
    
    xml += year_xml
    xml += pac75_xml
    xml += pac50_xml
    xml += pac25_xml
    xml += "</chart_data>\n"
    
    render_text area_1(xml)
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end
  
  #############################################
  def star_summary_mean
    get_parameters
    set_title "#{@school_name} School", "#{@district_name}, #{@county_name} County, CA"
    render :partial => "templates/#{@theme}/form_mean"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end

  def mean_score_xml

    parse_xml_params

    school_hash=StarResult.mean_school_values(@test_id, @grade, @school_code)
    district_hash=StarResult.mean_district_values(@test_id, @grade, @district_code, @county_code)
    county_hash=StarResult.mean_county_values(@test_id, @grade, @county_code)
    state_hash=StarResult.mean_state_values(@test_id, @grade)

    xml= "<chart_data>\n"
    year_xml= "<row>\n" + "<null />\n"
    school_xml= "<row>\n" + "<string>#{@school_name} School</string>\n"
    district_xml= "<row>\n" + "<string>#{@district_name} School District</string>\n"
    county_xml= "<row>\n" + "<string>#{@county_name} County</string>\n"
    state_xml= "<row>\n" + "<string>State of California</string>\n"

    number_array=[]
    for record in state_hash.sort
      year=record[0]
      # find max and min
      number_array << (school_hash[year] ? school_hash[year] : 0)
      number_array << (district_hash[year] ? district_hash[year] : 0)
      number_array << (county_hash[year] ? county_hash[year] : 0)
      number_array << (state_hash[year] ? state_hash[year] :0)

      year_xml += "<string>#{year}</string>\n"
      school_xml += "<number>#{school_hash[year].to_s}</number>\n"
      district_xml = district_xml + "<number>" + district_hash[year].to_s + "</number>\n"
      county_xml = county_xml + "<number>" + county_hash[year].to_s + "</number>\n"
      state_xml = state_xml + "<number>" + state_hash[year].to_s + "</number>\n"
    end

    year_xml += "</row>\n"
    school_xml += "</row>\n"
    state_xml += "</row>\n"
    county_xml += "</row>\n"
    district_xml += "</row>\n"
    
    xml += year_xml
    xml += school_xml
    xml += district_xml
    xml += county_xml
    xml += state_xml
    xml += "</chart_data>\n"

    min = (number_array.min and number_array.min >0) ? number_array.min-50 : 0
    max = number_array.max ? number_array.max+10 : 1000

    render_text line_on_column({:xml=>xml, :min=>min, :max=>max})
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end


  ################################
  def api_score
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    
    @cds= "%02d%05d%07d" % [@county_code, @district_code, 0]
    
    # used by similar school
    records=ApiGrowth.get_api_score(@school_code)
    for record in records
      @api_score = record.api_score
    end
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end

  def api_score_xml

    parse_xml_params
    
    records=ApiGrowth.get_api_score(@school_code)
        
    xml= "<chart_data>\n"
    year_xml= "<row>\n" + "<null />\n"
    school_xml= "<row>\n" + "<string>#{@school_name}</string>\n"

    number_array=[]
    for record in records
      year_xml += "<string>#{record.year}</string>\n"
      school_xml += "<number>#{record.api_score}</number>\n"
      number_array << (record.api_score ? record.api_score : 0)
    end
    
    year_xml += "</row>\n"
    school_xml += "</row>\n"
    xml += year_xml
    xml += school_xml
    xml += "</chart_data>\n"

    min = (number_array.min and number_array.min >0) ? number_array.min-5 : 0
    max = number_array.max ? number_array.max+5 : 1000

    render_text line_data(xml, min, max)

  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end

  ################################
  def api_all_scores
    get_parameters
    set_title "#{@district_name} School District", "#{@county_name} County, CA"

  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end

  def api_all_scores_xml

    parse_xml_params

    # find API record for school
    school_hash={}
    records=ApiGrowth.find_all_by_school_code(@school_code)    
    records.each { |record| school_hash[record.year]=record.api_score }

    # find API records for district, county, and state
    records = ApiSummary.find(:all,
                              :conditions => ["school_type = :school_type and district_code= :district_code", 
                                {:school_type => @school_type, :district_code => @district_code}],
                              :order =>"year"
                        ) 
    
    # generate XML string
    xml= "<chart_data>\n"
    year_xml= "<row>\n" + "<null />\n"
    school_xml= "<row>\n" + "<string>#{@school_name} School</string>\n"
    district_xml= "<row>\n" + "<string>#{@district_name} School District</string>\n"
    county_xml= "<row>\n" + "<string>#{@county_name} County</string>\n"
    state_xml= "<row>\n" + "<string>#{@state_name}</string>\n"

    number_array=[]
    for record in records
      # find max and min
      number_array << (school_hash[record.year.to_s] ? school_hash[record.year.to_s] : 0)
      number_array << (record.district_api ? record.district_api : 0)
      number_array << (record.county_api ? record.county_api : 0)
      number_array << (record.state_api ? record.state_api : 0)

      year_xml += "<string>#{record.year}</string>\n"
      school_xml += "<number>#{school_hash[record.year.to_s]}</number>\n"
      district_xml += "<number>#{record.district_api}</number>\n"
      county_xml += "<number>#{record.county_api}</number>\n"
      state_xml += "<number>#{record.state_api}</number>\n"
    end
    
    year_xml += "</row>\n"
    school_xml += "</row>\n"
    district_xml += "</row>\n"
    county_xml += "</row>\n"
    state_xml += "</row>\n"
    
    xml += year_xml
    xml += school_xml
    xml += district_xml
    xml += county_xml
    xml += state_xml
    xml += "</chart_data>\n"

    min = (number_array.min and number_array.min >0) ? number_array.min-50 : 0
    max = number_array.max ? number_array.max+50 : 1000

#    render_text line_data({:xml=>xml, :min=>min, :max=>max, :explode=>true})
    render_text line_data(xml, min, max)
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end

  ################################
  def api_rank
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"

    @year_hash={}    
    @current_year.to_i.downto(2001) do |year|
      @year_hash[year.to_s]={}
    end
    
    records=ApiGrowth.find_school_ranks(@school_code)  
    for record in records
      h={}
      h[:state_rank]=record.state_rank
      h[:county_rank]=record.county_rank
      h[:district_rank]=record.district_rank
      @year_hash[record.year]=h
    end

    records=ApiGrowth.find_school_counts(@school_type)
    for record in records
      h=@year_hash[record.year]
      h[:state_count]=record.count ? record.count : 0
    end
    
    records=ApiGrowth.find_county_school_counts(@school_type, @county_code)
    for record in records
      h=@year_hash[record.year]
      h[:county_count]=record.count ? record.count : 0
    end
    
    records=ApiGrowth.find_district_school_counts(@school_type, @district_code)
    for record in records
      h=@year_hash[record.year]
      h[:district_count]=record.count ? record.count : 0
    end

  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'        
  end

  #############################################
  def api_by_race
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    render :partial => "form_by_race"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end
  
  def api_by_race_xml
    parse_xml_params
    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]

    xml = "<chart_data>\n"
    xml += "<row>\n"
      xml += "<null/>\n"
      xml += "<string></string>\n"
    xml += "</row>\n"

    number_array=[]
    records=ApiResult.api_by_race(@year, cds)
    for record in records 
      number_array << record.aa.to_i if record.aa.to_i
      number_array << record.ai.to_i if record.ai.to_i
      number_array << record.as.to_i if record.as.to_i
      number_array << record.fi.to_i if record.fi.to_i
      number_array << record.hi.to_i if record.hi.to_i
      number_array << record.pi.to_i if record.pi.to_i
      number_array << record.wh.to_i if record.wh.to_i

      xml += "<row>\n"
        xml += "<string>African American</string>\n"
        xml += "<number>#{record.aa.to_i}</number>\n"
      xml += "</row>\n"

      xml += "<row>\n"
        xml += "<string>American Indian</string>\n"
        xml += "<number>#{record.ai.to_i}</number>\n"
      xml += "</row>\n"

      xml += "<row>\n"
        xml += "<string>Asian</string>\n"
        xml += "<number>#{record.as.to_i}</number>\n"
      xml += "</row>\n"
    
      xml += "<row>\n"
        xml += "<string>Filipino</string>\n"
        xml += "<number>#{record.fi.to_i}</number>\n"
      xml += "</row>\n"
    
      xml += "<row>\n"
        xml += "<string>Hispanic or Latino</string>\n"
        xml += "<number>#{record.hi.to_i}</number>\n"
      xml += "</row>\n"
    
      xml += "<row>\n"
        xml += "<string>Pacific Islander</string>\n"
        xml += "<number>#{record.pi.to_i}</number>\n"
      xml += "</row>\n"
    
      xml += "<row>\n"
        xml += "<string>White</string>\n"
        xml += "<number>#{record.wh.to_i}</number>\n"
      xml += "</row>\n"
    end
              
    xml += "</chart_data>\n"

    min = (number_array.min and number_array.min >0) ? number_array.min-20 : 0
    max = number_array.max ? number_array.max+50 : 1000

    render_text column(xml, min, max)
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end
  
  #############################################
  def avg_class_size
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    render :partial => "form_avg_class_size"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end
  
  def avg_class_size_xml
    parse_xml_params
    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]

    xml = "<chart_data>\n"
    xml += "<row>\n"
      xml += "<null/>\n"
      xml += "<string></string>\n"
    xml += "</row>\n"

    number_array=[]
    records=ApiResult.avg_class_size(@year, cds)
    for record in records 
      number_array << record.acs_k3.to_i if record.acs_k3.to_i 
      number_array << record.acs_46.to_i if record.acs_46.to_i
      number_array << record.acs_core.to_i if record.acs_core.to_i

      if @school_type=='E' 
        xml += "<row>\n"
          xml += "<string>Grade: K~3</string>\n"
          xml += "<number>#{record.acs_k3.to_i}</number>\n"
        xml += "</row>\n"
      end
  
      if @school_type=='E' or @school_type=='M' 
        xml += "<row>\n"
          xml += "<string>Grade: 4~6</string>\n"
          xml += "<number>#{record.acs_46.to_i}</number>\n"
        xml += "</row>\n"
      end

      if @school_type=='M' or @school_type=='H'
        xml += "<row>\n"
          xml += "<string>Core Academic Courses</string>\n"
          xml += "<number>#{record.acs_core.to_i}</number>\n"
        xml += "</row>\n"
      end
    end
              
    xml += "</chart_data>\n"

    max = number_array.max ? number_array.max+10 : 100

    render_text column(xml, 0, max)
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end
  
  #############################################
  def pct_enrollment
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    render :partial => "form_pct_enrollment"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end
  
  def pct_enrollment_xml
    parse_xml_params
    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]
    @year=@current_year if @year.to_i < 2005

    xml = "<chart_data>\n"
    xml += "<row>\n"
      xml += "<null/>\n"
      xml += "<string></string>\n"
    xml += "</row>\n"

#      select pen_2, pen_35, pen_6, pen_78, pen_911

=begin
    number_array=[]
    records=ApiResult.pct_enrollment(@year, cds)
    for record in records 
      number_array << record.pen_2.to_i
      number_array << record.pen_35.to_i
      number_array << record.pen_6.to_i
      number_array << record.pen_78.to_i
      number_array << record.pen_911.to_i


      if @school_type=='E' 
        xml += "<row>\n"
          xml += "<string>Grade: 2</string>\n"
          xml += "<number>#{record.pen_2.to_i}</number>\n"
        xml += "</row>\n"

        xml += "<row>\n"
          xml += "<string>Grade: 3~5</string>\n"
          xml += "<number>#{record.pen_35.to_i}</number>\n"
        xml += "</row>\n"
      end

      if @school_type=='E' or @school_type=='M'
        xml += "<row>\n"
          xml += "<string>Grade: 6</string>\n"
          xml += "<number>#{record.pen_6.to_i}</number>\n"
        xml += "</row>\n"
      end

      if @school_type=='M'
        xml += "<row>\n"
          xml += "<string>Grade: 7~8</string>\n"
          xml += "<number>#{record.pen_78.to_i}</number>\n"
        xml += "</row>\n"
      end

      if @school_type=='H'
        xml += "<row>\n"
          xml += "<string>Grade: 9~11</string>\n"
          xml += "<number>#{record.pen_911.to_i}</number>\n"
        xml += "</row>\n"
      end
    end
              
    xml += "</chart_data>\n"
=end
#    render_text column(xml, nil, number_array.max+10)


    total=0
    xml = "<chart_data>\n"
    xml += "<row>\n"
    xml += "<null/>\n"
    xml += "<string>Grade 2</string>\n" if @school_type=='E' 
    xml += "<string>Grade 3~5</string>\n" if @school_type=='E' 
    xml += "<string>Grade 6</string>\n" if @school_type=='E' or @school_type=='M'
    xml += "<string>Grade 7~8</string>\n" if @school_type=='M'if @school_type=='M'
    xml += "<string>Grade 9~11</string>\n" if @school_type=='H'
    xml += "<string>Not Enrolled</string>\n"
    xml += "</row>\n"
    xml += "<row>\n"
    xml += "<string></string>\n"

    records=ApiResult.pct_enrollment(@year, cds)
    for record in records 
      xml += "<number>#{record.pen_2.to_i}</number>\n" if @school_type=='E' 
      xml += "<number>#{record.pen_35.to_i}</number>\n" if @school_type=='E' 
      xml += "<number>#{record.pen_6.to_i}</number>\n" if @school_type=='E' or @school_type=='M'
      xml += "<number>#{record.pen_78.to_i}</number>\n" if @school_type=='M'if @school_type=='M'
      xml += "<number>#{record.pen_911.to_i}</number>\n" if @school_type=='H'
      
      total = total +
                record.pen_2.to_i + 
                record.pen_35.to_i + 
                record.pen_6.to_i + 
                record.pen_78.to_i + 
                record.pen_911.to_i
    end

    others = total==0 ? 0 : 100-total
    xml += "<number>" + others.to_s + "</number>\n"
              
    xml += "</row>\n"
    xml += "</chart_data>\n"

    render_text three_d_pie(xml)

  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end
  
  #############################################
  def vcst
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    render :partial => "form_vcst"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end
  
  def vcst_xml
    parse_xml_params
    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]

    xml = "<chart_data>\n"
    xml += "<row>\n"
      xml += "<null/>\n"
      xml += "<string></string>\n"
    xml += "</row>\n"

    number_array=[]
    records=ApiResult.by_vcst(@year, @school_type, cds) 
    for record in records 
      number_array << record.e.to_i if record.e.to_i
      number_array << record.m.to_i if record.m.to_i
      number_array << record.s.to_i if record.s.to_i
      number_array << record.h.to_i if record.h.to_i

      xml += "<row>\n"
        xml += "<string>English-Language Arts</string>\n"
        xml += "<number>#{record.e.to_i}</number>\n"
      xml += "</row>\n"

      xml += "<row>\n"
        xml += "<string>Mathematics</string>\n"
        xml += "<number>#{record.m.to_i}</number>\n"
      xml += "</row>\n"

      xml += "<row>\n"
        xml += "<string>Science</string>\n"
        xml += "<number>#{record.s.to_i}</number>\n"
      xml += "</row>\n"

      xml += "<row>\n"
        xml += "<string>History-Social Science</string>\n"
        xml += "<number>#{record.h.to_i}</number>\n"
      xml += "</row>\n"

      # for high school only (also after 2007)
      if @school_type=='H' and @year.to_i >= 2007
        number_array << record.ls.to_i if record.ls.to_i

        xml += "<row>\n"
          xml += "<string>Life Science</string>\n"
          xml += "<number>#{record.ls.to_i}</number>\n"
        xml += "</row>\n"
      end
    
    end
              
    xml += "</chart_data>\n"

    max = number_array.max ? number_array.max+50 : 1000

    render_text column(xml, 0, max)
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end
  
  #############################################
  def pcst
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    render :partial => "form_pcst"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end
  
  def pcst_xml
    
    parse_xml_params
    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]
    @year=@current_year if @year.to_i < 2005
    
    xml = "<chart_data>\n"
    xml += "<row>\n"
      xml += "<null/>\n"
      xml += "<string></string>\n"
    xml += "</row>\n"


    number_array=[]
    
    if @test_name=='CST' 
      
      records=ApiResult.vcst(@year, @school_type, cds) if @score_type=='VALID'
      records=ApiResult.pcst(@year, @school_type, cds) if @score_type=='PRODUCT'

      for record in records 
        number_array << record.e.to_i if record.e.to_i
        number_array << record.m.to_i if record.m.to_i
        number_array << record.s.to_i if record.s.to_i
        number_array << record.h.to_i if record.h.to_i
  
        xml += "<row>\n"
          xml += "<string>English-Language Arts</string>\n"
          xml += "<number>#{record.e.to_i}</number>\n"
        xml += "</row>\n"
  
        xml += "<row>\n"
          xml += "<string>Mathematics</string>\n"
          xml += "<number>#{record.m.to_i}</number>\n"
        xml += "</row>\n"
  
        xml += "<row>\n"
          xml += "<string>Science</string>\n"
          xml += "<number>#{record.s.to_i}</number>\n"
        xml += "</row>\n"
  
        xml += "<row>\n"
          xml += "<string>History-Social Science</string>\n"
          xml += "<number>#{record.h.to_i}</number>\n"
        xml += "</row>\n"
  
        # for grade 10 only (also after 2007)
        if @school_type=='H' and @year.to_i >= 2007
          number_array << record.ls.to_i if record.ls.to_i 
  
          xml += "<row>\n"
            xml += "<string>Life Science</string>\n"
            xml += "<number>#{record.ls.to_i}</number>\n"
          xml += "</row>\n"
        end
      
      end

    elsif @test_name=='NRT'

      records=ApiResult.vnrt(@year, cds) if @score_type=='VALID'
      records=ApiResult.pnrt(@year, cds) if @score_type=='PRODUCT'
    
      for record in records 
        number_array << record.r.to_i if record.r.to_i
        number_array << record.l.to_i if record.l.to_i
        number_array << record.s.to_i if record.s.to_i
        number_array << record.m.to_i if record.m.to_i
  
        xml += "<row>\n"
          xml += "<string>Reading</string>\n"
          xml += "<number>#{record.r.to_i}</number>\n"
        xml += "</row>\n"
  
        xml += "<row>\n"
          xml += "<string>Language</string>\n"
          xml += "<number>#{record.m.to_i}</number>\n"
        xml += "</row>\n"
  
        xml += "<row>\n"
          xml += "<string>Spelling</string>\n"
          xml += "<number>#{record.s.to_i}</number>\n"
        xml += "</row>\n"
  
        xml += "<row>\n"
          xml += "<string>Mathematics</string>\n"
          xml += "<number>#{record.m.to_i}</number>\n"
        xml += "</row>\n"
  
      end

    elsif @test_name=='CHS'

      records=ApiResult.vchs(@year, cds) if @score_type=='VALID'
      records=ApiResult.pchs(@year, cds) if @score_type=='PRODUCT'
    
      for record in records 
        number_array << record.e.to_i if record.e.to_i
        number_array << record.m.to_i if record.m.to_i
  
        xml += "<row>\n"
          xml += "<string>English-Language Arts</string>\n"
          xml += "<number>#{record.e.to_i}</number>\n"
        xml += "</row>\n"
  
        xml += "<row>\n"
          xml += "<string>Mathematics</string>\n"
          xml += "<number>#{record.m.to_i}</number>\n"
        xml += "</row>\n"
    
      end

    elsif @test_name=='M200'

      records=ApiResult.vm200(@year, cds) if @score_type=='VALID'
      records=ApiResult.pm200(@year, cds) if @score_type=='PRODUCT'
    
      for record in records 
        number_array << record.m228.to_i if record.m228.to_i
        number_array << record.m291.to_i if record.m291.to_i
        number_array << record.s291.to_i if record.s291.to_i
  
        xml += "<row>\n"
          xml += "<string>Mathematics 2~8</string>\n"
          xml += "<number>#{record.m228.to_i}</number>\n"
        xml += "</row>\n"
  
        xml += "<row>\n"
          xml += "<string>Mathematics 9~11</string>\n"
          xml += "<number>#{record.m291.to_i}</number>\n"
        xml += "</row>\n"
    
        xml += "<row>\n"
          xml += "<string>Science 9~11</string>\n"
          xml += "<number>#{record.s291.to_i}</number>\n"
        xml += "</row>\n"
      end

    end
              
    xml += "</chart_data>\n"

    max=    

    max = number_array.max ? number_array.max + (number_array.max*0.2).to_i : 1000

    render_text column(xml, 0, max)

  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end
  

  
  #############################################
  def race
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    render :partial => "form_race"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end

  def race_xml
    parse_xml_params

    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]

    total=0
    xml = "<chart_data>\n"
    xml += "<row>\n"
    xml += "<null/>\n"
    xml += "<string>African American</string>\n"
    xml += "<string>American Indian</string>\n"
    xml += "<string>Asian</string>\n"
    xml += "<string>Filipino</string>\n"
    xml += "<string>Hispanic or Latino</string>\n"
    xml += "<string>Pacific Islander</string>\n"
    xml += "<string>White</string>\n"
    xml += "<string>Others</string>\n"
    xml += "</row>\n"
    xml += "<row>\n"
    xml += "<string></string>\n"

    records=ApiResult.race(@year, cds)
    for record in records 
      xml += "<number>#{record.pct_aa.to_i}</number>\n"
      xml += "<number>#{record.pct_ai.to_i}</number>\n"
      xml += "<number>#{record.pct_as.to_i}</number>\n"
      xml += "<number>#{record.pct_fi.to_i}</number>\n"
      xml += "<number>#{record.pct_hi.to_i}</number>\n"
      xml += "<number>#{record.pct_pi.to_i}</number>\n"
      xml += "<number>#{record.pct_wh.to_i}</number>\n"
      
      total = total +
                record.pct_aa.to_i + 
                record.pct_ai.to_i +
                record.pct_as.to_i +
                record.pct_fi.to_i +
                record.pct_hi.to_i +
                record.pct_pi.to_i +
                record.pct_wh.to_i
    end

    others = total==0 ? 0 : 100-total
    xml += "<number>" + others.to_s + "</number>\n"
              
    xml += "</row>\n"
    xml += "</chart_data>\n"

    render_text three_d_pie(xml)
  
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end

  #############################################
  def teacher
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    render :partial => "form_teacher"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end

  def teacher_xml
    parse_xml_params

    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]

    total=0
    xml = "<chart_data>\n"
    xml += "<row>\n"
    xml += "<null/>\n"
    xml += "<string>Full Credentials</string>\n"
    xml += "<string>Emergency Cred.</string>\n"
    xml += "<string>Others</string>\n"
    xml += "</row>\n"
    xml += "<row>\n"
    xml += "<string></string>\n"

    records=ApiResult.teacher(@year, cds)
    for record in records 
      xml += "<number>#{record.full.to_i}</number>\n"
      xml += "<number>#{record.emer.to_i}</number>\n"
      
      total = total +
                record.full.to_i + 
                record.emer.to_i
    end

    others = total==0 ? 0 : 100-total
    xml += "<number>" + others.to_s + "</number>\n"
              
    xml += "</row>\n"
    xml += "</chart_data>\n"

    render_text three_d_pie(xml)
  
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end


  #############################################
  def parent_ed_level
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    
    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]
#    @records=ApiResult.parent_ed_level(@year, cds)
    render :partial => "form_parent_ed_level"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end
  
  def parent_ed_level_xml
    parse_xml_params
    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]
    
    total=0;
    xml = "<chart_data>\n"
    xml += "<row>\n"
    xml += "<null/>\n"
    xml += "<string>Not High School Graduate</string>\n"
    xml += "<string>High School Graduate</string>\n"
    xml += "<string>Some College</string>\n"
    xml += "<string>College Graduate</string>\n"
    xml += "<string>Graduate School</string>\n"
    xml += "<string>Unknown</string>\n"
    xml += "</row>\n"
    xml += "<row>\n"
    xml += "<string></string>\n"

    records=ApiResult.parent_ed_level(@year, cds)
    for record in records 

      xml += "<number>#{record.not_hsg.to_i*record.pct_resp.to_i/100}</number>\n"
      xml += "<number>#{record.hsg.to_i*record.pct_resp.to_i/100}</number>\n"
      xml += "<number>#{record.some_col.to_i*record.pct_resp.to_i/100}</number>\n"
      xml += "<number>#{record.col_grad.to_i*record.pct_resp.to_i/100}</number>\n"
      xml += "<number>#{record.grad_sch.to_i*record.pct_resp.to_i/100}</number>\n"

      total = total +
                record.not_hsg.to_i*record.pct_resp.to_i/100 +
                record.hsg.to_i*record.pct_resp.to_i/100 +
                record.some_col.to_i*record.pct_resp.to_i/100 +
                record.col_grad.to_i*record.pct_resp.to_i/100 +
                record.grad_sch.to_i*record.pct_resp.to_i/100
    end

    others = total==0 ? 0 : 100-total
    xml += "<number>" + others.to_s + "</number>\n"

    xml += "</row>\n"
    xml += "</chart_data>\n"

    render_text three_d_pie(xml)
  
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end
  
  
  #############################################
  def special_student
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    render :partial => "form_special_student"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end
  
  def special_student_xml
    parse_xml_params
    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]

    @year=@current_year if @year.to_i < 2006

    # Percentage of Students that are Participants in the Free or Reduced Price Meal Program
    # Percent of participants in Gifted and Talented education programs (STAR)
    # Percent of participants in migrant education programs (STAR)
    # Percent of participants who are designated as English Learners
    # Percent of Reclassified Fluent-English-Proficient (RFEP) students (STAR)
    # Percent of Students with Disabilities (STAR)
    total=0
    xml = "<chart_data>\n"
    xml += "<row>\n"
    xml += "<null/>\n"
    xml += "<string>Disabilities</string>\n"
    xml += "<string>English Learners</string>\n"
    xml += "<string>Free or Reduced Price Meal</string>\n"
    xml += "<string>Gifted and Talented</string>\n"
    xml += "<string>Migrant education</string>\n"
    xml += "<string>Reclassified Fluent-English-Proficient</string>\n"
    xml += "<string>Others</string>\n"
    xml += "</row>\n"
    xml += "<row>\n"
    xml += "<string></string>\n"

    records=ApiResult.special_student(@year, cds)
    for record in records 
      xml += "<number>#{record.p_di.to_i}</number>\n"
      xml += "<number>#{record.p_el.to_i}</number>\n"
      xml += "<number>#{record.meals.to_i}</number>\n"
      xml += "<number>#{record.p_gate.to_i}</number>\n"
      xml += "<number>#{record.p_miged.to_i}</number>\n"
      xml += "<number>#{record.p_rfep.to_i}</number>\n"
      total = total + 
              record.meals.to_i +
              record.p_gate.to_i + 
              record.p_miged.to_i +
              record.p_el.to_i + 
              record.p_rfep.to_i +
              record.p_di.to_i
    end

    others = total==0 ? 0 : 100-total
    xml += "<number>" + others.to_s + "</number>\n"
              
    xml += "</row>\n"
    xml += "</chart_data>\n"

    render_text three_d_pie(xml)
  
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end
  
  
  #############################################
  def api_detail
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]    
    
    @records=ApiResult.api_detail(@year, cds)
    render :partial => "form_api_detail"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end

  ############################
  def subgroup_detail_by_race
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]
    @records=ApiResult.sub_group_detail_by_race(@year, cds)
    render :partial => "form_subgroup_detail_by_race"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end
  

  ############################
  def subgroup_detail_other
    get_parameters
    set_title @school_name, "#{@district_name}, #{@county_name}, CA"
    cds= "%02d%05d%07d" % [@county_code, @district_code, @school_code]
    
    @year=@current_year if @year.to_i < 2006
    @records=ApiResult.sub_group_detail_other(@year, cds)

    render :partial => "form_subgroup_detail_other"

#    abc=ApiResult.ptotal(@year, cds)
#    for r in abc
#      puts r.tot_28
#      puts r.tot_91
#    end
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end
  
end
