require './test/helper'
require './ext/svmredlight'

include SVMLight

class TestDoc < Test::Unit::TestCase
  def test_create
    assert d = Doc.create(0, 0.5, [1.0, 0, 0, 0, 0.5])
  end

  def test_create_with_no_array
    assert_raise(TypeError) { Doc.create(-1, 0, {})  }
  end

  def test_create_with_empty_array
    assert_raise(ArgumentError) { Doc.create(-1, 0, [])}
  end
end

class TestModel < Test::Unit::TestCase
  def test_read
    assert m = Model.read_from_file('test/model')
    assert_equal 3877, m.support_vector_count
    assert_equal 39118, m.total_words
  end

  def test_classify
    m = Model.read_from_file('test/model')
    assert m.classify( Doc.create(-1, 0, [1.0, 0, 0, 0, 0.5 ])) 
    assert m.classify( Doc.create(-1, 0, [0, 0, 0, 0, 0.8, 0, 0 , 0 ])) 
    assert m.classify( Doc.create(-1, 0, [0, 0.5, 0, 0, 0, 0 , 0 ])) 
  end
end

