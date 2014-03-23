class IfsSchool < ActiveRecord::Base
  acts_as_mappable

  def self.get_district_geo_info(stype, county_name)

    type_str='(1,3,4)' if stype=='H'
    type_str='(1,2)' if stype=='M' or stype=='E'

    # For geo info
    sql=%Q(
      SELECT *
      FROM ifs_schools 
      WHERE stype in #{type_str}
      and county_name = '#{county_name}'
      and status = 'OPEN'
      order by district_name;  
    ) #'
    districts = self.find_by_sql(sql)
    cds2geo={}
    for district in districts
      geoinfo = { :lat => district.lat, :lng => district.lng,
            :address => district.address, :city => district.city, 
            :state => district.state, :zip => district.zip}
#      puts "geo: #{district.cds}: #{district.district_name}"
      cds2geo[district.cds] = geoinfo
    end
    cds2geo
  end

  def self.get_school_geo_info(stype, county_name)
    sql=%Q(
      select *
      from ifs_schools
      where stype = '#{stype}'
      and county_name = '#{county_name}'
      and status = 'OPEN'
      order by school_name
    ) #'
    schools = self.find_by_sql(sql)
    cds2geo={}
    for school in schools
      geoinfo = { :lat => school.lat, :lng => school.lng,
            :address => school.address, :city => school.city, 
            :state => school.state, :zip => school.zip}
      cds2geo[school.cds] = geoinfo
    end
    cds2geo
  end


  def self.get_school_geo_by_cds(stype, cdslist)
    sql=%Q(
      select *
      from ifs_schools
      where stype = '#{stype}'
      and cds in (#{cdslist})
      and status = 'OPEN'
      order by school_name
    ) #'
    schools = self.find_by_sql(sql)
    cds2geo={}
    for school in schools
      geoinfo = { :lat => school.lat, :lng => school.lng,
            :address => school.address, :city => school.city, 
            :state => school.state, :zip => school.zip}
      cds2geo[school.cds] = geoinfo
    end
    cds2geo
  end

end
