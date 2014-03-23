module TruHelper

  def state_draw_markers(page) # also returns the sidebar html
    html = ''
    county_names = []
    
    for county in @counties
      html += "<a href='/tru/county?state_id=#{@state_id}&county_id=#{county.id}'>#{county.name}</a> <br />"
      #puts "#{county.id}: #{county.name}"
      county_names << "'#{county.name}'"
    end

    criteria_str = county_names.join(',')
    counties = TruCounty.get_county_info(@state_id, criteria_str)
    
    load_markers(@map)
    color2icons = init_color_icons(page)

    for county in counties
      icon = get_icon(color2icons, 0, 900)
      geopoints = {:lat => county.lat, :lng => county.lng}
      draw_marker(page, geopoints, icon, county.name, county.name)
      add2all_geopoints(geopoints)
    end
    
    html
  end
  
  def number2score(number)
    if @record_type == 'median_price' or @record_type == 'average_price'
      return 900 if number.to_i > @price_boundaries[2]
      return 800 if number.to_i <= @price_boundaries[2] and number.to_i > @price_boundaries[1]
      return 700 if number.to_i <= @price_boundaries[1] and number.to_i > @price_boundaries[0]
      return 600 if number.to_i <= @price_boundaries[0]
    else
      return 900 if number.to_i > @num_boundaries[2]
      return 800 if number.to_i <= @num_boundaries[2] and number.to_i > @num_boundaries[1]
      return 700 if number.to_i <= @num_boundaries[1] and number.to_i > @num_boundaries[0]
      return 600 if number.to_i <= @num_boundaries[0]
    end
  end
  
  def draw_tru_legend(page)
    if @record_type == 'median_price' or @record_type == 'average_price'
      boundaries = [ "$500K", "$1.0M", "$1.5M" ]
    else
      boundaries = [ "50", "100", "500" ]
    end
    html = "<br />"
    html += "<img width=10 height=16 src='/images/icons/0-99/blank.png'><font size='-2'>No number</font>, "
    html += "<img width=10 height=16 src='/images/icons/markers/largeTDYellowIcons/blank.png'><font size='-2'>Num&#60;#{boundaries[0]}</font>, "
    html += "<img width=10 height=16 src='/images/icons/markers/largeTDGreenIcons/blank.png'><font size='-2'>#{boundaries[0]}&#60;Num&#60;#{boundaries[1]}</font>, "
    html += "<img width=10 height=16 src='/images/icons/markers/largeTDBlueIcons/blank.png'><font size='-2'>#{boundaries[1]}&#60;Num&#60;#{boundaries[2]}</font>, "
    html += "<img width=10 height=16 src='/images/icons/markers/largeTDRedIcons/blank.png'><font size='-2'>Num>#{boundaries[2]}</font>" 

    if page
      page['legend_ajax'].replace_html(html) 
    else  
      html
    end

  end
  
  
  def county_draw_markers(page)

    record_type = "Number Listed"  if @record_type == 'num_listed'
    record_type = "Median Price"  if @record_type == 'median_price'
    record_type = "Average Price"  if @record_type == 'average_price'

    html = ''
    tagline = ''
    html += "<h3>City Rank:</h3>"
    marker_not_found = false
    tagline += "<h2>#{record_type}</h2>"
    
    i = 1;
    name2rank = {}
    name2number = {}
    for record in @records
      name2rank[record.city] = i
      name2number[record.city] = record.data
      i += 1
    end    
    
    # show map & and draw markers
    load_markers(@map)
    color2icons = init_color_icons(page)
    
    has_marker_hash = {}
    for record in @geopoints
      
      if @stat_type == 'city'
        rank = name2rank[record.city] < 100 ? name2rank[record.city] : 0
        score = number2score(name2number[record.city])
      else
        rank = 0
        score = 900
      end
      icon = get_icon(color2icons, rank, score)
      
      lat = record.class == Hash ? record[:lat] : record.lat
      lng = record.class == Hash ? record[:lng] : record.lng

      #puts "#{record.city}, (#{lat}, #{lng})"

      if lat.to_i!=-1 or lng.to_i!=-1

        # is marker in db??
        status = draw_marker(page, record, icon, record.city, record.city)  
        
        if not status # (not in our db or out of boundary)
          
          # get it from google (if possible)
          latlng = draw_marker_by_google_geocoder(page, icon, record.city, record.city) 
          
          city = TruCity.find_by_id(record.iid)
          if city
            # city_id=-2 for google... meaning get the city geo info from google
            city.update_attributes(:city_id => -2, :lat => latlng[:lat], :lng => latlng[:lng])
          else
            new_rec = { :state_id => @state_id , :county_id => @county_id, 
                        :city_id => -2, :name => record.city,  
                        :lat => latlng[:lat], :lng => latlng[:lng] }
            new_city = TruCity.new(new_rec)
            new_city.save
          end
          status = true if (latlng[:lat].to_i != -1 and latlng[:lng].to_i != -1)
        end
        
        has_marker_hash[record.city] = status
        add2all_geopoints(record)
      else
        has_marker_hash[record.city] = false # lat==0 or lng==0 
      end
    end 

    # side bar info
    mnf_symbol = "<font size='-2'>(&#8224;)</font>"
    marker_not_found = false
    i = 1;
    total = 0
    for record in @records
      total += record.data.to_i

      if @record_type == 'num_listed'
        data = "#{record.data.to_s.gsub(/(.)(?=.{3}+$)/, %q(\1,))}" 
      else  
        if record.data.to_i > 1000000
          data = "#{number_to_currency(record.data.to_i/1000000.0)} M"
        else  
          data = "#{number_to_currency(record.data.to_i/1000, {:precision=>0})} K"
        end
      end

      found_marker = has_marker_hash[record.city] ? '' : " #{mnf_symbol}"
      marker_not_found = true if has_marker_hash[record.city] == false
      html += "#{i}: <a href='/tru/city?show_map=true&state_id=#{@state_id}&county_id=#{@county_id}&city_id=#{record.id}&" + 
                  "year=#{@year}&month=#{@month}&bedroom=#{@bedroom}&stat_type=#{@stat_type}&record_type=#{@record_type}'>" + 
                    "#{record.city}:</a> #{data}#{found_marker}<br />"
      i += 1
    end

    [html, tagline, marker_not_found]
  end


  def city_draw_zipcode_polygons(page)
    
    html = ''
    school_html = ''
    tagline = ''
    marker_not_found = false
    
    fillcolors = ["#ff6347", "#ffdf00", "#228b22", "#0000cd", "#dc143c"]
    
    i=1
    for record in @records

      # polygon
      polygons = @polygon_hash[record.zipcode]
      number = record.data

      index = 0
      if @record_type == 'median_price' or @record_type == 'average_price'
        index = 4 if number.to_i > @price_boundaries[2]
        index = 3 if number.to_i <= @price_boundaries[2] and number.to_i > @price_boundaries[1]
        index = 2 if number.to_i <= @price_boundaries[1] and number.to_i > @price_boundaries[0]
        index = 1 if number.to_i <= @price_boundaries[0]
      else
        index = 4 if number.to_i > @num_boundaries[2]
        index = 3 if number.to_i <= @num_boundaries[2] and number.to_i > @num_boundaries[1]
        index = 2 if number.to_i <= @num_boundaries[1] and number.to_i > @num_boundaries[0]
        index = 1 if number.to_i <= @num_boundaries[0]
      end

      if polygons.size > 0
        # draw polygon
        draw_polygons(page, polygons, fillcolors[index], "#ff0000", 0.5)
        
        # polygon center
        load_markers(@map)
        color2icons = init_color_icons(page)
        icon = get_icon(color2icons, i, number2score(number))
        #center_arr = @polygon_center_hash[record.zipcode]
        latlng = get_polygon_center(polygons)      
        status = draw_marker(page, latlng, icon, record.zipcode, record.zipcode)  
      end
      
      # html on sidebar
      if @record_type == 'num_listed'
        data = "#{record.data.to_s.gsub(/(.)(?=.{3}+$)/, %q(\1,))}" 
      else  
        if record.data.to_i > 1000000
          data = "#{number_to_currency(record.data.to_i/1000000.0)} M"
        else  
          data = "#{number_to_currency(record.data.to_i/1000, {:precision=>0})} K"
        end
      end

      html += "#{i}: #{record.zipcode}: #{data}<br />"

      school_html += "<a href='http://localhost:3000/search/search?search_type=zip&query=#{record.zipcode}&distance=5&school_type=H&page=1&show_map=true'>#{record.zipcode}</a> <br />"

      i += 1
    end

    html += "<br /><h4>Schools Around:</h4>#{school_html} <br />"

    html += "<br />" +
              "<a href='/tru/county?show_map=true&state_id=#{@state_id}&county_id=#{@county_id}&" +
              "year=#{@year}&month=#{@month}&bedroom=#{@bedroom}&stat_type=#{@stat_type}&record_type=#{@record_type}'>#{@county_name}</a>"

    [html, tagline, marker_not_found]
  end

end
