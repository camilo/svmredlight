module SVMLight
  
  class MissingModelFile < StandardError; end

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
    
    # in self.read_from_file and #write_to_file
    #
    # This is an anti-pattern. Checking for existence of resources is normally something to be avoided. Trying to open
    # the resource and then rescuing the exception/reading the error code is a much better practice, however SVMLight
    # will call exit(1) if the file does not exists, and, that in turn will kill the ruby VM, so in this case to
    # minimize that possibility I'm optimistically check for the file existence and hope it is still there when it is
    # actually time to open it.
    #
    # TODO: Come up with a proper replacement for those methods, probably simply reimplementing them in svmredlight.c 
    # and raising an exception when files cannot be open.

    # Will load an existen model from a file
    # @param [String] pahtofile path to the model file 
    def self.read_from_file(pahtofile)
      if File.exists?(pahtofile) && File.file?(pahtofile) 
        from_file(pahtofile)

      else

        raise MissingModelFile, "the #{pahtofile} does not exists or is not a file"
      end

    end

    private :to_file

    def write_to_file(pahtofile)
      dir = File.dirname(pahtofile)

      if File.directory?(dir) && File.writable?(dir)
        to_file(pahtofile)

      else
        raise ModelWriteError, "impossible to write #{pahtofile}" 

      end
    end



  end
end
