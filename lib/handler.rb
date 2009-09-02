module Handler
	
  ##
  # Included hook: extend including class.
  #
  def self.included(base)
    base.extend ClassMethods
  end
  
  
  module ClassMethods
  
    ##
    # Declare that a model generates a handle based on a given attribute or
    # method. Options include:
    # 
    # <tt>:separator</tt> - character to place between words
    # <tt>:store</tt> - attribute in which to store handle
    #
    def handle_based_on(attribute, options = {})
      options[:separator] ||= "_"
      options[:write_to]  ||= :handle

	    ##
	    # Generate a URL-friendly name.
	    #
      define_method :generate_handle do
        str = send(attribute)
        return nil unless str.is_a?(String)
        str = str.downcase.strip.gsub('&', ' and ') # add space for, e.g., "Y&T"
        str = str.delete('.\'"') # no space
        str = str.gsub(/\W/, ' ') # space
        str.gsub(/ +/, options[:separator])
      end
      
      ##
      # Assign the generated handle to the specified attribute.
      #
      define_method :assign_handle do
        write_attribute(options[:write_to], generate_handle)
      end
    end
  end
end
