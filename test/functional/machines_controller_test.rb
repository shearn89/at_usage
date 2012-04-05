require 'test_helper'

class MachinesControllerTest < ActionController::TestCase
  setup do
  end
  
  test "should predict usage" do
    get "index"
    asser_not_nil @estimates[0]
    assert_not_nil @estimates[1]
  end
end
