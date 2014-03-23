class DemoController < ApplicationController

  include GetParameter
  include Chart

  def initialize
    @app_base=app_base
    @app_name='DEMO'
    @title='iFanSee'
    @tagline='Yes, we love to analyze...'
    @theme='aqualicious'
  end

  def index
    
  end

  
  def api_score_xml

    xml=%Q(
      <chart_data>
      <row>
      <null />
      <string>2001</string>
      <string>2002</string>
      <string>2003</string>
      <string>2004</string>
      <string>2005</string>
      <string>2006</string>
      <string>2007</string>
      </row>
      <row>
      <string>Lee Middle</string>
      <number>591</number>
      <number>619</number>
      <number>637</number>
      <number>632</number>
      <number>655</number>
      <number>691</number>
      <number>696</number>
      </row>
      </chart_data>
    )

    render_text line_data(xml, 550, 700)

  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end
  

  def mean_score_xml
    xml=%Q(
      <chart_data>
      <row>
      <null />
      <string>2004</string>
      <string>2005</string>
      <string>2006</string>
      <string>2007</string>
      </row>
      <row>
      <string>Palmdale High School</string>
      <number>316.3</number>
      <number>319.1</number>
      <number>310.4</number>
      <number>322.3</number>
      </row>
      <row>
      <string>Antelope Valley Union High School District</string>
      <number>315.6</number>
      <number>316.3</number>
      <number>309.8</number>
      <number>312.9</number>
      </row>
      <row>
      <string>Los Angeles County</string>
      <number>315.8</number>
      <number>318.3</number>
      <number>319.3</number>
      <number>323.9</number>
      </row>
      <row>
      <string>State of California</string>
      <number>319.7</number>
      <number>323.1</number>
      <number>324.4</number>
      <number>327.6</number>
      </row>
      </chart_data>    
    )
    render_text line_on_column({:xml=>xml, :min=>250, :max=>340})
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end


  def pct_value_xml
    xml=%Q(
      <chart_data>
      <row>
      <null />
      <string>2004</string>
      <string>2005</string>
      <string>2006</string>
      <string>2007</string>
      </row>
      <row>
      <string>Advanced</string>
      <number>20</number>
      <number>35</number>
      <number>45</number>
      <number>36</number>
      </row>
      <row>
      <string>Proficient</string>
      <number>33</number>
      <number>27</number>
      <number>24</number>
      <number>33</number>
      </row>
      <row>
      <string>Basic</string>
      <number>27</number>
      <number>22</number>
      <number>18</number>
      <number>13</number>
      </row>
      <row>
      <string>Below Basic</string>
      <number>18</number>
      <number>16</number>
      <number>7</number>
      <number>15</number>
      </row>
      <row>
      <string>Far Below Basic</string>
      <number>2</number>
      <number>0</number>
      <number>6</number>
      <number>4</number>
      </row>
      </chart_data>
    )
    render_text staked_column_1(xml)
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end


  def pac_value_xml
    xml=%Q(
      <chart_data>
      <row>
      <null />
      <string>2004</string>
      <string>2005</string>
      <string>2006</string>
      <string>2007</string>
      </row>
      <row>
      <string>pac75</string>
      <number>39</number>
      <number>27</number>
      <number>36</number>
      <number>35</number>
      </row>
      <row>
      <string>pac50</string>
      <number>63</number>
      <number>61</number>
      <number>68</number>
      <number>65</number>
      </row>
      <row>
      <string>pac25</string>
      <number>88</number>
      <number>95</number>
      <number>91</number>
      <number>77</number>
      </row>
      </chart_data>
    )
    render_text area_1(xml)
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end

  def race_xml
    xml=%Q(
      <chart_data>
      <row>
      <null/>
      <string>African American</string>
      <string>American Indian</string>
      <string>Asian</string>
      <string>Filipino</string>
      <string>Hispanic or Latino</string>
      <string>Pacific Islander</string>
      <string>White</string>
      <string>Others</string>
      </row>
      <row>
      <string></string>
      <number>4</number>
      <number>0</number>
      <number>43</number>
      <number>21</number>
      <number>24</number>
      <number>1</number>
      <number>6</number>
      <number>1</number>
      </row>
      </chart_data>
    )
    render_text three_d_pie(xml)
  
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end

  def api_by_race_xml
    xml=%Q(
      <chart_data>
      <row>
      <null/>
      <string></string>
      </row>
      <row>
      <string>African American</string>
      <number>0</number>
      </row>
      <row>
      <string>American Indian</string>
      <number>0</number>
      </row>
      <row>
      <string>Asian</string>
      <number>954</number>
      </row>
      <row>
      <string>Filipino</string>
      <number>893</number>
      </row>
      <row>
      <string>Hispanic or Latino</string>
      <number>852</number>
      </row>
      <row>
      <string>Pacific Islander</string>
      <number>0</number>
      </row>
      <row>
      <string>White</string>
      <number>946</number>
      </row>
      </chart_data>
    )
    render_text column(xml, 0, 1000)
    
  rescue Exception => e 
    logger.error "########## Error!!!! ##########"
    logger.error "Class: #{self.class}\nAction: #{self.action_name}\n\n#{e.to_s}\n"
    render_text line_data("<chart_data><row></row></chart_data>")    
  end
  
end
