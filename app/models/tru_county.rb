class TruCounty < ActiveRecord::Base

  def self.get_county_names(state_id)
    sql=%Q(
      select name, id
      from tru_counties
      where state_id = #{state_id}
      order by name
    ) #'
    counties = TruCounty.find_by_sql(sql)
    
    county_names = []
    for county in counties
      s = [county.name, county.id]
      county_names << s
    end
    county_names
  end

  def self.get_county_info(state_id, criteria_str)
    sql=%Q(
      select * 
      from tru_counties
      where state_id = #{state_id}
      and name in (#{criteria_str})
    )
    self.find_by_sql(sql)
  end
  
  def self.get_city_geoinfo_by_county_name(year, month, bedroom, county_name)
    sql = %Q(
     select distinct i.id iid, i.name city, i.lat, i.lng
     from tru_summaries s, tru_zipcodes z, tru_cities i, tru_counties o
     where s.year = #{year}
         and s.month = #{month}
         and bedroom = #{bedroom}
         and s.stat_type = 'zipcode'     
     and s.reference_id = z.id
     and z.city_id = i.id
     and z.county_id = o.id
     and o.name = '#{county_name}'
    ) #'
    self.find_by_sql(sql)
  end
  
  def self.get_zipcode_geoinfo_by_county_name(year, month, bedroom, county_name)
    sql = %Q(
     select distinct z.id iid, z.name zipcode, i.name city, z.lat, z.lng
     from tru_summaries s, tru_zipcodes z, tru_cities i, tru_counties o
     where s.year = #{year}
         and s.month = #{month}
         and bedroom = #{bedroom}
         and s.stat_type = 'zipcode'     
     and z.city_id = i.id
     and z.county_id = o.id
     and o.name = '#{county_name}'
    ) #'
    self.find_by_sql(sql)
  end
  
  def self.abc
    sql=%Q(
       select distinct z.name zipcode, i.name city, z.lat, z.lng
       from tru_zipcodes z, tru_cities i, tru_counties o
       where z.city_id = i.id
       and z.county_id = o.id
       and o.name = 'Alameda'
       
    )
  end
  
end

