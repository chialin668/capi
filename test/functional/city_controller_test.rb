require File.dirname(__FILE__) + '/../test_helper'
require 'city_controller'

# Re-raise errors caught by the controller.
class CityController; def rescue_action(e) raise e end; end

class CityControllerTest < Test::Unit::TestCase
  def setup
    @controller = CityController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
