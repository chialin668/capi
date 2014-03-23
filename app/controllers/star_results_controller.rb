=begin
class StarResultsController < ApplicationController
  
  @records
  @grade
  @test_id
  @test_name

  def mean_scaled_score
    @grade=params[:grade]
    @test_id=params[:test_id]
    @test_name=params[:test_name]
       
    sql = <<END_OF_SQL_MEAN
    select school_name, county_name, district_name, mean_scaled_score
    from star_results r, star_categories c
    where r.county_code = c.county_code
      and r.district_code = c.district_code
      and r.school_code = c.school_code
      and test_id = #{@test_id}
      and grade = #{@grade}
    and school_name != ''
    order by mean_scaled_score desc
    limit 0,25; 
END_OF_SQL_MEAN
    puts sql

    @records=StarResult.find_by_sql(sql)    
    
    code2schoolinfo=session[:my_school]
    puts "123"
    puts code2schoolinfo[:school_code]
    puts "456"
  end
  
  def pac75
    @grade=params[:grade]
    @test_id=params[:test_id]
    @test_name=params[:test_name]
    
    sql = <<END_OF_SQL_PAC75
    select school_name, county_name, district_name, pac75,
          percent_tested, start_reported_enrollment  
    from star_results r, star_categories c
    where r.county_code = c.county_code
      and r.district_code = c.district_code
      and r.school_code = c.school_code
      and test_id = #{@test_id}
      and grade = #{@grade}
    and school_name != ''
    order by pac75 desc
    limit 0,25; 
END_OF_SQL_PAC75

      puts sql
      @records=StarResult.find_by_sql(sql)    
  end
  
  def cst_pct_advanced
    @grade=params[:grade]
    @test_id=params[:test_id]
    @test_name=params[:test_name]

    sql = <<END_OF_SQL_CST_PCT
    select school_name, county_name, district_name, cst_pct_advanced, cst_pct_proficient, 
          percent_tested, start_reported_enrollment  
    from star_results r, star_categories c
    where r.county_code = c.county_code
      and r.district_code = c.district_code
      and r.school_code = c.school_code
      and test_id = #{@test_id}
      and grade = #{@grade}
    and school_name != ''
    order by cst_pct_advanced desc, cst_pct_proficient desc
    limit 0,25; 
END_OF_SQL_CST_PCT

    puts sql
    @records=StarResult.find_by_sql(sql)    
    
  end
end

=end