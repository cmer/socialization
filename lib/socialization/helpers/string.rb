class String

  def deep_const_get
    result = nil
    path = self.clone.split("::")

    path.each do |p|
      result = (result || Kernel).const_get(p)
    end
    result
  end

  def is_integer?
    self.to_i.to_s == self
  end

end