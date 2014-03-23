class School < ActiveRecord::Base

  def self.get_grades(school_code)
    sql=%Q(
        select distinct grade
        from star_results 
        where school_code = #{school_code}
          and grade >0
        order by grade+0 desc
    ) #'
    ApiGrowth.find_by_sql(sql)
  end

  def self.has_3rd_or_7th_grade?(school_code)
    sql=%Q(
      select count(*) count
      from star_results
      where school_code = #{school_code}
        and grade in (3,7)      
    ) #'
    records=ApiGrowth.find_by_sql(sql)

    if records[0].count=='0'
      return false
    else
      return true
    end
  end
  
  #''
  def self.has_7th_grade?(school_code)
    sql=%Q(
      select count(*) count
      from star_results 
      where school_code ='#{school_code}'
        and grade = 7    
    ) #'
    records=ApiGrowth.find_by_sql(sql)

    if records[0].count=='0'
      return false
    else
      return true
    end
  end  
  
  # ''
  def self.get_non_cat6_test_names(year, grade, school_code)
    sql=%Q(
      select test_id, test_name
      from star_tests 
      where year=#{year}
      and test_id in 
        (select test_id
          from star_results 
          where school_code = #{school_code}
            and grade=#{grade}
            and mean_scaled_score > 0
            and test_name not like 'CAT/6%')
      order by test_name    
    ) #'
    StarTest.find_by_sql(sql)
  end

  #''
  def self.get_cat6_test_names(year, grade, school_code)
    sql=%Q(
      select test_id, test_name
      from star_tests 
      where year=#{year}
      and test_id in 
        (select test_id
          from star_results
          where school_code = '#{school_code}'
          and grade=#{grade}
          and mean_scaled_score > 0
          and test_name like 'CAT/6%')
      order by test_name    
    ) #'
    StarTest.find_by_sql(sql)
  end

  
end



