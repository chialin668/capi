require 'api_summary'
require 'star_result'
require 'star_test'
  
class DistrictController < ApplicationController

#  before_filter :authorize

  include GetParameter
  include Chart

  def initialize
    @app_base=app_base
    @app_name='DISTRICT'
    @title=''
    @tagline=''
    @theme='aqualicious'
    @state_name='California'
  end
  
  #####################################
  def summary
    get_parameters
    set_title "#{@district_name} School District", "#{@county_name} County, CA"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end


  ########################################################################
  def api_score
    get_parameters
    set_title "#{@district_name} School District", "#{@county_name} County, CA"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end

  def api_score_xml

    parse_xml_params

#    rec=ApiGrowth.find_by_school_type_and_year_and_district_code_and_county_code(@school_type, @year, @district_code, @county_code)
    
    # find API records for district, county, and state
    records = ApiSummary.find(:all,
                :conditions => ["school_type = :school_type and district_code= :district_code", 
                                {:school_type => @school_type, :district_code => @district_code}],
                :order =>"year"
                ) 
    
    # generate XML string
    xml= "<chart_data>\n"
    year_xml= "<row>\n" + "<null />\n"
    district_xml= "<row>\n" + "<string>#{@district_name} School District</string>\n"

    number_array=[]
    for record in records
      year_xml += "<string>#{record.year}</string>\n"
      district_xml += "<number>#{record.district_api}</number>\n"
      number_array << (record.district_api ? record.district_api : 0)
    end
    
    year_xml += "</row>\n"
    district_xml += "</row>\n"

    xml += year_xml
    xml += district_xml
    xml += "</chart_data>\n"

    min = (number_array.min and number_array.min >0) ? number_array.min-5 : 0
    max = number_array.max ? number_array.max+5 : 1000

    render_text line_data(xml, min, max)

  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end


  ########################################################################
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

#    rec=ApiGrowth.find_by_school_type_and_year_and_district_code_and_county_code(@school_type, @year, @district_code, @county_code)
    
    # find API records for district, county, and state
    records = ApiSummary.find(:all,
                :conditions => ["school_type = :school_type and district_code= :district_code", 
                                {:school_type => @school_type, :district_code => @district_code}],
                :order =>"year"
                ) 
    
    # generate XML string
    xml= "<chart_data>\n"
    year_xml= "<row>\n" + "<null />\n"
    district_xml= "<row>\n" + "<string>#{@district_name} School District</string>\n"
    county_xml= "<row>\n" + "<string>#{@county_name} County</string>\n"
    state_xml= "<row>\n" + "<string>#{@state_name}</string>\n"

    number_array=[]
    for record in records
      year_xml += "<string>#{record.year}</string>\n"
      district_xml += "<number>#{record.district_api}</number>\n"
      county_xml += "<number>#{record.county_api}</number>\n"
      state_xml += "<number>#{record.state_api}</number>\n"
      number_array << (record.district_api ? record.district_api : 0)
    end
    
    year_xml += "</row>\n"
    district_xml += "</row>\n"
    county_xml += "</row>\n"
    state_xml += "</row>\n"

    xml += year_xml
    xml += district_xml
    xml += county_xml
    xml += state_xml
    xml += "</chart_data>\n"

    min = (number_array.min and number_array.min >0) ? number_array.min-200 : 0
    max = number_array.max ? number_array.max+50 : 1000

    render_text line_data(xml, min, max)

  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end


  #####################################
  def api_school_in_district
    get_parameters
    set_title "#{@district_name} School District", "#{@county_name} County, CA"
    render :partial => "#{@app_name.downcase}/form_school_in_district"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end

  def api_school_in_district_xml

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
    district_xml= "<row>\n" + "<string>#{@district_name} School District</string>\n"
    school_xml= "<row>\n" + "<string>#{@school_name} School</string>\n"
    county_xml= "<row>\n" + "<string>#{@county_name} County</string>\n"
    state_xml= "<row>\n" + "<string>#{@state_name}</string>\n"

    for record in records
=begin    
      number_array=[]

      # find max and min
      number_array << (school_hash[record.year.to_s] ? school_hash[record.year.to_s] : 0)
      number_array << (record.district_api ? record.district_api : 0)
      number_array << (record.county_api ? record.county_api : 0)
      number_array << (record.state_api ? record.state_api : 0)
