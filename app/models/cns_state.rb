class CnsState < ActiveRecord::Base

  def self.find_all_state_names
    sql=%Q(
      select distinct state_name
      from cns_states
      order by state_name
    )
    CnsCounty.find_by_sql(sql)
  end

end
