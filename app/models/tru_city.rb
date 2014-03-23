class TruCity < ActiveRecord::Base

  def self.get_city_names_by_county_id(county_id)
    sql = %Q(
      select distinct z.city_id id, i.name 
      from tru_zipcodes z, tru_cities i
      where z.city_id = i.id
      and z.county_id = #{county_id}
      order by i.name
    )
    cities = TruCity.find_by_sql(sql)
    
    city_names = []
    for city in cities
      s = [city.name, city.id]
      city_names << s
    end
    city_names
  end
  
  
end
