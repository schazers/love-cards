local filterList = require 'src/util/filterList'
local constants = require 'src/constants'
local Entity = require 'src/Entity'
local Sounds = require 'src/Sounds'
local Hand = require 'src/Hand'
local Card = require 'src/Card'
local Promise = require 'src/Promise'
local generateRound = require 'src/generateRound'

local timeSinceLastSuccessfulShot = -1000000
local IMPACT_DELAY_SEC = 0.01 -- time between fire and impact

-- Entity vars
local entities
local hand
local cards

-- Entity methods
Entity.spawn = function(class, args)
  local entity = class.new(args)
  table.insert(entities, entity)
  return entity
end

local function spawnCard(args)
  local card = Card:spawn(args)
  table.insert(cards, card)
  return card
end

local function launchCard()
  local startX = love.math.random(constants.GAME_LEFT, constants.GAME_RIGHT)
  local minX = (startX < constants.GAME_LEFT + 0.2 * constants.GAME_WIDTH and 0.3 or 0.0) * constants.GAME_WIDTH + constants.GAME_LEFT
  local maxX = (startX > constants.GAME_LEFT + 0.8 * constants.GAME_WIDTH and 0.7 or 1.0) * constants.GAME_WIDTH + constants.GAME_LEFT
  local finalX = love.math.random(minX, maxX)
  local launchHeight = (0.3 + 0.61 * love.math.random()) * constants.GAME_HEIGHT + 0.7 * constants.CARD_HEIGHT
  local launchTime = 7.0 + 2.0 * love.math.random()
  local card = spawnCard({
    x = startX,
    y = constants.GAME_BOTTOM + 0.7 * constants.CARD_HEIGHT,
    vr = love.math.random(-300,300),
    rank = constants.CARD_RANKS[love.math.random(1, #constants.CARD_RANKS)],
    suit = constants.CARD_SUITS[love.math.random(1, #constants.CARD_SUITS)],
  })
  card:launch(finalX - startX, -launchHeight, launchTime)
end

local function removeDeadEntities(list)
  return filterList(list, function(entity)
    return entity.isAlive
  end)
end

-- Main methods
local function load()
  -- Init sounds
  Sounds.gun1 = Sound:new("snd/gun1.wav", 8)
  Sounds.gun2 = Sound:new("snd/gun2.wav", 8)
  Sounds.gun3 = Sound:new("snd/gun3.wav", 8)

  Sounds.pew1 = Sound:new("snd/pew1.wav", 8)
  Sounds.pew2 = Sound:new("snd/pew2.wav", 8)
  Sounds.pew3 = Sound:new("snd/pew3.wav", 8)
  Sounds.pew4 = Sound:new("snd/pew4.wav", 8)
  Sounds.pew5 = Sound:new("snd/pew5.wav", 8)
  Sounds.pew6 = Sound:new("snd/pew6.wav", 8)
  Sounds.pew7 = Sound:new("snd/pew7.wav", 8)
  Sounds.pew8 = Sound:new("snd/pew8.wav", 8)
  Sounds.pew9 = Sound:new("snd/pew9.wav", 8)
  Sounds.pew10 = Sound:new("snd/pew10.wav", 8)
  Sounds.pew11 = Sound:new("snd/pew11.wav", 8)
  Sounds.pew12 = Sound:new("snd/pew12.wav", 8)

  Sounds.impact = Sound:new("snd/impact1.wav", 8)
  Sounds.launch = Sound:new("snd/launch.mp3", 15)
  Sounds.music = Sound:new("snd/music.wav", 1)
  Sounds.music:setLooping(true)
  -- Initialize game vars
  entities = {}
  cards = {}
  -- Spawn initial entities
  hand = Hand:spawn({
    x = constants.GAME_LEFT + constants.CARD_WIDTH * 0.5 + 1, -- constants.GAME_MIDDLE_X,
    y = constants.GAME_BOTTOM - constants.CARD_HEIGHT * 0.35
  })
  local round = generateRound()
  local index, cardProps
  for index, cardProps in ipairs(round.hand) do
    hand:addCard(spawnCard({
      rankIndex = cardProps.rankIndex,
      suitIndex = cardProps.suitIndex
    }))
  end
  for index, cardProps in ipairs(round.cards) do
    Promise.newActive(0.3 * index):andThen(
      function()
        local startY = constants.GAME_BOTTOM + constants.CARD_HEIGHT / 2
        local startX = 20 * index
        local card = spawnCard({
          rankIndex = cardProps.rankIndex,
          suitIndex = cardProps.suitIndex,
          x = startX,
          y = startY,
          vr = math.random(-80, 80)
        })
        local apexX = math.random(constants.CARD_APEX_LEFT, constants.CARD_APEX_RIGHT)
        local apexY = math.random(constants.CARD_APEX_TOP, constants.CARD_APEX_BOTTOM)
        card:launch(apexX - startX, apexY - startY, 5 - 0.3 * index)
        Sounds.launch:play()
      end)
  end
  Sounds.music:play()
end

local function update(dt)
  -- Update all promises
  Promise.updateActivePromises(dt)
  -- Update all entities
  local index, entity
  for index, entity in ipairs(entities) do
    entity:update(dt)
    entity:countDownToDeath(dt)
  end
  -- Remove dead entities
  entities = removeDeadEntities(entities)
  cards = removeDeadEntities(cards)
  -- Update sounds
  timeSinceLastSuccessfulShot = timeSinceLastSuccessfulShot + dt
  if (timeSinceLastSuccessfulShot > IMPACT_DELAY_SEC) then
    Sounds.impact:play()
    timeSinceLastSuccessfulShot = -1000000
  end
end

local function draw()
  -- Draw all entities
  local index, entity
  for index, entity in ipairs(entities) do
    entity:draw()
  end
end

local function playGunshotSound()
  -- Gunshot
  Sounds.gun2:play()

  -- A random pew.
  local pew = math.random(1, 12)
  if     pew == 1 then  Sounds.pew1:play()
  elseif pew == 2 then  Sounds.pew2:play()
  elseif pew == 3 then  Sounds.pew3:play()
  elseif pew == 4 then  Sounds.pew4:play()
  elseif pew == 5 then  Sounds.pew5:play()
  elseif pew == 6 then  Sounds.pew6:play()
  elseif pew == 7 then  Sounds.pew7:play()
  elseif pew == 8 then  Sounds.pew8:play()
  elseif pew == 9 then  Sounds.pew9:play()
  elseif pew == 10 then Sounds.pew10:play()
  elseif pew == 11 then Sounds.pew11:play()
  elseif pew == 12 then Sounds.pew12:play()
  end
end

local function onMousePressed(x, y)
  -- Shoot cards
  playGunshotSound()
  local index, card
  for index, card in ipairs(cards) do
    if not card.isHeld and card:containsPoint(x, y) then
      hand:addCard(card)
      timeSinceLastSuccessfulShot = 0
    end
  end
end

return {
  load = load,
  update = update,
  draw = draw,
  onMousePressed = onMousePressed
}
