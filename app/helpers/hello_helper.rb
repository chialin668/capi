module HelloHelper

  def hello_draw_markers(page) # also returns the sidebar html
    html = ''
    load_markers(@map)
    color2icons = init_color_icons(page)

    icon = get_icon(color2icons, 0, 900)
    geopoints = {:lat => 37.420644, :lng => -121.021325}
    draw_marker(page, geopoints, icon, 'title', 'info')
    add2all_geopoints(geopoints)
    
    html
  end


end
