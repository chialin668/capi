class MySchool < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :school_type, :county_name, :district_name, :school_name
  validates_uniqueness_of :school_type, :scope => "user_id"

  def self.count_my_schools(user_id)
    MySchool.count(["user_id=?", user_id])
  end

  def self.get_my_schools(user_id)
    sql= %Q(
      select * 
      from my_schools
      where user_id=#{user_id}
    )
    schools=MySchool.find_by_sql(sql)
  end

=begin
  def self.is_my_school?(user_id, county_name, district_name, school_name)
    schools=MySchool.get_my_schools(user_id)
    for school in schools 
      return true if school.county_name==county_name && school.district_name==district_name && school.school_name==school_name
    end
    return false
  end
=end

  def self.has_this_type_of_school?(user_id, school_type)
    MySchool.find_by_user_id_and_school_type(user_id, school_type)
  end
  
  def self.has_high_school?(user_id)
    MySchool.find_by_user_id_and_school_type(user_id, 'H')
  end

  def self.has_middle_school?(user_id)
    MySchool.find_by_user_id_and_school_type(user_id, 'M')
  end

  def self.has_elemantary_school?(user_id)
    MySchool.find_by_user_id_and_school_type(user_id, 'E')
  end


end
