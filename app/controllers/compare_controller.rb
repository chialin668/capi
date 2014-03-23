class CompareController < ApplicationController

#  before_filter :authorize

  include GetParameter
  include Chart

  def initialize
    @app_base=app_base
    @app_name='COMPARE'
    @title='Compare Schools'
    @tagline='iFanSee Search Engine'
    @theme='aqualicious'
    @mysql_row_limit=10
    @current_year=current_year
    @year=@current_year
  end
  
  def index
  end


  def get_school_info
    @schools=[]
    school_codes=session[:scode_list]
    for school_code in school_codes
      @schools << StarCategory.find_by_school_code(school_code)
    end
  end


  def add_code_to_session
    school_code = params[:school_code]
    @school_codes = session[:scode_list] 
    if @school_codes.include?(school_code)
      @school_codes.delete(school_code)
    else
      @school_codes << school_code
    end
  end

  def search
    # clean the session table for search
    session[:scode_list] =[] if not params[:page]
    #@schools=session[:scode_list]

    @school_type= params[:school_type]
    @query = params[:query]
    tmp_str=@query.gsub(/, /, ',')
    ferret_query="school_name:" + tmp_str.gsub(/,/, ' OR school_name:')
    
    @total, @records=FerretApiGrowth.full_text_search(
                                    "year:#{@year} AND school_type:#{@school_type} AND (#{ferret_query})" , 
                                    {:page => (params[:page]||1),
                                     :sort=>['school_name']})
    @pages = pages_for(@total)
    
  end

  def compare
    school_codes=params[:school] # got an array back
    if school_codes
      get_school_info
      @school_code=school_codes[0] # Just need a code
      @has_result=true  # used for sidebar
      @school_type=params[:school_type]

      @tagline=''
#      for school in @schools
#        @tagline += "#{school.school_name}/"
#      end
#      @tagline=@tagline.chop
    
      # ??? should have render/redirect rather than compare.rhtml???
      # or, change all others?
    else
      redirect_to :action=>'index' 
    end
  end
  
  #####################################
  def api_score
    get_parameters  
    get_school_info
  end

  def api_score_xml

    parse_xml_params

    xml= "<chart_data>\n"
    year_xml= "<row>\n" + "<null />\n"
    2001.upto(current_year.to_i) do |year|
      year_xml += "<string>#{year}</string>\n"
    end
    year_xml += "</row>\n"
    
    number_array=[]
    school_xml = ""
    school_codes=session[:scode_list]
    for school_code in school_codes
      school_xml += "<row>\n"      
      records=ApiGrowth.get_api_score(school_code)
      school_xml += "<string>#{records[records.size-1].school_name}</string>\n"
      year2score={}
      for record in records
        year2score[record.year.to_i]=record.api_score
        number_array << record.api_score if record.api_score
      end  
      
      2001.upto(current_year.to_i) do |year|
        if year2score.has_key?(year)
          school_xml += "<string>#{year2score[year]}</string>\n"
        else
          school_xml += "<string>0</string>\n"
        end
      end
      school_xml += "</row>\n"
    end
    
    xml += year_xml
    xml += school_xml
    xml += "</chart_data>\n"

    min = (number_array.min and number_array.min >0) ? number_array.min-20 : 0
    max = number_array.max ? number_array.max+20 : 1000

    render_text line_data(xml, min, max, false)

  end

  #####################################
  def api_rank
    get_parameters  
    get_school_info
    
    @header_rec=[]
    @data_rec=[]
    code2school={}
    school_codes=session[:scode_list]
    for school_code in school_codes
      records=ApiGrowth.find_school_ranks(school_code)    
      code2school[school_code]=records
    end

    # school name
    rec=['School']
    for school_code in code2school.keys 
      records = code2school[school_code]
      rec << records[0].school_name
    end 
    @header_rec << rec

    # District name
    rec=['District']
    for school_code in code2school.keys 
      records = code2school[school_code]
      rec << records[0].district_name
    end 
    @data_rec << rec

    # County name
    rec=['County']
    for school_code in code2school.keys 
      records = code2school[school_code]
      rec << records[0].county_name
    end 
    @data_rec << rec

    # API rank
    current_year.to_i.downto(2001) do |year|
      rec=[]
      rec << year
      for school_code in code2school.keys
        records=code2school[school_code]
        for r in records
              rec << r.state_rank if r.year.to_i==year
        end
      end
      @data_rec << rec
    end

  end
  

  ####################################
  def star_summary_mean
    get_parameters  
    get_school_info
    render :partial => 'form_mean'
  end

  def mean_score_xml
    parse_xml_params

    xml= "<chart_data>\n"
    school_xml= "<row>\n" + 
          "<null/>\n" + 
          "<string></string>\n" + 
          "</row>\n"


    number_array=[]
    school_codes=session[:scode_list]
    for school_code in school_codes
      school_xml += "<row>\n"
      school=StarCategory.find_by_school_code(school_code)
      school_xml += "<string>#{school.school_name}</string>\n" 

      record=StarResult.find_by_year_and_grade_and_test_id_and_school_code(@year, @grade, @test_id, school_code)
      score=record ? record.mean_scaled_score : 0
      school_xml += "<string>" + score.to_s + "</string>\n" 
      number_array << score if score
      school_xml += "</row>\n"
    end
    
    xml += school_xml
    xml += "</chart_data>\n"

    min = (number_array.min and number_array.min >0) ? number_array.min-20 : 0
    max = number_array.max ? number_array.max+20 : 1000

    render_text column(xml, min, max)

