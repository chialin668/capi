class IfsState < ActiveRecord::Base

  def self.get_state_names
    sql=%Q(
      select long_name, id
      from ifs_states
      order by long_name
    ) #'
    states = IfsState.find_by_sql(sql)
    
    state_names = []
    for state in states
      s = [state.long_name, state.id]
      state_names << s
    end
    state_names
  end
    
end
