#--
# BibTeX-Ruby
# Copyright (C) 2010  Sylvester Keil <sylvester.keil.or.at>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

module BibTeX
  #
  # Represents a regular BibTeX entry.
  #
  class Entry < Element
    attr_reader :key, :type, :fields
   
    # Hash containing the required fields of the standard entry types
    @@RequiredFields = Hash.new([])
    @@RequiredFields.merge!({
      :article => [:author,:title,:journal,:year],
      :book => [[:author,:editor],:title,:publisher,:year],
      :booklet => [:title],
      :conference => [:author,:title,:booktitle,:year],
      :inbook => [[:author,:editor],:title,[:chapter,:pages],:publisher,:year],
      :incollection => [:author,:title,:booktitle,:publisher,:year],
      :inproceedings => [:author,:title,:booktitle,:year],
      :manual => [:title],
      :mastersthesis => [:author,:title,:school,:year],
      :misc => [],
      :phdthesis => [:author,:title,:school,:year],
      :proceedings => [:title,:year],
      :techreport => [:author,:title,:institution,:year],
      :unpublished => [:author,:title,:note]
    })

    # Creates a new instance of a given +type+ (e.g., :article, :book, etc.)
    # identified by a +key+.
    def initialize(type=nil, key=nil)
      self.key = key.to_s unless key.nil?
      self.type = type.to_sym unless type.nil?
      @fields = {}
    end

    # Sets the key of the entry
    def key=(key)
      raise(ArgumentError, "BibTeX::Entry key must be of type String; was: #{key.class.name}.") unless key.kind_of?(::String)
      @key = key
    end

    # Sets the type of the entry.
    def type=(type)
      raise(ArgumentError, "BibTeX::Entry type must be of type Symbol; was: #{type.class.name}.") unless type.kind_of?(Symbol)
      @type = type
    end
    
    # Returns the value of the field with the given name.
    def [](name)
      @fields[name.to_sym]
    end

    # Adds a new field (name-value pair) to the entry.
    # Returns the new value.
    def []=(name,value)
      add(name,value)
    end

    # Adds a new field (name-value pair) to the entry.
    # Returns the new value.
    def add(name,value)
      raise(ArgumentError, "BibTeX::Entry field name must be of type Symbol; was: #{name.class.name}.") unless name.kind_of?(Symbol)
      raise(ArgumentError, "BibTeX::Entry field value must be of type Array, Symbol, or String; was: #{value.class.name}.") unless [Array,::String,Symbol].map { |k| value.kind_of?(k) }.inject { |sum,n| sum || n }
      @fields[name] = value.kind_of?(Array) ? value : [value]
    end

    # Removes the field with a given name from the entry.
    # Returns the value of the deleted field; nil if the field was not set.
    def delete(name)
      @fields.delete(name.to_sym)
    end

    # Adds all the fields contained in a given hash to the entry.
    def <<(fields)
      raise(ArgumentError, "BibTeX::Entry fields must be of type Hash; was: #{fields.class.name}.") unless fields.kind_of?(Hash)
      fields.each { |n,v| add(n,v) }
      self
    end

    # Returns true if the entry currently contains no field.
    def empty?
      @fields.empty?
    end

    # Returns false if the entry is one of the standard entry types and does not have
    # definitions of all the required fields for that type.
    def valid?
      !@@RequiredFields[@type].map { |f|
        f.kind_of?(Array) ? !(f & @fields.keys).empty? : !@fields[f].nil?
      }.include?(false)
    end

    # Called when the element was added to a bibliography.
    def added_to_bibliography(bibliography)
      super(bibliography)
      bibliography.entries[@key] = self
      self
    end
    
    # Called when the element was removed from a bibliography.
    def removed_from_bibliography(bibliography)
      super(bibliography)
      bibliography.entries[@key] = nil
      self
    end

    # Replaces all constants in this string's value which are defined in +hsh+.
    def replace!(hsh)
      @fields.keys.each { |k| @fields[k] = StringReplacement.replace(@fields[k],hsh) }
    end

    # Returns a string of all the entry's fields.
    def content
      @fields.keys.map { |k| "#{k} = #{StringReplacement.to_s(@fields[k], :delimiter => ['{','}'])}" }.join(",\n")
    end

    # Returns a string representation of the entry.
    def to_s
      ["@#{type}{#{key},",content.gsub(/^/,'  '),'}'].join("\n")
    end
  end
end
