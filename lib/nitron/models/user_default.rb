class UserDefault
  def keys
    to_h.keys
  end

  def to_h
    NSUserDefaults.standardUserDefaults.dictionaryRepresentation
  end

  def []=(key, data)
    if data.nil?
      delete(key)
    else
      NSUserDefaults.standardUserDefaults[key] = data
    end
    synchronize
  end

  def [](key)
    NSUserDefaults.standardUserDefaults[key]
  end

  def save(hash)
    hash.each do |k,v|
      self[k] = v
    end
    synchronize
  end

  def delete(keys)
    Array(keys).each do |key| 
      NSUserDefaults.standardUserDefaults.removeObjectForKey(key)
    end
    synchronize
  end

  def synchronize
    NSUserDefaults.standardUserDefaults.synchronize
  end

  def reset
    delete keys
  end
end
