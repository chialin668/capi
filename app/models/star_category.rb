class StarCategory < ActiveRecord::Base

#  acts_as_ferret :remote => true, :fields => [ :school_name, :district_name, :county_name, :year ]
#  acts_as_ferret :remote => true

  def self.get_names(school_code=0, district_code=0, county_code=0)
    
    if (district_code!=nil and county_code!=nil)
      sql=%Q(
        # get_names
        select distinct school_name, county_name, district_name
        from star_categories
        where school_code=#{school_code}
        and district_code=#{district_code}
        and county_code=#{county_code}
        order by year desc
      ) 
    else
      # used for school comparison (no district_code and county_code)
      sql=%Q(
        # get_names
        select distinct school_name, county_name, district_name
        from star_categories
        where school_code=#{school_code}
        order by year desc
      ) 
    end

    records=StarCategory.find_by_sql(sql) 
    
    # can have different school name in different years
    school_hash={}
    for record in records
      school_hash[record.school_name]=record.school_name
    end

    if records.size == 0
      # can't find the school, but sometimes, we still want the district/county name.
      [school_hash, '', 
          StarCategory.find_by_district_code(district_code).district_name, 
          StarCategory.find_by_county_code(county_code).county_name]
    else
      [school_hash, 
        records[0].school_name, 
        records[0].district_name, 
        records[0].county_name]     
    end
  end

  def self.find_object_like(name)
    sql=%Q(
      select distinct school_code, district_code, county_code, 
                school_name, district_name, county_name
      from star_categories
      where school_code>0
          and district_code>0
          and county_code>0
          and (school_name like '#{name}%' 
          or district_name like '#{name}%' 
          or county_name like '#{name}%')
      order by county_name, district_name, school_name
    )
    records=StarCategory.find_by_sql(sql) 
  end

end
