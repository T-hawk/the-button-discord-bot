class User
  attr_accessor :id, :name, :rank


  def initialize(id, name, rank)
    self.id = id
    self.name = name
    self.rank = rank
  end

  def to_json(_)
    { "id" => self.id, "name" => self.name, "rank" => self.rank}.to_json
  end

  def from_json string
    data = JSON.load string
    self.new data['id'], data['nme'], data['rank']
  end
end
