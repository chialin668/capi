
require 'acts_as_ferret'

class FerretApiGrowth < ActiveRecord::Base

  acts_as_ferret :remote => true, :fields => [ :year,
                                               :school_type, 
                                               :school_name, :district_name, :county_name, 
                                               :api_score, 
                                               :region,
                                               :state_rank, :region_rank, :county_rank, :district_rank,
                                               :county_code, :district_code, :school_code]
end
