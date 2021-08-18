class Database

  def initialize(path)
    @file_path = path
  end

  def get_data
    file = File.read(@file_path)
    JSON.parse(file)
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

  def update_user_rank(id, name, rank)
    data = get_data
    data["users"].each_with_index do |user, index|
      if user["id"] == id
        data["users"][index]["rank"] = rank
        write data
        return
      end
    end
    data["users"].push({"id" => id, "name" => name, "rank" => rank})

    write data
  end

  def write(data)
    File.write(@file_path, JSON.dump(data))
  end

  def button_last_pressed
    data = get_data
    data["last_pressed"]
  end

  def button_just_pressed
    data = get_data
    data["last_pressed"] = Date.today
    write data
  end

  def reset_button
  end
end
