module CnsHelper

  def test
    puts 'test'
    color2icons = init_color_icons(nil)
    icon = get_icon(color2icons, 1, 900)
    @map.overlay_init GMarker.new([37.350408, -122.056942], :icon => icon, :title => "Marker-1", :info_window => "Marker 1!")
  end


  #####################################################################
  def state_draw_markers(page) # also returns the sidebar html

    html =''
    html += "<h3>School Rank:</h3>"
    marker_not_found=false

    stype = 'High' if @stype=='H'
    stype = 'Middle' if @stype=='M'
    stype = 'Elementary' if @stype=='E'
    tagline = "<h2>Top #{@scount} #{stype} Schools in California</h2>"
  
    load_markers(@map)
    geopoints=[]
    color2icons = init_color_icons(page)

    for school in @schools
      cds= "%02d%05d%07d" % [school.county_code, school.district_code, school.school_code]

      sname = school.school_name.length >= 20 ? "#{school.school_name[0..20]}..." : school.school_name
      school_name = "<a href='#{@capi_url_base}#{@capi_api_app_base}/school/api_score?" +
                    "year=#{@current_year}&" +
                    "school_type=#{@stype}&" + 
                    "school_code=#{school.school_code}&" +
                    "district_code=#{school.district_code}&" + 
                    "county_code=#{school.county_code}'>#{sname}</a>"
      rank = school.state_rank 
      
      geoinfo = @school_cds2geo[cds]
      mnf_symbol = ''
      if geoinfo and (geoinfo[:lat]!=0 and geoinfo[:lng]!=0)
    
          geopoints << geoinfo # for center and scale
    
          icon = get_icon(color2icons, rank, school.api_score)
    
          apiinfo = "Api Score: #{school.api_score} <br />" + 
                "State Rank: #{school.state_rank} <br /><br/>"
          address = "#{geoinfo[:address]} <br />" +
                "#{geoinfo[:city]}, #{geoinfo[:state]} #{geoinfo[:zip]} <br />"
          info = "#{school_name} <br />" + address

          draw_marker(page, geoinfo, icon, school.school_name, info)
          add2all_geopoints(geoinfo)

      else  
          logger.warn "WARNING: Geo info NOT found for: #{school.school_name}"
          mnf_symbol = "<font size='-2'>(&#8224;)</font>"
          marker_not_found = true
      end
    
      html += "#{rank}: #{school_name} #{mnf_symbol}<br />"    
    end
    
    full_list_url = "<br /><a href='#{@capi_url_base}#{@capi_api_app_base}/api/all_schools?year=#{@current_year}&school_type=#{@stype}'>Full List</a>"
    html += full_list_url
    
    [html, tagline, marker_not_found]
  end

  #####################################################################
  def region_draw_markers(page) # also returns the sidebar html

    html =''
    marker_not_found=false
    
    stype = 'High' if @stype=='H'
    stype = 'Middle' if @stype=='M'
    stype = 'Elementary' if @stype=='E'

    load_markers(@map)
    geopoints=[]
    color2icons = init_color_icons(page)

    if @region and @mtype and @scount != '' 
      # draw school markers
      
      if @mtype=='state'
        tagline = "<h2>Top #{@scount} #{stype} Schools in California (Located in SF Bay Area)</h2>" if @region=='SF'
        tagline = "<h2>Top #{@scount} #{stype} Schools in California (Located in LA Area)</h2>" if @region=='LA'
      elsif @mtype=='region'
        tagline = "<h2>Top #{@scount} #{stype} Schools in SF Bay Area</h2>" if @region=='SF'
        tagline = "<h2>Top #{@scount} #{stype} Schools in LA Area</h2>" if @region=='LA'
      end
      
      
      html += "<h3>School Rank:</h3>"
      
      for school in @schools
        cds= "%02d%05d%07d" % [school.county_code, school.district_code, school.school_code]
        
        sname = school.school_name.length >= 20 ? "#{school.school_name[0..20]}..." : school.school_name
        school_name = "<a href='#{@capi_url_base}#{@capi_api_app_base}/school/api_score?" +
                      "year=#{@current_year}&" +
                      "school_type=#{@stype}&" + 
                      "school_code=#{school.school_code}&" +
                      "district_code=#{school.district_code}&" + 
                      "county_code=#{school.county_code}'>#{sname}</a>"
        rank = school.state_rank if @mtype=='state'
        rank = school.region_rank if @mtype=='region'
        
        geoinfo = @school_cds2geo[cds]
        mnf_symbol = ''
        if geoinfo and (geoinfo[:lat]!=0 and geoinfo[:lng]!=0)
      
            geopoints << geoinfo # for center and scale
      
            icon = get_icon(color2icons, rank, school.api_score)
      
            apiinfo = "Api Score: #{school.api_score} <br />" + 
                  "Region Rank: #{school.region_rank} <br />" + 
                  "State Rank: #{school.state_rank} <br /><br/>"
            address = "#{geoinfo[:address]} <br />" +
                  "#{geoinfo[:city]}, #{geoinfo[:state]} #{geoinfo[:zip]} <br />"
            info = "#{school_name} <br />" + address

            draw_marker(page, geoinfo, icon, school.school_name, info)
            add2all_geopoints(geoinfo)
        else  
            logger.warn "WARNING: Geo info NOT found for: #{school.school_name}"
            mnf_symbol = "<font size='-2'>(&#8224;)</font>"
            marker_not_found = true
        end
      
        html += "#{rank}: #{school_name} #{mnf_symbol}<br />"    
      end
      
      full_list_url = "<br /><a href='#{@capi_url_base}#{@capi_api_app_base}/api/regions?region=#{@region}&year=#{@current_year}&school_type=#{@stype}'>Full List</a>"
      html += full_list_url
        
    end
      
    [html, tagline, marker_not_found]
  end

  #####################################################################
  def county_draw_markers(page)

    html = ''
    marker_not_found=false

    stype = 'High' if @stype=='H'
    stype = 'Middle' if @stype=='M'
    stype = 'Elementary' if @stype=='E'

    load_markers(@map)
    geopoints=[]
    color2icons = init_color_icons(page)

    if @mtype=='district'
      
      tagline = "<h2>#{stype} School Districts</h2>"
      html += "<h3>District List:</h3>"
      
      for district in @districts
      
        cds= "%02d%05d0000000" % [district.county_code, district.district_code]
        
        dname = district.district_name.length >= 17 ? "#{district.district_name[0..17]}..." : district.district_name
        
        # district_name = "<a href='#{@capi_url_base}#{@capi_api_app_base}/district/api_score?" +
        #              "year=#{@current_year}&" +
        #              "school_type=#{@stype}&" +
        #              "school_code=-1&" +
        #              "county_code=#{district.county_code}&" +
        #              "district_code=#{district.district_code}'>#{dname}</a>"

        tagline = "<h2>#{@district_name}</h2>"
        district_name = "<a href='/cns/district?stype=#{@stype}&county_name=#{@county_name}&district_cds=#{cds}'>#{dname}</a>"
    
        geoinfo = @district_cds2gso[cds]
        mnf_symbol = ''
        if geoinfo and (geoinfo[:lat]!=0 and geoinfo[:lng]!=0)
            geopoints << geoinfo # for center and scale
            icon = get_icon(color2icons, 0, nil)
            address = "#{geoinfo[:address]} <br />" +
                  "#{geoinfo[:city]}, #{geoinfo[:state]} #{geoinfo[:zip]} <br />"
            info="#{district_name} <br />" + address

            draw_marker(page, geoinfo, icon, district.district_name, info)
            add2all_geopoints(geoinfo)
        else  
            logger.warn "WARNING: Geo info NOT found for: #{district.district_name}"
            mnf_symbol = "<font size='-2'>(&#8224;)</font>"
            marker_not_found = true
        end
        html += "&#164; #{district_name} #{mnf_symbol}<br />"
      end
      
    elsif @mtype=='county' or @mtype=='state50' or @mtype=='state99'
    
      tagline = "<h2>Top 10 #{stype} Schools in #{@county_name} County</h2>" if @mtype=='county'
      tagline = "<h2>Top 50 #{stype} Schools in California (Located in #{@county_name} County)</h2>" if @mtype=='state50'
      tagline = "<h2>Top 100 #{stype} Schools in California (Located in #{@county_name} County)</h2>" if @mtype=='state99'
    
      html += "<h3>School Rank:</h3>"
    
      for school in @schools
        cds= "%02d%05d%07d" % [school.county_code, school.district_code, school.school_code]
        
        sname = school.school_name.length >= 17 ? "#{school.school_name[0..17]}..." : school.school_name
        school_name = "<a href='#{@capi_url_base}#{@capi_api_app_base}/school/api_score?" +
                      "year=#{@current_year}&" +
                      "school_type=#{@stype}&" + 
                      "school_code=#{school.school_code}&" +
                      "district_code=#{school.district_code}&" + 
                      "county_code=#{school.county_code}'>#{sname}</a>"
        rank = school.county_rank if @mtype=='county'
        rank = school.state_rank if @mtype=='state50'
        rank = school.state_rank if @mtype=='state99'

        geoinfo = @school_cds2geo[cds]
        mnf_symbol = ''
        if geoinfo and (geoinfo[:lat]!=0 and geoinfo[:lng]!=0)
    
            geopoints << geoinfo # for center and scale
    
            icon = get_icon(color2icons, rank, school.api_score)
    
            apiinfo = "Api Score: #{school.api_score} <br />" + 
                  "County Rank: #{school.county_rank} <br />" + 
                  "State Rank: #{school.state_rank} <br /><br/>"
            address = "#{geoinfo[:address]} <br />" +
                  "#{geoinfo[:city]}, #{geoinfo[:state]} #{geoinfo[:zip]} <br />"
            info = "#{school_name} <br />" + address

            draw_marker(page, geoinfo, icon, school.school_name, info)
            add2all_geopoints(geoinfo)
        else  
            logger.warn "WARNING: Geo info NOT found for: #{school.school_name}"
            mnf_symbol = "<font size='-2'>(&#8224;)</font>"
            marker_not_found = true
        end
    
        html += "#{rank}: #{school_name} #{mnf_symbol}<br />"
      end
    
    end 
    
    # center and scale
    if page
      page << @map.set_center(GLatLng.new(find_geo_center(geopoints)), find_scale_level(geopoints)-1) 
    else  
      geoinfo = find_geo_center(geopoints)
      if geoinfo[0]==0.0 or geoinfo[1]==0.0
        @map.center_zoom_init([37.420644, -121.021325], 8) # center of California
      else  
        @map.center_zoom_init(GLatLng.new(find_geo_center(geopoints)), find_scale_level(geopoints)-1) 
      end    
    end

    full_list_url = "<br /><a href='#{@capi_url_base}#{@capi_api_app_base}/api/counties?year=#{@current_year}&school_type=#{@stype}&county_name=#{@county_name}'>Full List</a>"
    html += full_list_url
    
    [html, tagline, marker_not_found]
  end

  #####################################################################
  def district_draw_markers(page) # also returns the sidebar html

    html =''
    geopoints=[]
    marker_not_found=false
    
    load_markers(@map)
    
    # draw school markers
    color2icons = init_color_icons(page)
    
    stype = 'High' if @stype=='H'
    stype = 'Middle' if @stype=='M'
    stype = 'Elementary' if @stype=='E'
    tagline = "<h2>#{@county_name} County</h2>"
    
    html += "<h3>School Rank:</h3>"
    
    for school in @schools
      cds= "%02d%05d%07d" % [school.county_code, school.district_code, school.school_code]
      
      sname = school.school_name.length >= 20 ? "#{school.school_name[0..20]}..." : school.school_name
      school_name = "<a href='#{@capi_url_base}#{@capi_api_app_base}/school/api_score?" +
                    "year=#{@current_year}&" +
                    "school_type=#{@stype}&" + 
                    "school_code=#{school.school_code}&" +
                    "district_code=#{school.district_code}&" + 
                    "county_code=#{school.county_code}'>#{sname}</a>"
      rank = school.district_rank 
    
      #puts "#{rank}: #{school.school_name}"
      
      geoinfo = @school_cds2geo[cds]
      mnf_symbol = ''
      if geoinfo and (geoinfo[:lat]!=0 and geoinfo[:lng]!=0)
    
          geopoints << geoinfo # for center and scale
    
          icon = get_icon(color2icons, rank, school.api_score)
          #puts "\t(#{geoinfo[:lat]}, #{geoinfo[:lng]})"
          apiinfo = "Api Score: #{school.api_score} <br />" + 
                "District Rank: #{school.district_rank} <br />" + 
                "County Rank: #{school.county_rank} <br />" + 
                "State Rank: #{school.state_rank} <br /><br/>"
          address = "#{geoinfo[:address]} <br />" +
                "#{geoinfo[:city]}, #{geoinfo[:state]} #{geoinfo[:zip]} <br />"
          info = "#{school_name} <br />" + address
    
          draw_marker(page, geoinfo, icon, school.school_name, info)
          add2all_geopoints(geoinfo)
      else  
          logger.warn "WARNING: Geo info NOT found for: #{school.school_name}"
          mnf_symbol = "<font size='-2'>(&#8224;)</font>"
          marker_not_found = true
      end
    
      html += "#{rank}: #{school_name} #{mnf_symbol}<br />"    
    end

    full_list_url = "<br /><a href='#{@capi_url_base}#{@capi_api_app_base}/api/districts?year=#{@current_year}&school_type=#{@stype}&county_name=#{@county_name}&district_name=#{@district_name}'>Full List</a>"
    html += full_list_url
      
    # center and scale
    if page
      page << @map.set_center(GLatLng.new(find_geo_center(geopoints)), find_scale_level(geopoints)-1) 
    else  
      geoinfo = find_geo_center(geopoints)
      if geoinfo[0]==0.0 or geoinfo[1]==0.0
        @map.center_zoom_init([37.420644, -121.021325], 8) # center of California
      else  
        @map.center_zoom_init(GLatLng.new(find_geo_center(geopoints)), find_scale_level(geopoints)-1) 
      end    
    end

    [html, tagline, marker_not_found]
  end

end
