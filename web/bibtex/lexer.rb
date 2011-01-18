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

require 'strscan'


module BibTeX
  
  #
  # The BibTeX::Lexer handles the lexical analysis of BibTeX bibliographies.
  #
  class Lexer

    attr_reader :src, :options, :stack
    
    #
    # Creates a new instance. Possible options and their respective
    # default values are:
    #
    # - :include => [:errors] A list that may contain :meta_comments, and
    #   :errors; depending on whether or not these are present, the respective
    #   tokens are included in the parse tree.
    # - :strict => true In strict mode objects can start anywhere; therefore
    #   the `@' symbol is not possible except inside literals or @comment
    #   objects; for a more lenient lexer set to false and objects are
    #   expected to start after a new line (leading white space is permitted).
    #
    def initialize(options={})
      @options = options
      @options[:include] ||= [:errors]
      @options[:strict] = true unless @options.has_key?(:strict)
      @src = nil
    end

    # Sets the source for the lexical analysis and resets the internal state.
    def src=(src)
      @stack = []
      @brace_level = 0
      @mode = :meta
      @active_object = nil
      @src = StringScanner.new(src)
      @line_breaks = []
      @line_breaks << @src.pos until @src.scan_until(/\n|$/).empty?
      @src.reset
    end

    # Returns the line number at a given position in the source.
    def line_number_at(index)
      # jb hack
      # (@line_breaks.find_index { |n| n >= index } || 0) + 1
      #@line_breaks.each_with_index {|n,i| return i+1 if n>=index}
      return 1
    end
    
    # Returns the next token from the parse stack.
    def next_token
      @stack.shift
    end

    def mode=(mode)
      Log.debug("Lexer: switching to #{mode} mode...")

      @active_object = case
        when [:comment,:string,:preamble,:entry].include?(mode) then mode
        when mode == :meta then nil
        else @active_object
      end

      @mode = mode
    end
    
    def mode
      @mode
    end

    # Returns true if the lexer is currenty parsing a BibTeX object.
    def bibtex_mode?
      [:bibtex,:comment,:string,:preamble,:entry].include?(self.mode)
    end
    
    # Returns true if the lexer is currently parsing meta comments.
    def meta_mode?
      self.mode == :meta
    end

    # Returns true if the lexer is currently parsing a braced-out expression.
    def content_mode?
      self.mode == :content
    end

    # Returns true if the lexer is currently parsing a string literal.
    def literal_mode?
      self.mode == :literal
    end
    
    # Returns true if the lexer is currently parsing the given object type.
    def is_active?(object)
      @active_object == object
    end
    
    # Pushes a value onto the parse stack.
    def push(value)
      case
      when ([:CONTENT,:STRING_LITERAL].include?(value[0]) && value[0] == @stack.last[0])
        @stack.last[1][0] << value[1]
        @stack.last[1][1] = line_number_at(@src.pos)
      when value[0] == :ERROR
        @stack.push(value) if @options[:include].include?(:errors)
        leave_object
      when value[0] == :META_COMMENT
        if @options[:include].include?(:meta_comments)
          value[1] = [value[1], line_number_at(@src.pos)]
          @stack.push(value)
        end
      else
        value[1] = [value[1], line_number_at(@src.pos)]
        @stack.push(value)
      end
      return self
    end

    # Start the lexical analysis.
    def analyse(src=nil)
      raise(ArgumentError, 'Lexer: failed to start analysis: no source given!') if src.nil? && @src.nil?
      Log.debug('Lexer: starting lexical analysis...')
      
      self.src = src || @src.string
      self.src.reset
      
      until self.src.eos?
        case
        when self.bibtex_mode?
          parse_bibtex
        when self.meta_mode?
          parse_meta
        when self.content_mode?
          parse_content
        when self.literal_mode?
          parse_literal
        end
      end
      
      Log.debug('Lexer: finished lexical analysis.')
      push [false, '$end']
    end

    def parse_bibtex
      case
      when self.src.scan(/[\t\r\n\s]+/o)
      when self.src.scan(/\{/o)
        @brace_level += 1
        push [:LBRACE,'{']
        if (@brace_level == 1 && is_active?(:comment)) || (@brace_level == 2 && is_active?(:entry))
          self.mode = :content
        end
      when self.src.scan(/\}/o)
        return error_unbalanced_braces if @brace_level < 1
        @brace_level -= 1
        push [:RBRACE,'}']
        leave_object if @brace_level == 0
      when self.src.scan( /=/o)
        push [:EQ,'=']
      when self.src.scan(/,/o)
        push [:COMMA,',']
      when self.src.scan(/#/o)
        push [:SHARP,'#']
      when self.src.scan(/\d+/o)
        push [:NUMBER,self.src.matched]
      when self.src.scan(/[a-z\d:_!$\.%&*-]+/io)
        push [:NAME,self.src.matched]
      when self.src.scan(/"/o)
        self.mode = :literal
      when self.src.scan(/@/o)
        error_unexpected_token
        enter_object
      when self.src.scan(/./o)
        error_unexpected_token
        enter_object
      end
    end
    
    def parse_meta
      match = self.src.scan_until(@options[:strict] ? /@[\t ]*/o : /(^|\n)[\t ]*@[\t ]*/o)
      unless self.src.matched.nil?
        push [:META_COMMENT, match.chop]
        enter_object
      else
        push [:META_COMMENT,self.src.rest]
        self.src.terminate
      end
    end

    def parse_content
      match = self.src.scan_until(/\{|\}/o)
      case self.src.matched
      when '{'
        @brace_level += 1
        push [:CONTENT,match]
      when '}'
        @brace_level -= 1
        case
        when @brace_level < 0
          push [:CONTENT,match.chop]
          error_unbalanced_braces
        when @brace_level == 0
          push [:CONTENT,match.chop]
          push [:RBRACE,'}']
          leave_object
        when @brace_level == 1 && is_active?(:entry)
          push [:CONTENT,match.chop]
          push [:RBRACE,'}']
          self.mode = :bibtex
        else
          push [:CONTENT, match]
        end
      else
        push [:CONTENT,self.src.rest]
        self.src.terminate
        error_unterminated_content
      end
    end
    
    def parse_literal
      match = self.src.scan_until(/[\{\}"\n]/o)
      case self.src.matched
      when '{'
        @brace_level += 1
        push [:STRING_LITERAL,match]
      when '}'
        @brace_level -= 1
        if @brace_level < 1
          push [:STRING_LITERAL,match.chop]
          error_unbalanced_braces
        else
          push [:STRING_LITERAL,match]
        end
      when '"'
        if @brace_level == 1
          push [:STRING_LITERAL,match.chop]
          self.mode = :bibtex
        else
          push [:STRING_LITERAL,match]
        end
      when "\n"
        push [:STRING_LITERAL,match.chop]
        error_unterminated_string
      else
        push [:STRING_LITERAL,self.src.rest]
        self.src.terminate
        error_unterminated_string
      end
    end
    
    # Called when the lexer encounters a new BibTeX object.
    def enter_object
      @brace_level = 0
      self.mode = :bibtex
      push [:AT,'@']

      case
      when self.src.scan(/string/io)
        self.mode = :string
        push [:STRING, self.src.matched]
      when self.src.scan(/preamble/io)
        self.mode = :preamble
        push [:PREAMBLE, self.src.matched]
      when self.src.scan(/comment/io)
        self.mode = :comment
        push [:COMMENT, self.src.matched]
      when self.src.scan(/[a-z\d:_!\.$%&*-]+/io)
        self.mode = :entry
        push [:NAME, self.src.matched]
      end
    end

    # Called when parser leaves a BibTeX object.
    def leave_object
      self.mode = :meta
      @brace_level = 0
    end


    def error_unbalanced_braces
      n = line_number_at(self.src.pos)
      Log.warn("Lexer: unbalanced braces on line #{n}; brace level #{@brace_level}; mode #{@mode.inspect}.")
      backtrace [:E_UNBALANCED_BRACES, [self.src.matched,n]]
    end
    
    def error_unterminated_string
      n = line_number_at(self.src.pos)
      Log.warn("Lexer: unterminated string on line #{n}; brace level #{@brace_level}; mode #{@mode.inspect}.")
      backtrace [:E_UNTERMINATED_STRING, [self.src.matched,n]]
    end

    def error_unterminated_content
      n = line_number_at(self.src.pos)
      Log.warn("Lexer: unterminated content on line #{n}; brace level #{@brace_level}; mode #{@mode.inspect}.")
      backtrace [:E_UNTERMINATED_CONTENT, [self.src.matched,n]]
    end
    
    def error_unexpected_token
      n = line_number_at(self.src.pos)
      Log.warn("Lexer: unexpected token `#{self.src.matched}' on line #{n}; brace level #{@brace_level}; mode #{@mode.inspect}.")
      backtrace [:E_UNEXPECTED_TOKEN, [self.src.matched,n]]
    end
    
    def backtrace(error)
      trace = []
      trace.unshift(@stack.pop) until @stack.empty? || (!trace.empty? && [:AT,:META_COMMENT].include?(trace[0][0]))
      trace << error
      push [:ERROR,trace]
    end

  end
  
end
