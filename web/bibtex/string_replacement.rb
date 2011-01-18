#--
# BibTeX-Ruby
# Copyright (C) 2010  Sylvester Keil <http://sylvester.keil.or.at>
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
  # This module contains functions to manipulate BibTeX
  # string literals.
  module StringReplacement
    
    # Returns a string representation of the literal.
    def self.to_s(value,options={})
      return if value.nil?
      options[:delimiter] ||= ['"','"']
      #options[:delimiter] ||= ['{','}']

      if value.empty? || (value.length == 1 && !value[0].kind_of?(Symbol))
        [options[:delimiter][0],value,options[:delimiter][1]].join
      else
        value.map { |s| s.kind_of?(Symbol) ? s.to_s : s.inspect}.join(' # ')
      end
    end

    # Replaces all string constants in +value+ which are defined in +hsh+.
    def self.replace(value,hsh)
      return if value.nil?
      value.map { |s| s.kind_of?(Symbol) && hsh.has_key?(s) ? hsh[s] : s }.flatten
    end
  end
end
