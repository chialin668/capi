require 'models/star_test'
require 'models/star_result'

class StarController < ApplicationController

#  before_filter :authorize

  attr_accessor :app_name, :mysql_row_limit, :theme

  def initialize
    @app_base=app_base
    @app_name='STAR'
    @title='California STAR Test'
    @tagline=%Q(Standardized Testing and Reporting)
    @mysql_row_limit=15
    @theme='aqualicious'
    @year=current_year.to_i
  end
  
  def get_rows_per_page
    my_profile=MyProfile.find_by_user_id(session[:user_id])
    if my_profile
      @mysql_row_limit=my_profile.rows_per_page
    else 
      @mysql_row_limit=10
    end
  end
  
  def score_main
      @score_type=params[:score_type]
      @grade=params[:grade]
      sql = %Q(
        select distinct t.test_id, t.test_name 
        from star_results r, star_tests t
        where r.test_id =t.test_id
        and school_code > 0
        and #{@score_type} > 0
        and grade=#{@grade}
        and r.year=#{@year}
        and t.year=#{@year}
        order by t.test_name;
      ) #'
#      puts sql
      
 #     @records=StarResult.find_by_sql(sql)

  end

  def mean_scaled_score
    @grade=params[:grade]
    @test_id=params[:test_id]
    @test_name=params[:test_name]
    sql = %Q(
      select state_rank_mean, school_name, county_name, district_name, mean_scaled_score
      from star_results r, star_categories c
      where r.county_code = c.county_code
        and r.district_code = c.district_code
        and r.school_code = c.school_code
        and test_id = #{@test_id}
        and grade = #{@grade}
        and r.year=#{@year}
        and c.year=#{@year}
        and school_name != ''
      order by mean_scaled_score desc
    ) #'
    @record_pages, @records = paginate_by_sql StarResult, sql, get_rows_per_page

  end

  def pac75
    @grade=params[:grade]
    @test_id=params[:test_id]
    @test_name=params[:test_name]
    sql = %Q(
      select school_name, county_name, district_name, pac75,
            percent_tested, start_reported_enrollment, state_rank_pac75  
      from star_results r, star_categories c
      where r.county_code = c.county_code
        and r.district_code = c.district_code
        and r.school_code = c.school_code
        and test_id = #{@test_id}
        and grade = #{@grade}
        and r.year=#{@year}
        and c.year=#{@year}
        and school_name != ''
        order by pac75 desc
    )
    @record_pages, @records = paginate_by_sql StarResult, sql, get_rows_per_page
  end

  def cst_pct_advanced
    @grade=params[:grade]
    @test_id=params[:test_id]
    @test_name=params[:test_name]

    sql = %Q(
      select school_name, county_name, district_name, 
            cst_pct_advanced, cst_pct_proficient, 
            percent_tested, start_reported_enrollment, state_rank_pct 
      from star_results r, star_categories c
      where r.county_code = c.county_code
        and r.district_code = c.district_code
        and r.school_code = c.school_code
        and test_id = #{@test_id}
        and grade = #{@grade}
        and r.year=#{@year}
        and c.year=#{@year}
        and school_name != ''
        order by cst_pct_advanced+cst_pct_proficient desc
    )
    @record_pages, @records = paginate_by_sql StarResult, sql, get_rows_per_page
    
  end


end
