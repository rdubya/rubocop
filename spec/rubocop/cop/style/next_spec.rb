# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::Next, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { {} }

  it 'finds all kind of loops with condition at the end of the iteration' do
    inspect_source(cop,
                   ['3.downto(1) do',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    '[].each do |o|',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    '[].each_with_object({}) do |o, a|',
                    '  if o == 1',
                    '    a[o] = {}',
                    '  end',
                    'end',
                    '',
                    'for o in 1..3 do',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    'loop do',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    '{}.map do |k, v|',
                    '  if v == 1',
                    '    puts k',
                    '  end',
                    'end',
                    '',
                    '3.times do |o|',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    'until false',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    'while true',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(9)
    expect(cop.offenses.map(&:line).sort).to eq([1, 7, 13, 19, 25, 31, 37, 43,
                                                 49])
    expect(cop.messages) .to eq(['Use `next` to skip iteration.'] * 9)
    expect(cop.highlights).to eq(%w(downto each each_with_object for loop map
                                    times until while))
  end

  it 'finds loop with condition at the end in different styles' do
    inspect_source(cop,
                   ['[].each do |o|',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    '[].each do |o|',
                    '  puts o',
                    '  if o == 1',
                    '    puts o',
                    '  end',
                    'end',
                    '',
                    '[].each do |o|',
                    '  unless o == 1',
                    '    puts o',
                    '  end',
                    'end'])

    expect(cop.offenses.size).to eq(3)
    expect(cop.offenses.map(&:line).sort).to eq([1, 7, 14])
    expect(cop.messages)
      .to eq(['Use `next` to skip iteration.'] * 3)
    expect(cop.highlights).to eq(['each'] * 3)
  end

  it 'ignores empty blocks' do
    inspect_source(cop,
                   ['[].each do', 'end',
                    '[].each { }'])
    expect(cop.offenses.size).to eq(0)
  end

  it 'ignores loops with conditional break' do
    inspect_source(cop,
                   ['loop do',
                    "  puts ''",
                    '  break if o == 1',
                    'end',
                    '',
                    'loop do',
                    '  break if o == 1',
                    'end',
                    '',
                    'loop do',
                    "  puts ''",
                    '  break unless o == 1',
                    'end',
                    '',
                    'loop do',
                    '  break unless o == 1',
                    'end'])
    expect(cop.offenses.size).to eq(0)
  end

  context 'EnforcedStyle: skip_modifier_ifs' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'skip_modifier_ifs' }
    end

    it 'ignores modifier ifs' do
      inspect_source(cop,
                     ['[].each do |o|',
                      '  puts o if o == 1',
                      'end',
                      '',
                      '[].each do |o|',
                      '  puts o unless o == 1',
                      'end'])

      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'EnforcedStyle: always' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'always' }
    end

    it 'ignores modifier ifs' do
      inspect_source(cop,
                     ['[].each do |o|',
                      '  puts o if o == 1',
                      'end',
                      '',
                      '[].each do |o|',
                      '  puts o unless o == 1',
                      'end'])

      expect(cop.offenses.size).to eq(2)
      expect(cop.offenses.map(&:line).sort).to eq([1, 5])
      expect(cop.messages)
        .to eq(['Use `next` to skip iteration.'] * 2)
      expect(cop.highlights).to eq(['each'] * 2)
    end
  end

  it 'ignores loops with conditions at the end with else' do
    inspect_source(cop,
                   ['[].each do |o|',
                    '  if o == 1',
                    '    puts o',
                    '  else',
                    "    puts 'no'",
                    '  end',
                    'end',
                    '',
                    '[].each do |o|',
                    '  puts o',
                    '  if o == 1',
                    '    puts o',
                    '  else',
                    "    puts 'no'",
                    '  end',
                    'end',
                    '',
                    '[].each do |o|',
                    '  unless o == 1',
                    '    puts o',
                    '  else',
                    "    puts 'no'",
                    '  end',
                    'end'])

    expect(cop.offenses.size).to eq(0)
  end

  it 'ignores loops with conditions at the end with ternary op' do
    inspect_source(cop,
                   ['[].each do |o|',
                    '  o == x ? y : z',
                    'end'
                   ])

    expect(cop.offenses.size).to eq(0)
  end
end