=end
      year_xml += "<string>#{record.year}</string>\n"
      district_xml += "<number>#{record.district_api}</number>\n"
      school_xml += "<number>#{school_hash[record.year.to_s]}</number>\n"
      county_xml += "<number>#{record.county_api}</number>\n"
      state_xml += "<number>#{record.state_api}</number>\n"
    end
    
    year_xml += "</row>\n"
    district_xml += "</row>\n"
    school_xml += "</row>\n"
    county_xml += "</row>\n"
    state_xml += "</row>\n"
    
    xml += year_xml
    xml += district_xml
    xml += school_xml
    xml += county_xml
    xml += state_xml
    xml += "</chart_data>\n"

#    min = (number_array.min and number_array.min >0) ? number_array.min-50 : 0
#    max = number_array.max ? number_array.max+50 : 1000

    render_text line_on_column({:xml=>xml, :explode=>true})

  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end

  #############################################
  def star_summary_mean
    get_parameters
    set_title "#{@district_name} School District", "#{@county_name} County, CA"
    render :partial => "templates/#{@theme}/form_mean"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end

  def mean_score_xml

    parse_xml_params

    district_hash=StarResult.mean_district_values(@test_id, @grade, @district_code, @county_code)
    county_hash=StarResult.mean_county_values(@test_id, @grade, @county_code)
    state_hash=StarResult.mean_state_values(@test_id, @grade)

    xml= "<chart_data>\n"
    year_xml= "<row>\n" + "<null />\n"
    district_xml= "<row>\n" + "<string>#{@district_name} School District</string>\n"
    county_xml= "<row>\n" + "<string>#{@county_name} County</string>\n"
    state_xml= "<row>\n" + "<string>#{@state_name}</string>\n"

    number_array=[]
    for record in state_hash.sort
      year=record[0]
      # find max and min
      number_array << (district_hash[year] ? district_hash[year] : 0)
      number_array << (county_hash[year] ? county_hash[year] : 0)
      number_array << (state_hash[year] ? state_hash[year] :0)

      year_xml += "<string>#{year}</string>\n"
      district_xml = district_xml + "<number>" + district_hash[year].to_s + "</number>\n"
      county_xml = county_xml + "<number>" + county_hash[year].to_s + "</number>\n"
      state_xml = state_xml + "<number>" + state_hash[year].to_s + "</number>\n"
    end

    year_xml += "</row>\n"
    state_xml += "</row>\n"
    county_xml += "</row>\n"
    district_xml += "</row>\n"
    
    xml += year_xml
    xml += district_xml
    xml += county_xml
    xml += state_xml
    xml += "</chart_data>\n"

    min = (number_array.min and number_array.min >0) ? number_array.min-50 : 0
    max = number_array.max ? number_array.max+20 : 1000

    render_text line_on_column({:xml=>xml, :min=>min, :max=>max})

  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end


  #############################################
  def star_summary_pac
    get_parameters
    set_title "#{@district_name} School District", "#{@county_name} County, CA"
    render :partial => "templates/#{@theme}/form_pac"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end

  def pac_value_xml
    
    parse_xml_params

#    records=StarResult.pac_values(@test_id, @grade, @school_code, @district_code, @county_code)
    records=StarResult.pac_values(@test_id, @grade, 0, @district_code, @county_code)

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
  def star_summary_pct
    get_parameters
    set_title "#{@school_name} School", "#{@district_name}, #{@county_name} County, CA"
    render :partial => "templates/#{@theme}/form_pct"
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    redirect_to :controller=>'api', :action=>'index'
  end
  
  def pct_value_xml

    parse_xml_params

#    records=StarResult.pct_values(@test_id, @grade, @school_code, @district_code, @county_code)
    records=StarResult.pct_values(@test_id, @grade, 0, @district_code, @county_code)
    
    xml= "<chart_data>\n"
    year_xml= "<row>\n" + "<null />\n"
    advanced_xml= "<row>\n" + "<string>Advanced</string>\n"
    proficient_xml= "<row>\n" + "<string>Proficient</string>\n"
    basic_xml= "<row>\n" + "<string>Basic</string>\n"
    below_basic_xml= "<row>\n" + "<string>Below Basic</string>\n"
    far_below_basic_xml= "<row>\n" + "<string>Far Below Basic</string>\n"
    
    for record in records
      year_xml += "<string>#{record.year}</string>\n"
      advanced_xml += "<number>#{record.cst_pct_advanced}</number>\n"
      proficient_xml += "<number>#{record.cst_pct_proficient}</number>\n"
      basic_xml += "<number>#{record.cst_pct_basic}</number>\n"
      below_basic_xml += "<number>#{record.cst_pct_below_basic}</number>\n"
      far_below_basic_xml += "<number>#{record.cst_pct_far_below_basic}</number>\n"
    end
    
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

  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end


end
