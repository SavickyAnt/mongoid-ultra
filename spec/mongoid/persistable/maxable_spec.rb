# frozen_string_literal: true

require 'spec_helper'

describe Mongoid::Persistable::Maxable do

  describe '#set_max' do

    shared_examples_for 'a max-able interface' do
      context 'when the document is a root document' do
        let(:initial_name) { 'Manhattan Transfer' }
        let(:initial_members) { 4 }
        let(:initial_founded) { Date.new(1972, 10, 1) }

        let(:band) do
          Band.create!(
            name: initial_name,
            member_count: initial_members,
            founded: initial_founded
          )
        end

        shared_examples_for 'a max-able root document' do
          before do
            band.send(max_method,
                      name: given_name,
                      member_count: given_members,
                      founded: given_founded)
          end

          it 'sets the fields to larger of current vs. given' do
            expect(band.reload.name).to eq [initial_name, given_name].max
            expect(band.member_count).to eq [initial_members, given_members].max
            expect(band.founded).to eq [initial_founded, given_founded].max
          end

          it 'resets dirty changes' do
            expect(band).to_not be_changed
          end
        end

        context 'when given < initial' do
          let(:given_name) { 'A' }
          let(:given_members) { 3 }
          let(:given_founded) { Date.new(1970, 1, 1) }

          it_behaves_like 'a max-able root document'
        end

        context 'when given == initial' do
          let(:given_name) { initial_name }
          let(:given_members) { initial_members }
          let(:given_founded) { initial_founded }

          it_behaves_like 'a max-able root document'
        end

        context 'when given > initial' do
          let(:given_name) { 'Z' }
          let(:given_members) { 10 }
          let(:given_founded) { Date.today }

          it_behaves_like 'a max-able root document'
        end
      end

      context 'when the document is an embedded document' do
        let(:initial_city) { 'Manhattan' }
        let(:initial_number) { 100 }
        let(:initial_end_date) { Date.today }

        let(:person) { Person.create! }
        let(:address) do
          person.addresses.create!(
            city: initial_city,
            number: initial_number,
            end_date: initial_end_date
          )
        end

        shared_examples_for 'a max-able embedded document' do
          before do
            address.send(max_method,
                         city: given_city,
                         number: given_number,
                         end_date: given_end_date)
          end

          it 'sets the fields to smaller of current vs. given' do
            expect(address.reload.city).to eq [initial_city, given_city].max
            expect(address.number).to eq [initial_number, given_number].max
            expect(address.end_date).to eq [initial_end_date, given_end_date].max
          end

          it 'resets dirty changes' do
            expect(address).to_not be_changed
          end
        end

        context 'when given < initial' do
          let(:given_city) { 'A' }
          let(:given_number) { 10 }
          let(:given_end_date) { 5.days.ago.to_date }

          it_behaves_like 'a max-able embedded document'
        end

        context 'when given == initial' do
          let(:given_city) { initial_city }
          let(:given_number) { initial_number }
          let(:given_end_date) { initial_end_date }

          it_behaves_like 'a max-able embedded document'
        end

        context 'when given > initial' do
          let(:given_city) { 'Z' }
          let(:given_number) { 1000 }
          let(:given_end_date) { 5.days.from_now.to_date }

          it_behaves_like 'a max-able embedded document'
        end
      end

      context 'when executing atomically' do
        let(:band) { Band.create!(member_count: 10, name: 'Manhattan Transfer') }

        it 'marks a dirty change for the modified fields' do
          band.atomically do
            band.send(max_method, member_count: 15, name: 'Manhattan Transfer')
            expect(band.changes)
              .to eq({ 'member_count' => [10, 15] })
          end
        end
      end
    end

    context 'as itself' do
      let(:max_method) { :set_max }

      it_behaves_like 'a max-able interface'
    end

    context 'as #clamp_lower_bound' do
      let(:max_method) { :clamp_lower_bound }

      it_behaves_like 'a max-able interface'
    end
  end
end
