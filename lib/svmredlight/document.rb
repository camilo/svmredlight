module SVMLight
  # A document is the Ruby representation of a DOC structure in SVMlight, it contains a
  # queryid, a slackid, a costfactor ( c ) and a vector with feature numbers and their
  # correspondent weights.
  class Document
    
    # @param [Hash] vector a hash where the keys are feature numbers and the values its weights
    # @param [Hash] opts the options coincide with SVMLight parameters to the create_example function, the default values for all the options are 0
    # @option [:docnum] Numeric docum
    # @option [:costfactor] Numeric costfactor
    # @option [:slackid] Numeric slackid
    # @option [:queryid] Numeric queryid
    def self.new(vector, opts={})
      opts.default = 0
      docnum     = opts[:docnum]
      costfactor = opts[:costfactor]
      slackid    = opts[:slackid] 
      queryid    = opts[:queryid] 

      create(docnum, costfactor, slackid, queryid, vector.to_a)
    end
  end
end
