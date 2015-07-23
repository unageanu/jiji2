# coding: utf-8

require 'jiji/test/test_configuration'

describe Jiji::Utils::Strings do

  describe '#mask' do
    it '空文字' do
      expect(Jiji::Utils::Strings.mask('')).to eq ''
    end
    it 'nil' do
      expect(Jiji::Utils::Strings.mask(nil)).to eq ''
    end
    it 'a' do
      expect(Jiji::Utils::Strings.mask('a')).to eq 'x'
      expect(Jiji::Utils::Strings.mask('a', 2)).to eq 'x'
    end
    it 'aa' do
      expect(Jiji::Utils::Strings.mask('aa')).to eq 'ax'
      expect(Jiji::Utils::Strings.mask('aa', 2)).to eq 'xx'
    end
    it 'aaaaa' do
      expect(Jiji::Utils::Strings.mask('aaaaa')).to eq 'axxxx'
      expect(Jiji::Utils::Strings.mask('aaaaa', 2)).to eq 'aaxxx'
      expect(Jiji::Utils::Strings.mask('aaaaa', 3)).to eq 'aaaxx'
    end
    it 'あ' do
      expect(Jiji::Utils::Strings.mask('あ')).to eq 'x'
      expect(Jiji::Utils::Strings.mask('あ', 2)).to eq 'x'
    end
    it 'ああ' do
      expect(Jiji::Utils::Strings.mask('ああ')).to eq 'あx'
      expect(Jiji::Utils::Strings.mask('ああ', 2)).to eq 'xx'
    end
    it 'あああああ' do
      expect(Jiji::Utils::Strings.mask('あああああ')).to eq 'あxxxx'
      expect(Jiji::Utils::Strings.mask('あああああ', 2)).to eq 'ああxxx'
      expect(Jiji::Utils::Strings.mask('あああああ', 3)).to eq 'あああxx'
    end

  end
end
