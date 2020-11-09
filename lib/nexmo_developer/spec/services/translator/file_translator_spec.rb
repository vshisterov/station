require 'rails_helper'

RSpec.describe Translator::FileTranslator do
  let(:doc_path) { 'voice/voice-api/guides/numbers.md' }

  subject { described_class.new(doc_path) }

  it 'accepts a documentation path to initialize an instance' do
    expect(subject.doc_path).to eql(doc_path)
  end

  describe '#frontmatter' do
    it 'loads the document metadata correctly' do
      expect(subject.frontmatter).to include('translation_frequency' => 13)
    end
  end

  describe '#translation_requests' do
    it 'returns an array of Translator::TranslationRequest instances' do
      requests = subject.translation_requests

      expect(requests).to all(be_a(Translator::TranslationRequest))
      expect(requests.map(&:locale).uniq).to match_array(['zh-CN', 'ja-JP'])
    end
  end

  describe '#frequency' do
    it 'returns the translation frequency from the document if it exists' do
      expect(subject.frequency).to be(13)
    end

    it 'returns the translation frequency from the products config if its not present in the document' do
      translator = described_class.new('messaging/sms/overview.md')

      expect(translator.frequency).to be(15)
    end

    it 'raises an exception if translation frequency cannot be found in either document or products config' do
      translator = described_class.new('vonage-business-cloud/vbc-apis/user-api/overview.md')

      expect { translator.frequency }.to raise_error(ArgumentError, "Expected a 'translation_frequency' attribute for VBC User API but none found")
    end
  end

  describe '#product_translation_frequency' do
    it 'finds the matching product translation frequency in the products config YAML file' do
      expect(subject.product_translation_frequency).to eql(15)
    end
  end

  describe '#product' do
    let(:doc_path) { 'messaging/tiktok/overview.md' }

    it 'raises an exception if there isn\'t a product associated' do
      expect { subject.product }.to raise_error(ArgumentError, 'Unable to match document with products list in config/products.yml')
    end

    it 'returns the corresponding product' do
      product = described_class.new('messaging/sms/overview.md').product
      expect(product).to include('name' => 'SMS API', 'translation_frequency' => 15)
    end
  end

  describe '#full_path' do
    it 'returns a complete file path for the partial path provided' do
      expect(subject.full_path).to eql("#{Rails.configuration.docs_base_path}/_documentation/en/#{doc_path}")
    end
  end
end