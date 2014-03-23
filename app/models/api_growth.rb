require 'rubygems'

# require_gem 'acts_as_ferret'
#require 'acts_as_ferret'

class ApiGrowth < ActiveRecord::Base

  def self.get_api_score(school_code)
    sql=%Q(
      select year, school_name, api_score
      from api_growths
      where school_code = #{school_code}
      order by year
    ) 
    ApiGrowth.find_by_sql(sql)
  end

  def self.find_api_scores(school_codes)
    sql=%Q(
      select year, api_score
      from api_growths
      where school_code in (#{school_codes})
      order by year
    ) 
    ApiGrowth.find_by_sql(sql)
  end
  
  def self.find_school_ranks(school_code)
    sql=%Q(
      select year, school_name, district_name, county_name, state_rank, district_rank, county_rank
      from api_growths g
      where school_code =#{school_code}
    ) 
    ApiGrowth.find_by_sql(sql)
  end

  def self.find_school_counts(school_type)
    sql=%Q(
      select school_type, year, count(*) count
      from api_growths 
      where school_type="#{school_type}" 
      and api_score> 0 
      group by school_type, year;
    ) 
    ApiGrowth.find_by_sql(sql)
  end
  
  def self.find_county_school_counts(school_type, county_code)
    sql=%Q(
      select school_type, year, count(*) count
      from api_growths 
      where school_type="#{school_type}" 
      and county_code=#{county_code}
      and api_score> 0 
      group by school_type, year;
    ) 
    ApiGrowth.find_by_sql(sql)
  end
  
  def self.find_district_school_counts(school_type, district_code)
    sql=%Q(
      select school_type, year, count(*) count
      from api_growths 
      where school_type="#{school_type}" 
      and district_code=#{district_code}
      and api_score> 0 
      group by school_type, year;
    ) 
    ApiGrowth.find_by_sql(sql)
  end

  ##################################################
  def self.api_rank(year, school_type, rows_per_page)
    #    @records=ApiGrowth.find(:all,
    #                            :conditions => %Q(school_type='#{@school_type}' and year='#{@year}'),
    #                            :order =>"api_score desc, school_name",
    #                            :limit => "0,#{@mysql_row_limit}")                            

    sql=%Q(
      select * 
      from api_growths
      where school_type="#{school_type}" 
      and year='#{year}'
      order by api_score desc, school_name
    ) #'
    paginate_by_sql ApiGrowth, sql, rows_per_page
    
  end
    
  
  def self.get_counties(school_type='H', year='07')
    counties=[["<Please Choose>", ""]]
    sql = %Q(
     select distinct county_name
     from api_growths
     where school_type="#{school_type}"
     and county_name != ""
     and year='#{year}'
     order by county_name;
    ) #'
    records=ApiGrowth.find_by_sql(sql)
    for record in records
      counties << record.county_name
    end
    counties
  end
  
  def self.get_district_by_county_name(school_type='H', county_name='Alameda', year='07')
    districts=[["<Please Choose>", ""]]
    sql1 = %Q(
      select distinct district_name 
      from api_growths
      where school_type='#{school_type}'
      and county_name = '#{county_name}'
      and year='#{year}'
      order by district_name;
    ) #'
    records=ApiGrowth.find_by_sql(sql1)
    for record in records
      arr=[record.district_name, record.district_name]
      districts << arr
    end
    districts
  end
  
  def self.get_school_by_county_district(school_type='H', county_name='Alameda', district_name='Alameda City Unified', year='07')
    schools=[["<Please Choose>", ""]]
    sql = %Q(
      select distinct school_name
      from api_growths
      where school_type='#{school_type}'
      and county_name = '#{county_name}'
      and district_name = '#{district_name}'
      and year='#{year}'
      order by school_name;
    ) #'
    records=ApiGrowth.find_by_sql(sql)
    for record in records
      arr=[record.school_name, record.school_name]
      schools << arr
    end
    schools
  end

  #
  # for gmap
  #
  def self.get_state_top_x_schools(stype, year, top_x)
    sql=%Q(
      select * 
      from api_growths
      where school_type='#{stype}' 
      and year='#{year}'
      and state_rank <= #{top_x}
      order by state_rank
    ) #'
    ApiGrowth.find_by_sql(sql)
  end

  def self.get_state_top_x_schools_in_region(stype, year, region, top_x)
    sql=%Q(
      select * 
      from api_growths
      where school_type='#{stype}' 
      and year='#{year}'
      and region = '#{region}'
      and state_rank <= #{top_x}
      order by state_rank
    ) #'
    ApiGrowth.find_by_sql(sql)
  end

  def self.get_region_top_x_schools(stype, year, region, top_x)
    sql=%Q(
      select * 
      from api_growths
      where school_type='#{stype}' 
      and year='#{year}'
      and region = '#{region}'
      and region_rank <= #{top_x}
      order by state_rank
    ) #'
    ApiGrowth.find_by_sql(sql)
  end

  def self.get_county_top10_schools(stype, year, county_name)
    # api scores and ranks
    sql=%Q(
      select * 
      from api_growths
      where school_type='#{stype}' 
      and year='#{year}'
      and county_name='#{county_name}'
      and county_rank <= 10
      order by county_rank
    ) #'
    ApiGrowth.find_by_sql(sql)
  end


  def self.get_state_topN_in_county(stype, year, county_name, n)
    # api scores and ranks
    sql=%Q(
      select * 
      from api_growths
      where school_type='#{stype}' 
      and year='#{year}'
      and county_name='#{county_name}'
      and state_rank <= #{n}
      order by state_rank
    ) #'
    ApiGrowth.find_by_sql(sql)
  end

  def self.get_state_top50_in_county(stype, year, county_name)
    self.get_state_topN_in_county(stype, year, county_name, 50)
  end

  def self.get_state_top100_in_county(stype, year, county_name)
    self.get_state_topN_in_county(stype, year, county_name, 100)
  end

  def self.district_top10(stype, year, county_name, district_name)
    sql=%Q(
      select *
      from api_growths
      where school_type = '#{stype}'
      and year='#{year}'
      and county_name='#{county_name}'
      and district_name = '#{district_name}'
#      and district_rank <= 10
      order by district_rank
    ) #'
    cds2school={}
    schools=ApiGrowth.find_by_sql(sql)
    for school in schools
      cds= "%02d%05d%07d" % [school.county_code, school.district_code, school.school_code]
      cds2school[cds] = school
    end
    cds2school
  end

  def self.get_district_names(stype, year, county_name)
    stype='H' if not stype
    sql=%Q(
      # get_district_names
      select county_code, district_code, school_code, district_name
      from api_growths
      where school_type = '#{stype}'
      and year = #{year}
      and county_name = '#{county_name}'
      order by district_name
    )
    ApiGrowth.find_by_sql(sql)
  end

  def self.get_district_codes(year, county_name)
    sql=%Q(
      select school_type, min(district_code) district_code
      from api_growths
      where year = #{year}
      and county_name = '#{county_name}'
      group by school_type
    )  
    ApiGrowth.find_by_sql(sql)
  end
  
  def self.get_first_district_codes(year, county_name)
    sql=%Q(
      # sql used for _district.rhtml ?????
      select a1.school_type, a2.district_name, min(district_code) district_code
      from api_growths a1, 
        (select county_code, school_type, min(district_name) district_name
            from api_growths
            where year = '#{year}'
            and county_name = '#{county_name}'
            group by school_type) a2
      where a1.county_code = a2.county_code
      and a1.school_type = a2.school_type
      and year = '#{year}'
      and county_name = '#{county_name}'
      group by school_type, a2.district_name
      order by a2.district_name
    )  
    ApiGrowth.find_by_sql(sql)
  end

=begin
      select a1.school_type, a2.district_name, min(district_code) district_code
      from api_growths a1, 
        (select county_code, school_type, min(district_name) district_name
            from api_growths
            where year = '2008'
            and county_name = 'Alameda'
            group by school_type) a2
      where a1.county_code = a2.county_code
      and a1.school_type = a2.school_type
      and year = '2008'
      and county_name = 'Alameda'
      group by school_type, a2.district_name
      order by a2.district_name

select distinct school_type, district_code, district_name, year
from api_growths
where district_code in ('10017', '61119')
and year = 2008
order by school_type

=end

  def self.find_school_by_district_code(stype, year, district_code)
    sql=%Q(
      select *
      from api_growths
      where school_type = '#{stype}'
      and year = #{year}
      and district_code = #{district_code}
      order by district_rank
    )  
    ApiGrowth.find_by_sql(sql)
  end

  def self.get_county_names(stype)
    sql=%Q(
      # Not working....> need to show the first distrct name 
      select county_code, county_name, min(district_code) district_code
      from api_growths
      group by county_code, county_name
      order by county_name
    )
    sql1 =%Q(
      select distinct a1.county_code, a1.county_name, a1.district_code
      from api_growths a1, (select county_code, county_name, min(district_name) district_name
                              from api_growths
                              where school_type = '#{stype}'
                              group by county_code, county_name) a2
      where a1.county_code = a2.county_code
      and a1.district_name = a2.district_name
    )
    ApiGrowth.find_by_sql(sql1)
  end

end
