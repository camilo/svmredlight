require './test/helper'
require './lib/svmredlight'

include SVMLight

class TestDocument < Test::Unit::TestCase

  def test_create
    assert Document.create(0, 0.5, [1.0, 0, 0, 0, 0.5])
  end

  def test_create_with_no_array
    assert_raise(TypeError) { Document.create(-1, 0, {})  }
  end

  def test_create_with_empty_array
    assert_raise(ArgumentError) { Document.create(-1, 0, [])}
  end
end

