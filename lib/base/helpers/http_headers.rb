#--
# Copyright (c) 2013 RightScale, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module RightScale
  module CloudApi

    # HTTP Headers container.
    #
    # The class makes it so that the headers always point to an array or values. It is a wrapper
    # around Hash class where all the keys are always arrays.
    #
    class HTTPHeaders < BlankSlate

      # Initializer.
      #
      # @param [Hash] headers A set of HTTP headers where keys are the headers names and the values
      # are the headers values.
      #
      def initialize(headers={})
        @headers = normalize(headers)
      end

      # Element reference.
      #
      # Retrieves the given headers values by the header name.
      #
      # @param [String] header The header name.
      #
      # @return [Array] The arrays of value(s).
      #
      def [](header)
        @headers[normalize_header(header)] || []
      end

      # Element assignment.
      #
      # Sets the header.
      #
      # @param [String]  header The header name.
      # @param [String,Array] value The new value(s).
      #
      def []=(header, value)
        value = normalize_value(value)
        if value.nil?
          delete(header)
        else
          @headers[normalize_header(header)] = value
        end
      end

      # Deletes the given header.
      #
      # @param [String] header The header name.
      #
      def delete(header)
        @headers.delete(normalize_header(header))
      end

      # Merges the new headers into the existent list.
      #
      # @param [Array] headers The new headers.
      #
      # @return [Hash] A new hash containing the result.
      #
      def merge(headers)
        @headers.merge(normalize(headers))
      end

      # Merges the new headers into the current hash.
      #
      # @param [Array] headers The new headers.
      #
      # @return [Hash] Updates the current object and returns the resulting hash.
      #
      def merge!(headers)
        @headers.merge!(normalize(headers))
      end

      # Set the given header unless it is set.
      #
      # If the curent headers list already has any value for the given header the method does nothing.
      #
      # @param [String] header The header name.
      # @param [String,Array] value The values to initialize the header with.
      #
      #
      def set_if_blank(header, value)
        self[header] = value if self[header].first._blank?
      end

      # Returns a new Hash instance with all the current headers.
      #
      # @return [Hash] A new Hash with the headers.
      #
      def to_hash
        @headers.dup
      end

      # Displays the headers in a nice way.
      #
      # @return [return] return_description
      #
      # @example
      #   ec2.response.headers.to_s #=>
      #    'content-type: "text/xml;charset=UTF-8", server: "AmazonEC2", something: ["a", "b"]'
      #
      def to_s
        @headers.to_a.map { |header, value| "#{header}: #{(value.size == 1 ? value.first : value).inspect}" } * ', '
      end

      # Feeds all the unknown methods to the undelaying hash object.
      #
      def method_missing(method_name, *args, &block)
        @headers.__send__(method_name, *args, &block)
      end

      # Makes it so that a header is always a downcased String instance.
      #
      # @param [String,Symbol] header The header name.
      #
      # @return [String] The normalized header name.
      #
      def normalize_header(header)
        header.to_s.downcase
      end
      private :normalize_header

      # Wraps the given value(s) into Array.
      #
      # @param [Array] value The original values.
      #
      # @return [String] The arrayified values or nil.
      #
      def normalize_value(value)
        value.nil? ? nil : Utils::arrayify(value)
      end
      private :normalize_value

      # The method normalizes the give hash and makes it so that all the keys are downcased
      # String instances and all the values are Arrays.
      #
      # @param [Hash] headers A hash of headers.
      #
      # @return [Hash] Returns a new hash with normilized keys and values.
      #
      def normalize(headers)
        result = {}
        headers.each do |header, value|
          header, value  = normalize_header(header), normalize_value(value)
          result[header] = value unless value.nil?
        end
        result
      end
      private :normalize
    end

  end
end