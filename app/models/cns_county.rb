class CnsCounty < ActiveRecord::Base
  
  def self.find_all_county_names(state_code)
    sql=%Q(
      select distinct county_name
      from cns_counties
      where state_code = '#{state_code}'
      order by county_name
    )
    CnsCounty.find_by_sql(sql)
  end
end
