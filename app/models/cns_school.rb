class CnsSchool < ActiveRecord::Base

  def self.find_district_by_name_and_types(district_name, types)
    sql=%Q(
      # find polygons
      select *
      from cns_schools
      where state_code = 'CA'
      and district_type in #{types}
      and district_name in #{district_name}
    ) #'
    CnsSchool.find_by_sql(sql)
  end

end
