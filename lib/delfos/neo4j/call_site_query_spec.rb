# frozen_string_literal: true

require_relative "call_site_query"

module Delfos
  module Neo4j
    RSpec.describe CallSiteQuery do
      let(:step_number) { 0 }
      let(:stack_uuid) { "some-uuid" }
      let(:container_method_line_number) { 2 }
      let(:container_method_klass_name) { "A" }
      let(:called_method_klass_name) { "E" }
      let(:container_method) do
        double "ContainerMethod",
          klass_name: container_method_klass_name, # class A
          method_type: "ClassMethod",              #   def self.method_a    # called_method
          method_name: "method_a",                 #     E.new.method_e     # call site
          file: "a.rb",
          line_number: container_method_line_number
      end

      let(:call_site) do
        double "CallSite",      # class A
          file: "a.rb",         #   def self.method_a    # called_method
          line_number: 3,       #     E.new.method_e     # call site
          container_method: container_method,
          called_method: called_method
      end

      let(:called_method) do
        double "CalledCode",
          klass_name: called_method_klass_name, # class E
          method_type: "InstanceMethod",  #   def method_e        # m2
          method_name: "method_e",        #
          file: "e.rb",
          line_number: 2
      end

      subject { described_class.new(call_site, stack_uuid, step_number) }

      it "#params" do
        params = subject.params

        expect(params).to eq(
          "container_method_klass_name"  => "A",            # class A
          "container_method_type"        => "ClassMethod",  #   def self.method_a    # called_method
          "container_method_name"        => "method_a",     #     E.new.method_e     # call site
          "container_method_file"        => "a.rb",
          "container_method_line_number" => 2,

          "call_site_file"               => "a.rb",
          "call_site_line_number"        => 3,
          "stack_uuid"                   => stack_uuid,
          "step_number"                  => step_number,

          "called_method_klass_name"     => "E",              # class E
          "called_method_type"           => "InstanceMethod", #   def method_e        # m2
          "called_method_name"           => "method_e",
          "called_method_file"           => "e.rb",
          "called_method_line_number"    => 2,
        )
      end

      it "#query_for" do
        expect(subject.query).to eq described_class::BODY
      end

      context "with missing container method line number" do
        let(:container_method_line_number) { nil }

        it do
          expect(subject.query).to include "line_number: {container_method_line_number}"
          expect(subject.params.keys).to include "container_method_line_number"
          expect(subject.params["container_method_line_number"]).to eq(-1)
        end
      end
    end
  end
end
