class TruState < ActiveRecord::Base

  def self.get_state_names
    sql=%Q(
      select name, id
      from tru_states
      order by name
    ) #'
    states = TruState.find_by_sql(sql)
    
    state_names = []
    for state in states
      s = [state.name, state.id]
      state_names << s
    end
    state_names
  end
  
end
