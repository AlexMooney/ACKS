module RandomWeighted
  def random_weighted(weight_by_value)
    target = rand(1..100)
    weight_by_value.detect { |item, weight| weight && target <= weight }.first
  end

  def self.included(base)
    base.extend(self)
  end
end
