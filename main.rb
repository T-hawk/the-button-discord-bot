class Main
  require "discordrb"
  require 'json'
  require_relative './user.rb'
  require_relative './database.rb'

  $ranks = [
    "Potato",
    "Strawberry",
    "Egg",
    "Bread",
    "Pickle",
    "Pepper",
    "Pizza",
    "Burger",
    "Taco",
    "Bacon",
    "Cheese",
    "Croissant",
    "Milk"
  ]
  $rank_emojis = [
    ":potato:",
    ":strawberry:",
    ":egg:",
    ":bread:",
    ":cucumber:",
    ":hot_pepper:",
    ":pizza:",
    ":hamburger:",
    ":taco:",
    ":bacon:",
    ":cheese:",
    ":croissant:",
    ":milk:"
  ]

  $time_interval = 1.5

  def initialize
    @bot = Discordrb::Commands::CommandBot.new token: ENV["THE_BUTTON_TOKEN"], client_id: 870326478116630558, prefix: "-"
    @db = Database.new()
  end

  def run
    @bot.command(:push) do |event|
      if current_rank < $ranks.length

        remove_roles = []
        event.user.roles.each do |role|
          if $ranks.include? role.name
            remove_roles.push role
          end
        end
        event.user.remove_role(remove_roles)

        role = event.user.server.roles.find {|role| role.name == $ranks[current_rank] }
        event.user.add_role(role)
        event.send_embed do |embed|
          embed.title = "#{$rank_emojis[current_rank]} Button Pushed your new rank is #{$ranks[current_rank]} #{$rank_emojis[current_rank]}"
          embed.color = "#fc1c03"
        end
        @db.update_user_rank(event.user.id, event.user.name, $ranks[current_rank], $rank_emojis[current_rank])
        @db.button_just_pressed
        return
      else
        event.respond death_message
        @db.reset_button
      end
    end

    @bot.command(:rank) do |event|
      user = @db.user(event.user.id)
      if user
        event.respond "#{user['name']}'s rank is #{user['rank_emoji']} #{user['rank']} #{user['rank_emoji']}"
      else
        event.respond "#{event.user.username} doesn't have a rank"
      end
    end

    @bot.command(:status) do |event|
      if !@db.button_last_pressed.empty?
        if current_rank < $ranks.length
          #event.respond "#{$ranks[current_rank]} #{$rank_emojis[current_rank]} is the current rank"
          event.send_embed do |embed|
            embed.title = status_title
            embed.description = "The current rank is #{$ranks[current_rank]} #{$rank_emojis[current_rank]}"
            embed.color = "#fc1c03"
          end
        else
          event.respond death_message
        end
      else
        event.respond "Game has not started yet. An admin must use the -start command"
      end
    end

    @bot.command(:reset) do |event|
      @db.reset
      @db.button_just_pressed
      event.respond "The Button has started! Good luck!"
      return
    end

    @bot.command(:help) do |event|
      event.respond <<-STR
    The Button is a social experiment of sorts... The Button is forever ticking down to its inevitable death, if the button is pushed
    the its death clock is reset. The player who pushed the button recieves a rank based on how close the button was to death. The closer
    it is do death, the higher the rank. Have fun!

    Use `-push` to push the button
    Use `-status` to see what rank the button is on
    Use `-rank` to find out your current rank
      STR
    end
    @bot.run
  end

  def current_rank
    (((Time.now - Time.parse(@db.button_last_pressed))/3600)/$time_interval).floor
  end

  def status_title
    string = ""
    $rank_emojis.each_with_index do |rank, index|
      if current_rank >= index
        string += rank
      else
        string += " ?"
      end
    end
    return string
  end

  def death_message
    "The Button has died!! Oh no you fool! :cry:"
  end
end

main = Main.new
main.run
