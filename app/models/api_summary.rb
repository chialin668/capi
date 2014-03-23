class ApiSummary < ActiveRecord::Base
  
  def self.get_api_scores(school_type, district_code)
    sql=%Q(
      /* get_api_scores */
      select distinct year, school_name, district_name, county_name, 
                            district_api, county_api, state_api
      from api_summaries
      where school_type = '#{school_type}'
      and district_code= #{district_code}
      order by year
    ) # '   
    ApiSummary.find_by_sql(sql)
  end

  def self.get_api_district_scores(school_type, district_name, county_name)
    sql=%Q(
      /* get_api_district_scores */
      select distinct year, state_api, district_api, county_api
      from api_summaries
      where district_name = '#{district_name}'
      and county_name = '#{county_name}'
      and school_type = '#{school_type}'
      order by year
    ) # '   
    ApiSummary.find_by_sql(sql)
  end

  def self.get_district_apis(stype, year, county_name)

    sql = %Q(
      select * 
      from api_summaries
      where year = '#{year}'
      and county_name = '#{county_name}'
      and school_type = '#{stype}'
      order by district_name
    )
    self.find_by_sql(sql)
  end


end