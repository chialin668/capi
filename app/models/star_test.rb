class StarTest < ActiveRecord::Base


  def self.get_math_tests(year, school_name, grade)
    sql=%Q(
      select test_id, test_name
      from star_tests 
      where year=#{year}
      and (lower(test_name) like '%math%'
            or lower(test_name) like 'algebra%'
            or lower(test_name) = 'geometry')
      and test_id in 
        (select test_id
          from star_results r, star_categories c
          where r.school_code=c.school_code
          and r.district_code=c.district_code
          and r.county_code=c.county_code
          and c.school_name = '#{school_name}'
          and r.grade=#{grade})
    ) #''
    StarTest.find_by_sql(sql)
  end
  
  def self.get_english_tests(year, school_name, grade)
    # English
    sql=%Q(
      select test_id, test_name
      from star_tests 
      where year=#{year}
      and lower(test_name) like '%english%'
      and test_id in 
        (select test_id
          from star_results r, star_categories c
          where r.school_code=c.school_code
          and r.district_code=c.district_code
          and r.county_code=c.county_code
          and c.school_name = '#{school_name}'
          and r.grade=#{grade})
    ) #''
    StarTest.find_by_sql(sql)
  end
    
  def self.get_science_tests(year, school_name, grade)
    # Science
    sql=%Q(
      select test_id, test_name
      from star_tests 
      where year=#{year}
      and lower(test_name) like '%science%'
      and test_id in 
        (select test_id
          from star_results r, star_categories c
          where r.school_code=c.school_code
          and r.district_code=c.district_code
          and r.county_code=c.county_code
          and c.school_name = '#{school_name}'
          and r.grade=#{grade})
    ) #''
    StarTest.find_by_sql(sql)
  end
  
  def self.get_physic_tests(year, school_name, grade)
    # Physics
    sql=%Q(
      select test_id, test_name
      from star_tests 
      where year=#{year}
      and lower(test_name) like '%physics%'
      and test_id in 
        (select test_id
          from star_results r, star_categories c
          where r.school_code=c.school_code
          and r.district_code=c.district_code
          and r.county_code=c.county_code
          and c.school_name = '#{school_name}'
          and r.grade=#{grade})
    ) #''
    StarTest.find_by_sql(sql)
  end

  def self.get_chemistry_tests(year, school_name, grade)
    # Chemistry
    sql=%Q(
      select test_id, test_name
      from star_tests 
      where year=#{year}
      and lower(test_name) like '%chemistry%'
      and test_id in 
        (select test_id
          from star_results r, star_categories c
          where r.school_code=c.school_code
          and r.district_code=c.district_code
          and r.county_code=c.county_code
          and c.school_name = '#{school_name}'
          and r.grade=#{grade})
    ) #''
    StarTest.find_by_sql(sql)
  end
  
  def self.get_history_tests(year, school_name, grade)
    # History
    sql=%Q(
      select test_id, test_name
      from star_tests 
      where year=#{year}
      and lower(test_name) like '%history%'
      and test_id in 
        (select test_id
          from star_results r, star_categories c
          where r.school_code=c.school_code
          and r.district_code=c.district_code
          and r.county_code=c.county_code
          and c.school_name = '#{school_name}'
          and r.grade=#{grade})
    ) #''
    StarTest.find_by_sql(sql)
  end
  
  def self.get_cat_6_tests(year, school_name, grade)
    # cat/6
    sql=%Q(
      select test_id, test_name
      from star_tests 
      where year=#{year}
      and lower(test_name) like '%cat/6%'
      and test_id in 
        (select test_id
          from star_results r, star_categories c
          where r.school_code=c.school_code
          and r.district_code=c.district_code
          and r.county_code=c.county_code
          and c.school_name = '#{school_name}'
          and r.grade=#{grade})
    ) #''
    StarTest.find_by_sql(sql)
  end

end

