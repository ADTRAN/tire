require 'rest_client'
require 'multi_json'
require 'active_model'
require 'hashr'
require 'cgi'

require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/hash/except.rb'

# Ruby 1.8 compatibility
require 'tire/rubyext/ruby_1_8' if defined?(RUBY_VERSION) && RUBY_VERSION < '1.9'

require 'tire/version'
require 'tire/rubyext/hash'
require 'tire/rubyext/symbol'
require 'tire/utils'
require 'tire/logger'
require 'tire/configuration'
require 'tire/http/response'
require 'tire/http/client'
require 'tire/search'
require 'tire/search/query'
require 'tire/search/queries/match'
require 'tire/search/sort'
require 'tire/search/facet'
require 'tire/search/filter'
require 'tire/search/highlight'
require 'tire/search/scan'
require 'tire/search/script_field'
require 'tire/multi_search'
require 'tire/count'
require 'tire/results/pagination'
require 'tire/results/collection'
require 'tire/results/item'
require 'tire/index'
require 'tire/alias'
require 'tire/dsl'
require 'tire/model/naming'
require 'tire/model/callbacks'
require 'tire/model/percolate'
require 'tire/model/indexing'
require 'tire/model/import'
require 'tire/model/search'
require 'tire/model/persistence/finders'
require 'tire/model/persistence/attributes'
require 'tire/model/persistence/storage'
require 'tire/model/persistence'
require 'tire/tasks'

module Tire
  extend DSL

  def warn(message)
    line = caller.detect { |line| line !~ %r|lib\/tire\/| }.sub(/:in .*/, '')
    STDERR.puts  "", "\e[31m[DEPRECATION WARNING] #{message}", "(Called from #{line})", "\e[0m"
  end
  module_function :warn
end


module RestClient
  def self.delete_with_payload(url, payload, headers={}, &block)
    Request.execute(:method => :delete, :url => url, :payload => payload, :headers => headers, &block)
  end
end
 
module Tire
  module HTTP
    module Client
      class RestClient
        # Allow data to be passed to delete
        def self.delete(url, data = nil)
          if data
            perform ::RestClient.delete_with_payload(url, data)
          else
            perform ::RestClient.delete(url)
          end
        rescue *ConnectionExceptions
          raise
        rescue ::RestClient::Exception => e
          Response.new e.http_body, e.http_code
        end
      end
    end
  end
 
  class Index
    # Removes items which match the query
    #
    # @see http://www.elasticsearch.org/guide/reference/api/delete-by-query.html
    # @example
    # {
    #   "bool": {
    #     "must": {
    #       "term":{"user_id":1}
    #     },
    #     "must": {
    #       "terms":{"uid":[12972, 12957, 12954]}
    #     }
    #   }
    # }
    def delete_by_query(&blk)
      raise ArgumentError.new('block not supplied') unless block_given?
      query = Tire::Search::Query.new(&blk)
      Configuration.client.delete("#{Configuration.url}/#{@name}/_query", query.to_json)
    end
  end
end
