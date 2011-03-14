module Handler

  ##
  # Included hook: extend including class.
  #
  def self.included(base)
    base.extend ClassMethods
  end

  ##
  # Transliterate a string: change accented Unicode characters to ASCII
  # approximations. Tries several methods, attempting the best first:
  #
  # 1. unidecode, if installed (http://rubyforge.org/projects/unidecode)
  # 2. iconv (included with Ruby, doesn't work with all Ruby versions)
  # 3. normalize, then remove un-normalizable characters
  #
  def self.transliterate(string)
    transliterate_with_unidecode(string) or
      transliterate_with_iconv(string) or
      transliterate_with_normalization(string) or
      string
  end

  ##
  # Transliterate a string with the unidecode library.
  # Return nil if unsuccessful (eg, library not available).
  #
  def self.transliterate_with_unidecode(string)
    begin
      require 'unidecode'
      string.to_ascii
    rescue LoadError
      nil
    end
  end

  ##
  # Transliterate a string with the iconv library.
  # Return nil if unsuccessful (eg, library not available).
  #
  def self.transliterate_with_iconv(string)
    begin
      Iconv.iconv('ascii//ignore//translit', 'utf-8', string).to_s
    rescue
      nil
    end
  end

  ##
  # Transliterate a string using multibyte normalization,
  # then remove remaining non-ASCII characters. Taken from
  # <tt>ActiveSupport::Inflector.transliterate</tt>.
  #
  def self.transliterate_with_normalization(string)
    string.mb_chars.normalize.gsub(/[^\x00-\x7F]+/, '').to_s
  end

  ##
  # Generate a handle from a string.
  #
  def self.generate_handle(title, separator)
    str = title
    return nil unless str.is_a?(String)
    str = transliterate(str).to_s
    str = str.downcase
    str = str.strip
    str = str.gsub('&', ' and ') # add space for, e.g., "Y&T"
    str = str.delete('.\'"')     # no space
    str = str.gsub(/\W/, ' ')    # space
    str = str.strip
    str = str.gsub(/ +/, separator)
    str
  end

  ##
  # Get the next handle in the sequence (for avoiding duplicates).
  #
  def self.next_handle(handle, separator)
    if handle =~ /#{separator}\d+$/
      handle.sub(/\d+$/){ |i| i.to_i + 1 }
    else
      handle + separator + "2"
    end
  end

  module ClassMethod

    ##
    # Declare that a model generates a handle based on
    # a given attribute or method. Options include:
    #
    # <tt>:separator</tt> - character to place between words
    # <tt>:store</tt> - attribute in which to store handle
    # <tt>:unique</tt> - generate a handle which is unique among all records
    #
    def handle_based_on(attribute, options = {})
      options[:separator] ||= "_"
      options[:write_to]  ||= :handle
      options[:unique]      = true if options[:unique].nil?

      ##
      # Generate a URL-friendly name.
      #
      define_method :generate_handle do
        h = Handler.generate_handle(send(attribute), options[:separator])
        if options[:unique]

          # generate a condition for finding an existing record with a
          # given handle
          find_dupe = lambda{ |h|
            conds = ["#{options[:write_to]} = ?", h]
            unless new_record?
              conds[0] << " AND id != ?"
              conds << id
            end
            conds
          }

          # increase number while *other* records exist with the same handle
          # (record might be saved and should keep its handle)
          while self.class.all(:conditions => find_dupe.call(h)).size > 0
            h = Handler.next_handle(h, options[:separator])
          end
        end
        h
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

ActiveRecord::Base.class_eval{ include Handler }
