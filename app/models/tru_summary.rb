class TruSummary < ActiveRecord::Base

  def self.get_state_names
    sql=%Q(
      select s.name, s.state_code, num_listed
      from tru_summaries u, tru_states s
      where u.reference_id = s.id
      and u.bedroom = 0
      and stat_type = 'state'
      and year = (select max(year) 
                    from tru_summaries)
        and month = (select max(month) 
                      from tru_summaries 
                      where year = (select max(year) 
                                      from tru_summaries))
      order by name;
    )
    self.find_by_sql(sql)
  end

  def self.get_county_names(state, tru_type)
    stat_type = 'num_listed' if tru_type == 'listed'
    stat_type = 'median_price' if tru_type == 'median'
    stat_type = 'average_price' if tru_type == 'average'
    
    sql=%Q(
      select year, month, c.name, reference_id, #{stat_type} value
      from tru_summaries u, tru_states s, tru_counties c
      where s.id = c.state_id
      and u.bedroom = 0
      and c.id = u.reference_id
      and s.state_code = '#{state}'
      and stat_type = 'county'
      and year = (select max(year) 
                                from tru_summaries)
      and month = (select max(month) 
                    from tru_summaries 
                    where year = (select max(year) 
                                    from tru_summaries))
      order by name;
    )
    self.find_by_sql(sql)
  end

  def self.get_city_names(state, tru_type)
    stat_type = 'num_listed' if tru_type == 'listed'
    stat_type = 'median_price' if tru_type == 'median'
    stat_type = 'average_price' if tru_type == 'average'

    sql=%Q(
      select year, month, c.name, reference_id, #{stat_type} value
      from tru_summaries u, tru_states s, tru_cities c
      where s.id = c.state_id
      and u.bedroom = 0
      and c.id = u.reference_id
      and s.state_code = '#{state}'
      and stat_type = 'city'
      and year = (select max(year) 
                                from tru_summaries)
      and month = (select max(month) 
                    from tru_summaries 
                    where year = (select max(year) 
                                    from tru_summaries))
      order by name;
    )
    self.find_by_sql(sql)
  end  

  def self.get_stats(stat_type, name, column)
    sql=%Q(
      select month, #{column} value 
      from tru_summaries
      where stat_type = '#{stat_type}'
      and bedroom = 0
      and name = '#{name}'
      order by year, month
    )
    self.find_by_sql(sql)
  end
  
   
  
end