#    render_text line_on_column({:xml=>xml, :min=>min, :max=>max})
  end
  

  ####################################
  def star_summary_pct
    get_parameters  
    get_school_info
    render :partial => 'form_pct'
  end

  def pct_value_xml
    parse_xml_params

    xml= "<chart_data>\n"
    school_xml= "<row>\n" + 
          "<null/>\n" + 
          "<string></string>\n" + 
          "</row>\n"

    number_array=[]
    school_codes=session[:scode_list]
    for school_code in school_codes
      school_xml += "<row>\n"
      school=StarCategory.find_by_school_code(school_code)
      school_xml += "<string>#{school.school_name}</string>\n" 

      record=StarResult.find_by_year_and_grade_and_test_id_and_school_code(@year, @grade, @test_id, school_code)
      score=record ? (record.cst_pct_advanced+record.cst_pct_proficient) : 0
      school_xml += "<string>" + score.to_s + "</string>\n" 
      number_array << score if score
      school_xml += "</row>\n"
    end
    
    xml += school_xml
    xml += "</chart_data>\n"

#    min = (number_array.min and number_array.min >0) ? number_array.min-20 : 0
#    max = number_array.max ? number_array.max+20 : 1000

    render_text column(xml, 0, 100)

#    render_text line_on_column({:xml=>xml, :min=>min, :max=>max})
  end
  

  def star_summary_pac
    get_parameters  
    get_school_info
    render :partial => 'form_pac'
  end

  def pac_value_xml
    parse_xml_params

    xml= "<chart_data>\n"
    school_xml= "<row>\n" + 
          "<null/>\n" + 
          "<string></string>\n" + 
          "</row>\n"

    number_array=[]
    school_codes=session[:scode_list]
    for school_code in school_codes
      school_xml += "<row>\n"
      school=StarCategory.find_by_school_code(school_code)
      school_xml += "<string>#{school.school_name}</string>\n" 

      record=StarResult.find_by_year_and_grade_and_test_id_and_school_code(@year, @grade, @test_id, school_code)
      score=record ? (record.pac75) : 0
      school_xml += "<string>" + score.to_s + "</string>\n" 
      number_array << score if score
      school_xml += "</row>\n"
    end

    xml += school_xml
    xml += "</chart_data>\n"

    render_text column(xml, 0, 100)

  end

end


