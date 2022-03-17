class Database

  require 'redis'

  def initialize()
    uri = URI.parse(ENV["REDISTOGO_URL"])
    @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end

  def reset
    write({"users" => [], "last_pressed" => ""})
  end

  def get_data
    file = @redis.get("data.json")
    if file
      JSON.parse(file)
    else
      {"users" => [], "last_pressed" => ""}
    end
  end

  def user(id)
    data = get_data
    for user in data["users"]
      if user["id"] == id
        return user
      end
    end
    return nil
  end

  def update_user_rank(id, name, rank, rank_emoji)
    data = get_data
    data["users"].each_with_index do |user, index|
      if user["id"] == id
        data["users"][index]["rank"] = rank
        data["users"][index]["rank_emoji"] = rank_emoji
        write data
        return
      end
    end
    data["users"].push({"id" => id, "name" => name, "rank" => rank, "rank_emoji" => rank_emoji})

    write data
  end

  def write(data)
    @redis.set("data.json", JSON.dump(data))
  end

  def button_last_pressed
    data = get_data
    data["last_pressed"]
  end

  def button_just_pressed
    data = get_data
    data["last_pressed"] = Time.now
    write data
  end

  def reset_button
  end
end
