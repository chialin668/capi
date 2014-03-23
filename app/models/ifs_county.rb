class IfsCounty < ActiveRecord::Base

  def self.get_county_names(state_id)
    sql=%Q(
      select name, id
      from ifs_counties
      where state_id = #{state_id}
      order by name
    ) #'
    counties = IfsCounty.find_by_sql(sql)
    
    county_names = []
    for county in counties
      s = [county.name, county.id]
      county_names << s
    end
    county_names
  end
    

end
