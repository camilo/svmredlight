require './test/helper'
include SVMLight

class TestDocument < Test::Unit::TestCase

  def test_create
    d = Document.create(0, 0.5, 1, 0, [[1, 1.0 ], [4, 0.0] , [10, 0.0] ,[ 11, 0.5 ]])
    assert_kind_of Document, d
  end

  def test_create_should_accept_integer_as_feature_weight
    d = Document.create(0, 0.5, 1, 0, [[1, 0 ], [4, 0.0] , [10, 0.0] ,[ 11, 0.5 ]])
    assert_kind_of Document, d
  end

  def test_create_using_new
    d = Document.new({1 => 566.0, 4 => 133.0}, {docnum: 10, slackid: 1, queryid: 2, costfactor: 0.5}) 

    assert_equal 10, d.docnum
    assert_equal 1, d.slackid
    assert_equal 2, d.queryid
    assert_equal 0.5, d.costfactor
  end

  def test_should_be_able_to_access_properties
    d1 = Document.create(0, 0.5, 1, 0, [[1, 1.0 ], [10, 0.0 ], [20, 0.0], [21, 0.1 ]])
    d2 = Document.create(1, 0.6, 2, 1, [[1, 1.0 ], [30, 0.0 ], [40, 0.0], [41, 0.1 ]])

    assert_equal 0, d1.docnum
    assert_equal 1, d2.docnum

    assert_equal 1, d1.slackid
    assert_equal 2, d2.slackid

    assert_equal 0, d1.queryid
    assert_equal 1, d2.queryid

    assert_equal 0.5, d1.costfactor
    assert_equal 0.6, d2.costfactor
  end

  def test_all_word_numbers_should_be_greater_than_zero
    assert_raise(ArgumentError){ Document.create(0, 0.5, 1, 0, [[0, 1.0 ], [10, 0.0 ], [20, 0.0], [21, 0.1 ]]) }
    assert_raise(ArgumentError){ Document.create(1, 0.5, 1, 0, [[-1, 1.0 ], [30, 0.0 ], [40, 0.0], [41, 0.1 ]])}
  end

  def test_create_with_no_array
    assert_raise(TypeError) { Document.create(-1, 0, 1, 0, {})  }
  end

  def test_create_with_empty_array
    assert_raise(ArgumentError) { Document.create(-1, 0, 1, 0 [])}
  end
end

