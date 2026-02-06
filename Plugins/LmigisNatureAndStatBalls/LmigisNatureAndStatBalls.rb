#===============================================================================
# Nature and Stat Balls
# Created by Lmigi
# Allows Poké Balls that set natures or max EVs on catch.
#===============================================================================

module NatureAndStatBalls
  module_function
  #------------------------------------------------------------------------
  # Set a Pokémon's nature
  #------------------------------------------------------------------------
  def set_nature!(pkmn, nature)
    pkmn.nature = nature
  end

  #------------------------------------------------------------------------
  # Set a Pokémon's stats EVs to max in a single stat
  #------------------------------------------------------------------------
  def max_single_ev!(pkmn, stat_id, max_ev = 252)
    GameData::Stat.each_main do |s|
      pkmn.ev[s.id] = 0
    end
    pkmn.ev[stat_id] = max_ev
    pkmn.calc_stats
    pkmn.hp = pkmn.totalhp if pkmn.hp > pkmn.totalhp || pkmn.hp <= 0
  end
end

#===============================================================================
# EV Balls 
# - On catch: sets the caught Pokémon's EVs to max for related stat.
#===============================================================================
EV_BALLS = {
  :HPEVBALL  => :HP,
  :ATKEVBALL => :ATTACK,
  :DEFEVBALL => :DEFENSE,
  :SPAEVBALL => :SPECIAL_ATTACK,
  :SPDEVBALL => :SPECIAL_DEFENSE,
  :SPEEVBALL => :SPEED
}

EV_BALLS.each do |ball_id, stat_id|
  Battle::PokeBallEffects::OnCatch.add(ball_id, proc { |ball, battle, pkmn|
    NatureAndStatBalls.max_single_ev!(pkmn, stat_id, 252)
  })
end

#===============================================================================
#  Nature Balls
# - On catch: sets the caught Pokémon's nature to a specific nature
#===============================================================================
NATURE_BALLS = {
  :HARDYBALL   => :HARDY,
  :LONELYBALL  => :LONELY,
  :BRAVEBALL   => :BRAVE,
  :ADAMANTBALL => :ADAMANT,
  :NAUGHTYBALL => :NAUGHTY,

  :BOLDBALL    => :BOLD,
  :DOCILEBALL  => :DOCILE,
  :RELAXEDBALL => :RELAXED,
  :IMPISHBALL  => :IMPISH,
  :LAXBALL     => :LAX,

  :TIMIDBALL   => :TIMID,
  :HASTYBALL   => :HASTY,
  :SERIOUSBALL => :SERIOUS,
  :JOLLYBALL   => :JOLLY,
  :NAIVEBALL   => :NAIVE,

  :MODESTBALL  => :MODEST,
  :MILDBALL    => :MILD,
  :QUIETBALL   => :QUIET,
  :BASHFULBALL => :BASHFUL,
  :RASHBALL    => :RASH,

  :CALMBALL    => :CALM,
  :GENTLEBALL  => :GENTLE,
  :SASSYBALL   => :SASSY,
  :CAREFULBALL => :CAREFUL,
  :QUIRKYBALL  => :QUIRKY
}

NATURE_BALLS.each do |ball_id, nature|
  Battle::PokeBallEffects::OnCatch.add(ball_id, proc { |ball, battle, pkmn|
    NatureAndStatBalls.set_nature!(pkmn, nature)
  })
end