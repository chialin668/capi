class Api08gResult < ActiveRecord::Base; end
class Api07gResult < ActiveRecord::Base; end
class Api06gResult < ActiveRecord::Base; end
class Api05gResult < ActiveRecord::Base; end
class Api04gResult < ActiveRecord::Base; end
class Api03gResult < ActiveRecord::Base; end
class Api02gResult < ActiveRecord::Base; end
class Api01gResult < ActiveRecord::Base; end

class ApiResult < ActiveRecord::Base  

  #
  # http://www.cde.ca.gov/ta/ac/ap/reclayout07g.asp
  #
  def self.exec_sql(year, sql)
    #??? there must be a better way
    return Api08gResult.find_by_sql(sql) if year=='2008'
    return Api07gResult.find_by_sql(sql) if year=='2007'
    return Api06gResult.find_by_sql(sql) if year=='2006'
    return Api05gResult.find_by_sql(sql) if year=='2005'
    return Api04gResult.find_by_sql(sql) if year=='2004'
    return Api03gResult.find_by_sql(sql) if year=='2003'
    return Api02gResult.find_by_sql(sql) if year=='2002'
    return Api01gResult.find_by_sql(sql) if year=='2001'
  end

  #''
  def self.api_detail(year, cds)
    
    yr=year.gsub(/20/,'')
    lyr= "%02d" % (yr.to_i-1)
    sql=%Q(
      select tested, valid, api#{yr} api_yr, api#{lyr} api_lyr, target, growth, sch_wide, comp_imp, both_targets
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  #''
  def self.number_tested(year, cds)
    # Number of Students Tested
    yr=year.gsub(/20/,'')
    sql=%Q(
      select tested
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end
  
  #'''
  def self.race(year, cds)
    # Percent African American
    # Percent American Indian
    # Percent Asian
    # Percent Filipino
    # Percent Hispanic or Latino
    # Percent Pacific Islander
    # Percent White    
    yr=year.gsub(/20/,'')
    sql=%Q(
      select pct_aa, pct_ai, pct_as, pct_fi, pct_hi, pct_pi, pct_wh
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end
  
  #'''
  def self.api_by_race(year, cds)
    # Percent African American
    # Percent American Indian
    # Percent Asian
    # Percent Filipino
    # Percent Hispanic or Latino
    # Percent Pacific Islander
    # Percent White    
    yr=year.gsub(/20/,'')
    sql=%Q(
      select aa_api#{yr} 'aa', ai_api#{yr} 'ai', as_api#{yr} 'as', fi_api#{yr} 'fi', hi_api#{yr} 'hi', pi_api#{yr} 'pi', wh_api#{yr} 'wh'
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  #'''
  def self.sub_group_detail_by_race(year, cds)
    # Number of Subgroup students Included in API
    # Subgroup Significant Both Years? (Yes/No)
    # 2007 Subgroup API (Growth)
    # 2006 Subgroup API (Base)
    # 2006-2007 Subgroup Growth Target
    # 2006-2007 Subgroup API Growth
    # Met Subgroup Growth Target
  
    yr=year.gsub(/20/,'')
    lyr= "%02d" % (yr.to_i-1)

    sql=%Q(
      select aa_num, ai_num, as_num, fi_num, hi_num, pi_num, wh_num,
          aa_sig, ai_sig, as_sig, fi_sig, hi_sig, pi_sig, wh_sig,
          aa_api#{yr} aa_api_yr, ai_api#{yr} ai_api_yr, as_api#{yr} as_api_yr, 
              fi_api#{yr} fi_api_yr, hi_api#{yr} hi_api_yr, pi_api#{yr} pi_api_yr, wh_api#{yr} wh_api_yr,
          aa_api#{lyr} aa_api_lyr, ai_api#{lyr} ai_api_lyr, as_api#{lyr} as_api_lyr, 
              fi_api#{lyr} fi_api_lyr, hi_api#{lyr} hi_api_lyr, pi_api#{lyr} pi_api_lyr, wh_api#{lyr} wh_api_lyr,
          aa_targ, ai_targ, as_targ, fi_targ, hi_targ, pi_targ, wh_targ,
          aa_grow, ai_grow, as_grow, fi_grow, hi_grow, pi_grow, wh_grow,
          aa_met, ai_met, as_met, fi_met, hi_met, pi_met, wh_met
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  #'''    
  def self.sub_group_detail_other(year, cds)
    # Socioeconomically Disadvantaged
    # English Learner Students
    # Students with Disabilities
    yr=year.gsub(/20/,'')
    lyr= "%02d" % (yr.to_i-1)
    sql=%Q(
      select sd_num, el_num, di_num, 
          sd_sig, el_sig, di_sig, 
          sd_api#{yr} sd_api_yr, el_api#{yr} el_api_yr, di_api#{yr} di_api_yr, 
          sd_api#{lyr} sd_api_lyr, el_api#{lyr} el_api_lyr, di_api#{lyr} di_api_lyr, 
          sd_targ, el_targ, di_targ, 
          sd_grow, el_grow, di_grow, 
          sd_met, el_met, di_met
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end  

  #'
  def self.race_included(year, cds)
    # African American
    # American Indian
    # Asian
    # Filipino
    # Hispanic or Latino
    # Pacific Islander
    # White    
    yr=year.gsub(/20/,'')
    sql=%Q(
      select aa_num 'aa', ai_num 'ai', as_num 'as', fi_num 'fi', hi_num 'hi', pi_num 'pi', wh_num 'wh'
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end
  
  # '''
  def self.parent_ed_level(year, cds)
    # Parent Ed Level: Percent Not High School Graduate
    # Parent Ed Level: Percent High School Graduate
    # Parent Ed Level: Percent Some College
    # Parent Ed Level: Percent College Graduate
    # Parent Ed Level: Percent Graduate School
    # Average Parent Education Level
    # Unknown: 100% - total%
    yr=year.gsub(/20/,'')
    sql=%Q(
      select pct_resp, not_hsg, hsg, some_col, col_grad, grad_sch, avg_ed
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  # '''
  def self.pct_enrollment(year, cds)
    # Percent of Enrollments in grade 2 (STAR), 3-5, 6, 7-8, 9-11
    # ??? no pen_2 in year2005!!!!
    yr=year.gsub(/20/,'')
    sql=%Q(
      select pen_2, pen_35, pen_6, pen_78, pen_911
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  # '''
  def self.avg_class_size(year, cds)
    # acs_k3: Average Class Size (Grades K-3)
    # acs_46: Average Class Size (Grades 4-6)
    # acs_core: Average Class Size for a Number of Core Academic Courses
    yr=year.gsub(/20/,'')
    sql=%Q(
      select acs_k3, acs_46, acs_core
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end
  
  # '''
  def self.special_student(year, cds)
    # Percentage of Students that are Participants in the Free or Reduced Price Meal Program
    # Percent of participants in Gifted and Talented education programs (STAR)
    # Percent of participants in migrant education programs (STAR)
    # Percent of participants who are designated as English Learners
    # Percent of Reclassified Fluent-English-Proficient (RFEP) students (STAR)
    # Percent of Students with Disabilities (STAR)
    yr=year.gsub(/20/,'')
    sql=%Q(
      select meals, p_gate, p_miged, p_el, p_rfep, p_di
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  #####################################'''
  def self.vcst(year, school_type, cds)
    #
    # VST: Valid Score for California Standards Test (CST)
    #
    # E28, E91: English-Language Arts Grades 2-8, 9-11
    # M28, M91: Mathematics Grades 2-8, 9-11
    # S28, S91: Science Grades 2-8 (Includes ONLY Grades 5 & 8), 9-11 (End of Cousrse, CST).
    # H28, H91: History-Social Science Grades 2-8, 9-11
    # LS10:     Life Science Grade 10 only
    yr=year.gsub(/20/,'')

    if school_type=='H' and year.to_i >= 2007
      select_string = "select vcst_e91 'e', vcst_m91 'm', vcst_s91 's', vcst_h91 'h', vcst_ls10 'ls'" 
    elsif school_type=='H' and year.to_i < 2007
      select_string = "select vcst_e91 'e', vcst_m91 'm', vcst_s91 's', vcst_h91 'h'" 
    else
      select_string = "select vcst_e28 'e', vcst_m28 'm', vcst_s28 's', vcst_h28 'h'"
    end
    sql=%Q(
      #{select_string}
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  # '''
  def self.pcst(year, school_type, cds)
    #
    # PCST: Product of Test Weights Multiplied by Valid Scores for CST
    #
    # E28, E91: English-Language Arts Grades 2-8, 9-11
    # M28, M91: Mathematics Grades 2-8, 9-11
    # S28, S91: Science Grades 2-8 (Includes ONLY Grades 5 & 8), 9-11 (End of Cousrse, CST).
    # H28, H91: History-Social Science Grades 2-8, 9-11
    # LS10:     Life Science Grade 10 only  (Only in 2007)
    yr=year.gsub(/20/,'')
    if school_type=='H' and year.to_i >= 2007
      select_string = "select pcst_e91 'e', pcst_m91 'm', pcst_s91 's', pcst_h91 'h', pcst_ls10 'ls'" 
    elsif school_type=='H' and year.to_i < 2007
      select_string = "select pcst_e91 'e', pcst_m91 'm', pcst_s91 's', pcst_h91 'h'" 
    else
      select_string = "select pcst_e28 'e', pcst_m28 'm', pcst_s28 's', pcst_h28 'h'"
    end  
    sql=%Q(
      #{select_string}
      from api#{yr}g_results
      where cds = '#{cds}'
    ) #'
    self.exec_sql(year, sql)
  end

  def self.get_cws(year, cds)
    yr=year.gsub(/20/,'')
    sql=%Q(
      select cw_cste, cw_cstm, cws_91, cw_csth, cw_sci
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  #####################################'''
  def self.vm200(year, cds)
    # M2_28, M2_91: Mathematics Assignment of 200 CST in Grades 2-8, 9-11
    # S2_91: Science Assignment of 200 CST in Grades 9-11
    yr=year.gsub(/20/,'')
    sql=%Q(
      select vcstm2_28 m228, vcstm2_91 m291, vcsts2_91 s291
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  def self.pm200(year, cds)
    # M2_28, M2_91: Mathematics Assignment of 200 CST in Grades 2-8, 9-11
    # S2_91: Science Assignment of 200 CST in Grades 9-11
    yr=year.gsub(/20/,'')
    sql=%Q(
      select pcstm2_28 m228, pcstm2_91 m291, pcsts2_91 s291
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  def self.cw_m200(year, cds)
    # M2_28, M2_91: Mathematics Assignment of 200 CST in Grades 2-8, 9-11
    # S2_91: Science Assignment of 200 CST in Grades 9-11
    yr=year.gsub(/20/,'')
    sql=%Q(
      select cwm2_28, cwm2_91, cws2_91
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  #####################################'''
  def self.vnrt(year, cds)
    # Norm-Referenced Test (NRT) 
    # reading, language, spelling, mathmatics in Grades 2-8
    yr=year.gsub(/20/,'')
    sql=%Q(
      select vnrt_r28 r, vnrt_l28 l, vnrt_s28 s, vnrt_m28 m
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  def self.pnrt(year, cds)
    # Norm-Referenced Test (NRT) 
    # reading, language, spelling, mathmatics in Grades 2-8
    yr=year.gsub(/20/,'')
    sql=%Q(
      select pnrt_r28 r, pnrt_l28 l, pnrt_s28 s, pnrt_m28 m
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  def self.cwnrt(year, cds)
    # Norm-Referenced Test (NRT) 
    # reading, language, spelling, mathmatics in Grades 2-8
    yr=year.gsub(/20/,'')
    sql=%Q(
      select cw_pnrtr, cw_pnrtl, cw_pnrts, cw_pnrtm
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  #####################################'''
  def self.vchs(year, cds)
    # California High School Exit Exam (CAHSEE)
    yr=year.gsub(/20/,'')
    sql=%Q(
      select vchs_e e, vchs_m m
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  def self.pchs(year, cds)
    # California High School Exit Exam (CAHSEE)
    yr=year.gsub(/20/,'')
    sql=%Q(
      select pchs_e e, pchs_m m
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  def self.cw_chs(year, cds)
    # California High School Exit Exam (CAHSEE)
    yr=year.gsub(/20/,'')
    sql=%Q(
      select cw_chse, cw_chsm
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end
  
  def self.ptotal(year, cds)
    yr=year.gsub(/20/,'')
    sql=%Q(
      select tot_28, tot_91
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

  def self.teacher(year, cds)
    yr=year.gsub(/20/,'')
    sql=%Q(
      select full, emer
      from api#{yr}g_results
      where cds = '#{cds}'
    )
    self.exec_sql(year, sql)
  end

end


