# frozen_string_literal: true

require 'spec_helper'

describe 'i18n fallbacks' do
  with_i18n_fallbacks

  context 'when fallbacks are enabled with a locale list' do
    with_default_i18n_configs

    before do
      I18n.fallbacks[:de] = [:en]
    end

    context 'when translation is present in active locale' do
      it 'uses active locale' do
        product = Product.new
        I18n.locale = :de
        product.description = 'Marvelous in German'
        I18n.locale = :en
        product.description = 'Marvelous!'
        I18n.locale = :de
        expect(product.description).to eq('Marvelous in German')
      end
    end

    context 'when translation is missing in active locale and present in fallback locale' do
      it 'falls back on default locale' do
        product = Product.new
        I18n.locale = :en
        product.description = 'Marvelous!'
        I18n.locale = :de
        expect(product.description).to eq('Marvelous!')
      end
    end

    context 'when translation is missing in all locales' do
      it 'returns nil' do
        product = Product.new
        I18n.locale = :en
        product.description = 'Marvelous!'
        I18n.locale = :ru
        expect(product.description).to eq nil
      end
    end
  end
end
