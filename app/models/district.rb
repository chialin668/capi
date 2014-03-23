class District < ActiveRecord::Base

  def self.get_schools(school_type, district_code)
    
    sql=%Q(
      select distinct school_code, school_name
      from api_growths
      where school_type = '#{school_type}'
      and year = '2007'
      and district_code = #{district_code}
      order by school_name
    ) #'
    ApiGrowth.find_by_sql(sql)
    
  end

  def self.get_districts(school_type, county_code)
    sql=%Q(
      select distinct district_code, district_name
      from api_growths
      where school_type = '#{school_type}'
      and year = '2007'
      and county_code = #{county_code}
      order by district_name
    )
    ApiGrowth.find_by_sql(sql)
  end

  def self.get_counties(school_type)
    sql=%Q(
      select distinct county_code, county_name
      from api_growths
      where school_type = '#{school_type}'
      and year = '2007'
      order by county_name
    ) #'
    ApiGrowth.find_by_sql(sql)
  end

end
