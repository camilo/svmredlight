require './test/helper'
include SVMLight

class TestDocument < Test::Unit::TestCase

  context "creating a new document" do
    
    should "succed when using #create" do
      d = Document.create(0, 0.5, 1, 0, [[1, 1.0 ], [4, 0.0] , [10, 0.0] ,[ 11, 0.5 ]])
      assert_kind_of Document, d
    end

    should "accept integers as feature weights" do 
      d = Document.create(0, 0.5, 1, 0, [[1, 0 ], [4, 0.0] , [10, 0.0] ,[ 11, 0.5 ]])
      assert_kind_of Document, d
    end

    should "create documents useing new as well" do
      d = Document.new({1 => 566.0, 4 => 133.0}, {docnum: 10, slackid: 1, queryid: 2, costfactor: 0.5}) 

      assert_equal 10, d.docnum
      assert_equal 1, d.slackid
      assert_equal 2, d.queryid
      assert_equal 0.5, d.costfactor
    end

    should "raise argument error if any of the word numbers is less or equal to 0" do 
      assert_raise(ArgumentError){ Document.create(0, 0.5, 1, 0, [[0, 1.0 ], [10, 0.0 ], [20, 0.0], [21, 0.1 ]]) }
      assert_raise(ArgumentError){ Document.create(1, 0.5, 1, 0, [[-1, 1.0 ], [30, 0.0 ], [40, 0.0], [41, 0.1 ]])}
    end

    should "raise type error when the fourth argument is not an array" do
      assert_raise(TypeError) { Document.create(-1, 0, 1, 0, {})  }
    end

    should "raise type error when the fourth argument is empty" do
      assert_raise(ArgumentError) { Document.create(-1, 0, 1, 0 [])}
    end

  end
  
  context 'a document' do
    should "have accessible docnum, queryid, slackid, and, costfacor" do
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
  end
end

