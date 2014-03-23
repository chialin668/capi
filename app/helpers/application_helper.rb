# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  include GeoKit::Geocoders

  def get_polygon_center(polygons)
    
    lats = 0
    lngs = 0
    
    for polygon in polygons
      lat_sum = 0.0
      lng_sum = 0.0
      for ll in polygon
        lat_sum += ll[0]
        lng_sum += ll[1]
      end
      lat_avg = lat_sum/polygon.size
      lng_avg = lng_sum/polygon.size
      
      lats = lats + lat_avg 
      lngs = lngs + lng_avg
    end
    lats_avg = lats/polygons.size
    lngs_avg = lngs/polygons.size
    #puts lats_avg, lngs_avg
    
    {:lat => lats_avg, :lng => lngs_avg}
  end
  
  def draw_polygons(page, polygons, fillColor="#00ff00", strokeColor="#ff0000", 
                                      fillOpacity=0.3, strokeWeight=5, strokeOpacity=0.3)
    lat_array = []
    lng_array = []

    for polygon in polygons
      if page
        # latlngs, strokeColor?, strokeWeight?, strokeOpacity?, fillColor?, fillOpacity?, opts?
        page << @map.add_overlay(GPolygon.new(polygon, strokeColor, strokeWeight, strokeOpacity, fillColor, fillOpacity))
      else
        @map.overlay_init(GPolygon.new(polygon, strokeColor, strokeWeight, strokeOpacity, fillColor, fillOpacity))
      end

      # find the polygon boundary
      for latlng in polygon
        # puts "(#{latlng[0]}, #{latlng[1]})"
        lat_array << latlng[0]
        lng_array << latlng[1]
        
        add2all_geopoints({:lat => latlng[0], :lng => latlng[1]})
      end
    end
    
    lat_array.sort!
    lng_array.sort!
    @lat_min = lat_array[0]
    @lat_max = lat_array[lat_array.size-1]
    @lng_min = lng_array[0]
    @lng_max = lng_array[lng_array.size-1]
  end


  def draw_marker_by_google_geocoder(page, icon, title, info)

    loc = GoogleGeocoder.geocode("#{title}, CA")
    if loc.success

      lat = loc.lat
      lng = loc.lng
      
      if (!@lat_min and !@lat_max and !@lng_min and !@lng_max) or 
            (lat.to_f > @lat_min.to_f and lat.to_f < @lat_max.to_f and lng.to_f > @lng_min.to_f and lng.to_f < @lng_max.to_f)
        if page      
          page << @map.add_overlay(GMarker.new([lat, lng], 
                                  :icon => icon,
                                  :title => title,
                                  :info_window => info)) 
        else                                  
          @map.overlay_init(GMarker.new([lat, lng], 
                                  :icon => icon,
                                  :title => title,
                                  :info_window => info)) 
        end

        return { :lat => lat, :lng => lng }
      else
        logger.warn "**** ++++ Google geocoder location still out of boundary for #{title}!!!!"
        return { :lat => -1.0, :lng => -1.0 }  # mark them as 0s so we won't need to get it from internet again!!
      end
    else
      logger.warn "****>>>>> Google Geocoder Error!!  title: #{title}"
      return { :lat => -1.0, :lng => -1.0 }  # mark them as 0s so we won't need to get it from internet again!!
    end  
  end


  def draw_marker(page, geopoint, icon, title, info)
    
      lat = geopoint.class == Hash ? geopoint[:lat] : geopoint.lat
      lng = geopoint.class == Hash ? geopoint[:lng] : geopoint.lng
      
      if lat and lng        
        # if no boundary --> draw marker anyway
        # if has boundary --> needs to be within the boundary
        if (!@lat_min and !@lat_max and !@lng_min and !@lng_max) or 
              (lat.to_f > @lat_min.to_f and lat.to_f < @lat_max.to_f and lng.to_f > @lng_min.to_f and lng.to_f < @lng_max.to_f)
  
          if page      
            page << @map.add_overlay(GMarker.new([lat, lng], 
                                    :icon => icon,
                                    :title => title,
                                    :info_window => info)) 
          else                                  
            @map.overlay_init(GMarker.new([lat, lng], 
                                    :icon => icon,
                                    :title => title,
                                    :info_window => info)) 
          end
          return true
          
        else
          logger.warn "\n**** WARNING: #{title} (#{lat}, #{lng}) is " +
                  "Out of Boundary (#{@lat_min},#{@lat_max}),(#{@lng_min},#{@lng_max})!!"
          return false
        end
      else
          logger.warn "\n**** WARNING: Geo info not found!! #{title} (#{lat}, #{lng})"
          return false
      end  
  end

  def add2all_geopoints(geopoint)
      return if not @all_geopoints
      
      lat = geopoint.class == Hash ? geopoint[:lat] : geopoint.lat
      lng = geopoint.class == Hash ? geopoint[:lng] : geopoint.lng
      
      # if no boundary --> add it anyway
      # if has boundary --> needs to be within the boundary
      if (!@lat_min and !@lat_max and !@lng_min and !@lng_max) or 
            (lat.to_f > @lat_min.to_f and lat.to_f < @lat_max.to_f and lng.to_f > @lng_min.to_f and lng.to_f < @lng_max.to_f)
        @all_geopoints << {:lat => lat, :lng => lng}
      end      
  end
  
  def set_geo_center(page)
    return if @all_geopoints.size == 0
    
    if page
      page << @map.set_center(GLatLng.new(find_geo_center(@all_geopoints)), find_scale_level(@all_geopoints)-1) 
    else  
      @map.center_zoom_init(GLatLng.new(find_geo_center(@all_geopoints)), find_scale_level(@all_geopoints)-1) 
    end  
  end

  #
  # For GMap
  #
  def gmap_boundary_by_zoom_level
    #
    # To retrieve information, use: 
    # http://localhost:3000/gmap_geobound.html
    #
    boundary=[]
    boundary[0] = [[-89.72647879678343, -180], [89.93411921886802, 180]]
    boundary[1] = [[-82.02137801950886, -180], [88.07532853412853, 180]]
    boundary[2] = [[-48.92249926375824, 120.23437499999997], [79.56054626376365, -4.21875]]
    boundary[3] = [[-7.885147283424331, 178.9453125], [66.01801815922042, -63.28125]]
    boundary[4] = [[16.04581345375217, -151.611328125], [54.1109429427243, -92.724609375]]
    boundary[5] = [[27.254629577800063, -136.845703125], [46.40756396630067, -107.40234375]]
    boundary[6] = [[32.491230287947594, -129.5068359375], [42.08191667830631, -114.78515625000001]]
    boundary[7] = [[35.00300339527669, -125.826416015625], [39.80009595634838, -118.46557617187501]]
    boundary[8] = [[36.230981283477924, -123.98071289062499], [38.62974534092597, -120.30029296874999]]
    boundary[9] = [[36.84006462037767, -123.06335449218751], [38.039438891821725, -121.22314453125001]]
    boundary[10] = [[37.14170874010794, -122.6019287109375], [37.74139927315054, -121.68182373046875]]
    boundary[11] = [[37.292081740702365, -122.37190246582031], [37.59192743186127, -121.91184997558595]]
    boundary[12] = [[37.366882922327626, -122.2568893432617], [37.516806367148575, -122.02686309814455]]
    boundary[13] = [[37.404391941703665, -122.19938278198242], [37.479353670749205, -122.08436965942383]]
    boundary[14] = [[37.42313941392658, -122.17062950134277], [37.46062027927878, -122.11312294006348]]
    boundary[15] = [[37.43254546808027, -122.15629577636717], [37.45128589232625, -122.12754249572755]]
    boundary[16] = [[37.437213976341035, -122.14908599853514], [37.44658419061043, -122.13470935821535]]
    boundary[17] = [[37.43955663991349, -122.1454918384552], [37.444241747049816, -122.13830351829529]]
    
    # Google map has 17 zoom levels
    0.upto(17) do |i|
      (nw, se) = boundary[i]
      (nw_lat, nw_lng) = nw
      (se_lat, se_lng) = se
      
      puts "@gpoint2scale[#{i}] = [#{se_lat-Nw_lat}, #{se_ng-Nw_lng}]"
    end
  end


  def get_gscale_range
    # find the proper scale (that two points are within the map window)
    # generated by gmap_boundary_by_zoom_level (application.rb)
    @gpoint2scale={}
    @gpoint2scale[0] = [179.660598015651, 360]
    @gpoint2scale[1] = [170.096706553637, 360]
    @gpoint2scale[2] = [128.483045527522, -124.453125]
    @gpoint2scale[3] = [73.9031654426447, -242.2265625]
    @gpoint2scale[4] = [38.0651294889721, 58.88671875]
    @gpoint2scale[5] = [19.1529343885006, 29.443359375]
    @gpoint2scale[6] = [9.59068639035872, 14.7216796875]
    @gpoint2scale[7] = [4.79709256107169, 7.36083984374999]
    @gpoint2scale[8] = [2.39876405744805, 3.68041992187499]
    @gpoint2scale[9] = [1.19937427144405, 1.8402099609375]
    @gpoint2scale[10] = [0.599690533042605, 0.92010498046875]
    @gpoint2scale[11] = [0.299845691158907, 0.460052490234361]
    @gpoint2scale[12] = [0.149923444820949, 0.230026245117159]
    @gpoint2scale[13] = [0.0749617290455404, 0.115013122558594]
    @gpoint2scale[14] = [0.037480865352201, 0.0575065612792969]
    @gpoint2scale[15] = [0.0187404242459763, 0.02875328063962]
    @gpoint2scale[16] = [0.00937021426939566, 0.0143766403197958]
    @gpoint2scale[17] = [0.00468510713633208, 0.00718832015991211]    
  end

  def load_square_markers(map)
    1.upto(99) do |i|
      map.icon_global_init(GIcon.new(:image => "/images/icons/markers/smallSQRedIcons/marker#{i}.png",
                                        :icon_size => GSize.new(15,15),
                                        :icon_anchor => GPoint.new(12,34),
                                        :info_window_anchor => GPoint.new(9,2)), 
                                        "icon_red#{i}")    
    end
  end

  def load_markers(map)
    # blank markers
    map.icon_global_init(GIcon.new(:image => "/images/icons/markers/largeTDRedIcons/blank.png",                              
                                      :icon_size => GSize.new(20,34),
                                      :icon_anchor => GPoint.new(12,34),
                                      :shadow => "/images/icons/google/shadow50.png",
                                      :shadow_size => GSize.new(37,34),
                                      :info_window_anchor => GPoint.new(9,2)), 
                                      "icon_blank_red")    

    map.icon_global_init(GIcon.new(:image => "/images/icons/markers/largeTDGreenIcons/blank.png",                            
                                      :icon_size => GSize.new(20,34),
                                      :icon_anchor => GPoint.new(12,34),
                                      :shadow => "/images/icons/google/shadow50.png",
                                      :shadow_size => GSize.new(37,34),
                                      :info_window_anchor => GPoint.new(9,2)), 
                                      "icon_blank_green")    

    map.icon_global_init(GIcon.new(:image => "/images/icons/markers/largeTDBlueIcons/blank.png",                             
                                      :icon_size => GSize.new(20,34),
                                      :icon_anchor => GPoint.new(12,34),
                                      :shadow => "/images/icons/google/shadow50.png",
                                      :shadow_size => GSize.new(37,34),
                                      :info_window_anchor => GPoint.new(9,2)), 
                                      "icon_blank_blue")    

    map.icon_global_init(GIcon.new(:image => "/images/icons/markers/largeTDYellowIcons/blank.png",                           
                                      :icon_size => GSize.new(20,34),
                                      :icon_anchor => GPoint.new(12,34),
                                      :shadow => "/images/icons/google/shadow50.png",
                                      :shadow_size => GSize.new(37,34),
                                      :info_window_anchor => GPoint.new(9,2)), 
                                      "icon_blank_yellow")    

    map.icon_global_init(GIcon.new(:image => "/images/icons/0-99/blank.png",                                       
                                      :icon_size => GSize.new(20,34),
                                      :icon_anchor => GPoint.new(12,34),
                                      :shadow => "/images/icons/google/shadow50.png",
                                      :shadow_size => GSize.new(37,34),
                                      :info_window_anchor => GPoint.new(9,2)), 
                                      "icon_blank")    

    # numbered markers
    1.upto(99) do |i|
      map.icon_global_init(GIcon.new(:image => "/images/icons/markers/largeTDRedIcons/marker#{i}.png",
                                        :icon_size => GSize.new(20,34),
                                        :icon_anchor => GPoint.new(12,34),
                                        :shadow => "/images/icons/google/shadow50.png",
                                        :shadow_size => GSize.new(37,34),
                                        :info_window_anchor => GPoint.new(9,2)), 
                                        "icon_red#{i}")    
    end

    1.upto(99) do |i|
      map.icon_global_init(GIcon.new(:image => "/images/icons/markers/largeTDBlueIcons/marker#{i}.png",
                                        :icon_size => GSize.new(20,34),
                                        :icon_anchor => GPoint.new(12,34),
                                        :shadow => "/images/icons/google/shadow50.png",
                                        :shadow_size => GSize.new(37,34),
                                        :info_window_anchor => GPoint.new(9,2)), 
                                        "icon_blue#{i}")    
    end

    1.upto(99) do |i|
      map.icon_global_init(GIcon.new(:image => "/images/icons/markers/largeTDGreenIcons/marker#{i}.png",
                                        :icon_size => GSize.new(20,34),
                                        :icon_anchor => GPoint.new(12,34),
                                        :shadow => "/images/icons/google/shadow50.png",
                                        :shadow_size => GSize.new(37,34),
                                        :info_window_anchor => GPoint.new(9,2)), 
                                        "icon_green#{i}")    
    end

    1.upto(99) do |i|
      map.icon_global_init(GIcon.new(:image => "/images/icons/markers/largeTDYellowIcons/marker#{i}.png",
                                        :icon_size => GSize.new(20,34),
                                        :icon_anchor => GPoint.new(12,34),
                                        :shadow => "/images/icons/google/shadow50.png",
                                        :shadow_size => GSize.new(37,34),
                                        :info_window_anchor => GPoint.new(9,2)), 
                                        "icon_yellow#{i}")    
    end

    1.upto(99) do |i|
      map.icon_global_init(GIcon.new(:image => "/images/icons/0-99/marker#{i}.png", 
                                        :icon_anchor => GPoint.new(12,34),
                                        :shadow => "/images/icons/google/shadow50.png",
                                        :shadow_size => GSize.new(37,34),
                                        :info_window_anchor => GPoint.new(9,2)), 
                                        "icon#{i}")    
    end
  end


  def init_icons(page, color, count)
    icons=[]
    icon = Variable.new("icon_blank_#{color}") 
    icons << icon # [0]
    1.upto(count) do |i| 
      icon = Variable.new("icon_#{color}#{i}") 
      icons << icon
      page << icon if page
    end
    icons
  end

  def init_color_icons(page)

    color2icons = {}
    icon_blank = Variable.new("icon_blank");            
    page << icon_blank if page
    color2icons[:blank] = icon_blank
    
    icons_red = init_icons(page, 'red', 99)
    color2icons[:red] = icons_red
    icons_blue = init_icons(page, 'blue', 99)
    color2icons[:blue] = icons_blue
    icons_green = init_icons(page, 'green', 99)
    color2icons[:green] = icons_green
    icons_yellow = init_icons(page, 'yellow', 99)
    color2icons[:yellow] = icons_yellow
    
    color2icons  
  end
  

  def get_icon(color2icons, rank, api)
    
    icons_red = color2icons[:red]
    icons_blue = color2icons[:blue]
    icons_green = color2icons[:green]
    icons_yellow = color2icons[:yellow]
    icon_blank = color2icons[:blank]
    
    if api
      if rank.to_i > 0 and rank.to_i <= 99
        icon = icons_yellow[rank] if api < 700
        icon = icons_green[rank] if api >=700 and api <800
        icon = icons_blue[rank] if api >=800 and api <900
        icon = icons_red[rank] if api >=900
      else
        icon = icons_yellow[0] if api < 700
        icon = icons_green[0] if api >=700 and api <800
        icon = icons_blue[0] if api >=800 and api <900
        icon = icons_red[0] if api >=900
      end
    else
      icon = icon_blank # no api score 
    end  
    icon
  end

  def find_geo_center(geopoints)
    
    return @map_center if geopoints.size == 0 
    
    geo_count=0
    sum_lat=0.0; sum_lng=0.0
    for latlng in geopoints
        #puts "#{latlng[:lat]}, #{latlng[:lng]}"
      if latlng[:lat]!=0 and latlng[:lng]!=0 
        sum_lat += latlng[:lat].to_f
        sum_lng += latlng[:lng].to_f
        geo_count += 1
      end  
    end
    
    if geo_count==0
      [0.0, 0.0] 
    else  
      [sum_lat/geo_count, sum_lng/geo_count]    
    end
  end


  def find_scale_level(geopoints)

    scale_level=9  # default level
    return scale_level if geopoints.size == 0

    get_gscale_range

    lats=[]; lngs=[]
    for latlng in geopoints
      if latlng[:lat]!=0 and latlng[:lng]!=0 
        #puts "#{latlng[:lat]}, #{latlng[:lng]}"
        lats << latlng[:lat].to_f
        lngs << latlng[:lng].to_f
      end  
    end
    
    lat_diff = lats.max - lats.min
    lng_diff = lngs.max - lngs.min
      
    0.upto(13) do |i|  # Will be too close from 11 to 17
      (boundary_lat, boundary_lng) = @gpoint2scale[i]
      break if (boundary_lat-lat_diff<0 and boundary_lng-lng_diff<0)
      scale_level = i
    end  
    scale_level
  end

  def draw_legend(page)
    html = "<br />"
    html += "<img width=10 height=16 src='/images/icons/0-99/blank.png'><font size='-2'>No API score</font>, "
    html += "<img width=10 height=16 src='/images/icons/markers/largeTDYellowIcons/blank.png'><font size='-2'>API&#60;700</font>, "
    html += "<img width=10 height=16 src='/images/icons/markers/largeTDGreenIcons/blank.png'><font size='-2'>700&#60;API&#60;800</font>, "
    html += "<img width=10 height=16 src='/images/icons/markers/largeTDBlueIcons/blank.png'><font size='-2'>800&#60;API&#60;900</font>, "
    html += "<img width=10 height=16 src='/images/icons/markers/largeTDRedIcons/blank.png'><font size='-2'>API>900</font>" 

    if page
      page['legend_ajax'].replace_html(html) 
    else  
      html
    end

  end

end
