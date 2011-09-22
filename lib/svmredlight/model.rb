module SVMLight
  
  class MissingModelFile < StandardError;end

  # A model is the product of training a SVM, once created it can take documents as inputs
  # and act of them (by for instance classifying them). Models can also be read from files
  # created by svm_learn.
  class Model
    TYPES = [:classification]

    # Learns a model from a set of labeled documents.
    # @param [Symbol] type, what kind of model is this, classification, regression, etc. for now the only valid value is classification.
    # @param [Array] documents_and_lables documents and labels is an array of arrays where each inner array must have two elements, the first, a Document and the second a classification (normally +1 and  -1)
    # @param [Hash] learn_params each key of learn_params is a string it that maps to a field of the LEARN_PARM struct in SVMLight
    # @param [Hash] kernel_params each key of kernel_params is a string it that maps to a field of the KERNEL_PARM struct in SVMLight
    # @param [Array|Nil] alphas an array of alpha values 
    def self.new(type, documents_and_lables, learn_params, kernel_params, alphas = nil )
      raise ArgumentError, "Supporte types are (for now) #{TYPES}" unless TYPES.include? type

      learn_classification(documents_and_lables, learn_params, kernel_params, false, alphas)
    end
    private_class_method :learn_classification
    private_class_method :from_file


    # Will load an existen model from a file
    # @param [String] pahtofile path to the model file 
    def self.read_from_file(pahtofile)

      # This is an antipattern, checking for existence of resoruces is normally somethig to be avoided, trying to open
      # and rescuing the exception/reading the error code is a much better practice, however SVMLight will call exit(1)
      # if the file does not exists and that in turn will kill the ruby VM, so in this case to minimize that possibility
      # I'm optimistically check for the file existence and hope it is still there when it is actually open, in the end
      # reimplementing the whole thing in C would be better.
      if File.exists?(pahtofile) && File.file?(pahtofile) 
        from_file(pahtofile)
      else
        raise MissingModelFile, "the #{pahtofile} does not exists or is not a file"
      end

    end

  end
end
