# frozen_string_literal: true

ENV["NEO4J_HOST"]     ||= "http://localhost"
ENV["NEO4J_PORT"]     ||= "7476"
ENV["NEO4J_USERNAME"] ||= "neo4j"
ENV["NEO4J_PASSWORD"] ||= "password"

module DelfosSpecNeo4jHelpers
  extend self

  def wipe_db!
    require "delfos/neo4j"
    Delfos.setup_neo4j!

    perform_query "MATCH (m)-[rel]->(n) DELETE m, rel, n"
    perform_query "MATCH (m) DELETE m"
  end

  def perform_query(q)
    Delfos::Neo4j.execute_sync(q)
  end
end

# rubocop:disable Metrics/BlockLength
RSpec.configure do |c|
  c.include DelfosSpecNeo4jHelpers

  c.before(:suite) do
    require "delfos/neo4j/query_execution/errors"
    begin
      DelfosSpecNeo4jHelpers.wipe_db!
    rescue *Delfos::Neo4j::QueryExecution::HTTP_ERRORS,
           Delfos::Neo4j::QueryExecution::ConnectionError => e
      puts <<-ERROR
       ***************************************
       ***************************************
       ***************************************

       Failed to connect to Neo4j:
         #{e}

       Neo4j config:
         #{Delfos.neo4j}

       Start Neo4j or set the following environment variables:
         NEO4J_HOST
         NEO4J_PORT
         NEO4J_USERNAME
         NEO4J_PASSWORD

       ***************************************
       ***************************************
       ***************************************
      ERROR
      exit(-1)
    end

    Delfos::Neo4j.ensure_schema!
  end

  c.after(:suite) do
    require "delfos/neo4j"

    begin
      Delfos::Neo4j.flush!
    rescue Delfos::Neo4j::QueryExecution::ExpiredTransaction
      Delfos.logger.debug "rescuing expired transaction"
    end
  end
end
