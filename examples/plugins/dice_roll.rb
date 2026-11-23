# frozen_string_literal: true

require_relative "../settings"

class DiceRoll
  include Cinch::Plugin

  # !roll [[repeats#]rolls]d<sides>[+/-offset]
  match(/roll (?:(?:(\d+)#)?(\d+))?d(\d+)([+-]\d{1,6})?\z/)

  def execute(m, repeats, rolls, sides, offset)
    count = (repeats || "1").to_i * (rolls || "1").to_i
    sides = sides.to_i
    unless count.between?(1, 100) && sides.between?(1, 10_000)
      m.reply "Use 1–100 dice with 1–10,000 sides."
      return
    end

    total = count.times.sum { rand(1..sides) + offset.to_i }
    m.reply "Your dice roll was: #{total}", true
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    ExampleSettings.configure(c, "irc_dice")
    c.plugins.plugins = [DiceRoll]
  end
end

bot.start
