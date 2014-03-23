class SummaryController < ApplicationController

  include GetParameter
  include Chart

  
  def initialize
    @app_base=app_base
    @app_name='SUMMARY'
    @title='Summary'
    @tagline='iFanSee.com'
    @theme='aqualicious'
  end

  def get_parameters_tru
    @html_type = params[:html_type]
    @state = params[:state]
    @type = params[:type]
    @name = params[:name]
    @tru_type = params[:tru_type]
    @growth = params[:growth]
  end

  def parse_xml_params_tru
    xml_params=params[:xml_params]
    parameters=xml_params.split('|')
    for parameter in parameters
      data=parameter.split('=')
      @html_type=data[1] if data[0]=='html_type'
      @state=data[1] if data[0]=='state'
      @type=data[1] if data[0]=='type'
      @name=data[1] if data[0]=='name'
      @growth=data[1] if data[0]=='growth'
      @tru_type=data[1] if data[0]=='tru_type'
    end  
  end


  def index
    # http://localhost:3000/summary/state?type=state&name=CA&tru_type=listed&growth=yes
    # http://localhost:3000/summary?state=WA
    get_parameters_tru
    
    puts @state
  end
  
  def state
    get_parameters_tru
  end


  def generate_xml_listed
    records = TruSummary.get_stats(@type, @name, 'num_listed')

    # cord-x
    xml = "<chart_data>\n"
    xml += "<row>\n"
    xml += "<null />\n"
    for record in records
      xml += "<string>#{record.month}</string>\n"
    end
    xml += "</row>\n"
    
    # values
    number_array=[]
    xml += "<row>\n"
    xml += "<string>Number listed (year #{current_year})</string>\n"

    if @growth=='true'
      growths = []
      0.upto(records.size-1) do |i| 
        if i==0
           growths << 0.0
        else
          diff=records[i].value.to_i - records[i-1].value.to_i
          growths << diff/records[i].value.to_f*100
        end
      end

      for growth in growths
        xml += "<number>#{growth}</number>\n"
        number_array << growth
      end

      xml += "</row>\n"
      xml += "</chart_data>\n"
  
      max = number_array.max*1.1
      min = number_array.min*1.1

      render_text column_tru(xml, min, max)
    else  
      for record in records
        xml += "<number>#{record.value}</number>\n"
        number_array << record.value.to_i
      end

      xml += "</row>\n"
      xml += "</chart_data>\n"
  
      margin_l = number_array.max/30
      margin_h = number_array.max/50
      min = (number_array.min and number_array.min >0) ? number_array.min-margin_l : 0
      max = number_array.max ? number_array.max+margin_h : 1000


      render_text line_data_tru(xml, min, max)
#      render_text line_on_column_tru(xml, min, max)
    end
  end

  def generate_xml_median
    records = TruSummary.get_stats(@type, @name, 'median_price')

    # cord-x
    xml = "<chart_data>\n"
    xml += "<row>\n"
    xml += "<null />\n"
    for record in records
      xml += "<string>#{record.month}</string>\n"
    end
    xml += "</row>\n"
    
    # values
    number_array=[]
    xml += "<row>\n"
    xml += "<string>Median Price (year #{current_year})</string>\n"

    if @growth=='true'
      growths = []
      0.upto(records.size-1) do |i| 
        if i==0
           growths << 0.0
        else
          diff=records[i].value.to_i - records[i-1].value.to_i
          growths << diff/records[i].value.to_f*100
        end
      end

      for growth in growths
        xml += "<number>#{growth}</number>\n"
        number_array << growth
      end

      xml += "</row>\n"
      xml += "</chart_data>\n"
  
      max = number_array.max*1.1
      min = number_array.min*1.1

      render_text column_tru(xml, min, max)
    else  
      for record in records
        xml += "<number>#{record.value}</number>\n"
        number_array << record.value.to_i
      end

      xml += "</row>\n"
      xml += "</chart_data>\n"
  
      margin_l = number_array.max/30
      margin_h = number_array.max/50
      min = (number_array.min and number_array.min >0) ? number_array.min-margin_l : 0
      max = number_array.max ? number_array.max+margin_h : 1000

      render_text line_data_tru(xml, min, max)
    end
  end


  def generate_xml_average
    records = TruSummary.get_stats(@type, @name, 'average_price')

    # cord-x
    xml = "<chart_data>\n"
    xml += "<row>\n"
    xml += "<null />\n"
    for record in records
      xml += "<string>#{record.month}</string>\n"
    end
    xml += "</row>\n"
    
    # values
    number_array=[]
    xml += "<row>\n"
    xml += "<string>Average Price (year #{current_year})</string>\n"

    if @growth=='true'
      growths = []
      0.upto(records.size-1) do |i| 
        if i==0
           growths << 0.0
        else
          diff=records[i].value.to_i - records[i-1].value.to_i
          growths << diff/records[i].value.to_f*100
        end
      end

      for growth in growths
        xml += "<number>#{growth}</number>\n"
        number_array << growth
      end

      xml += "</row>\n"
      xml += "</chart_data>\n"
  
      max = number_array.max*1.1
      min = number_array.min*1.1

      render_text column_tru(xml, min, max)
    else  
      for record in records
        xml += "<number>#{record.value}</number>\n"
        number_array << record.value.to_i
      end

      xml += "</row>\n"
      xml += "</chart_data>\n"
  
      margin_l = number_array.max/30
      margin_h = number_array.max/50
      min = (number_array.min and number_array.min >0) ? number_array.min-margin_l : 0
      max = number_array.max ? number_array.max+margin_h : 1000

      render_text line_data_tru(xml, min, max)
    end
  end


  def state_xml
    parse_xml_params_tru
    generate_xml_listed if @tru_type=='listed'
    generate_xml_median if @tru_type=='median'
    generate_xml_average if @tru_type=='average'
  end

  def county
    # http://localhost:3000/summary/state?type=state&name=CA&tru_type=listed&growth=yes
    get_parameters_tru
  end
  
  def county_xml
    parse_xml_params_tru
    generate_xml_listed if @tru_type=='listed'
    generate_xml_median if @tru_type=='median'
    generate_xml_average if @tru_type=='average'
  end

  def city
    get_parameters_tru
  end

  def city_xml
    parse_xml_params_tru
    generate_xml_listed if @tru_type=='listed'
    generate_xml_median if @tru_type=='median'
    generate_xml_average if @tru_type=='average'
  end


end
