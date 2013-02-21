require 'csv'

module Tire
  module Model
    module Exportable

      def self.included(base)
        base.class_eval do
          def self.export(options = {})
            path = options.delete(:path) || "#{self.name}_#{Time.now.to_i}.csv"

            total = self.all.total
            current = 0
            attributes = self.properties

            File.open(path, 'w') do |f|
              page = 1
              while current < total
                f << CSV.generate(options) do |csv|
                  csv << attributes if current == 0
                  search('*', page: page, per_page: 1000).each do |entry|
                    csv << attributes.map{|attribute| entry.send(attribute)}
                    current += 1
                  end
                end
                page += 1
              end
            end
          end
        end
      end
    end
  end
end