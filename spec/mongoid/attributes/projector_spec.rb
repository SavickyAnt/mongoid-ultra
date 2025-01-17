# frozen_string_literal: true

require 'spec_helper'

describe Mongoid::Attributes::Projector do
  Dir[File.join(File.dirname(__FILE__), 'projector_data', '*.yml')].sort.each do |path|
    context File.basename(path) do
      specs = YAML.safe_load(File.read(path), aliases: true)

      specs.each do |spec|
        context spec['name'] do

          pending spec['pending'].to_s if spec['pending']

          let(:projection) do
            spec['projection']
          end

          let(:projector) do
            Mongoid::Attributes::Projector.new(projection)
          end

          spec.fetch('queries').each do |query_spec|
            context query_spec.fetch('query').inspect do
              let(:query) { query_spec['query'] }

              context 'attribute_or_path_allowed?' do
                it "is #{query_spec.fetch('allowed')}" do
                  expect(projector.attribute_or_path_allowed?(query)).to be query_spec['allowed']
                end
              end
            end
          end
        end
      end
    end
  end
end
