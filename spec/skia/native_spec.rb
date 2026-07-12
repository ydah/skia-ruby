# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Skia::Native do
  describe '.user_native_dir' do
    it 'returns a platform-specific user data path' do
      path = described_class.user_native_dir(described_class.platform_library_names.last)

      expect(path).to include('skia-ruby', 'native')
    end
  end

  describe '.load_error_message' do
    it 'includes installation guidance and the original error' do
      message = described_class.load_error_message(LoadError.new('library missing'))

      expect(message).to include('library missing')
      expect(message).to include('bundle exec skia-install-native')
      expect(message).to include('SKIA_LIBRARY_PATH')
    end
  end
end
