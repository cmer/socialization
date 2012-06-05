class String

  def deep_const_get
    result = nil
    path = self.clone.split("::")

    path.each do |p|
      result = (result || Kernel).const_get(p)
    end
    result
  end

end