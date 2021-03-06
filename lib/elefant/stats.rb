require "elefant/connection_adapter"
require "elefant/postgres/stat_queries"
require "elefant/postgres/size_queries"

module Elefant
  class Stats
    include Elefant::Postgres::StatQueries
    include Elefant::Postgres::SizeQueries

    def initialize
      @connection = Elefant::ConnectionAdapter.new
    end

    def db_name
      @connection.info[:db_name]
    end

    def version
      @connection.info[:server_version]
    end

    def client_version
      @connection.info[:client_version]
    end

    def get(name, params)
      query(name, params)
    end

    def close!
      @connection.disconnect
    end

    def self.check!
      connection = Elefant::ConnectionAdapter.new
      raise ArgumentError.new("Could not establish connection") unless connection.alive?
      connection.disconnect
    end

    private

    def exec(query, params = [])
      @connection.execute(query, params)
    end

    def query(name, params)
      method = name.to_sym

      if respond_to?(method)
        send(method, *params)
      else
        raise ArgumentError.new("Unknown Stats Query: #{name}")
      end
    end
  end
end
