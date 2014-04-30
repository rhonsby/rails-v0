require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = route_params
    parse_www_encoded_form(req.body) if req.body
    parse_www_encoded_form(req.query_string) if req.query_string

    @permitted_keys = []
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted_keys += @params.keys.select { |key| keys.include?(key) }
  end

  def require(key)
    raise AttributeNotFoundError unless @params.keys.include?(key)
  end

  def permitted?(key)
    @permitted_keys.include?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  #
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    decoded_url = URI.decode_www_form(www_encoded_form)

    decoded_url.each do |arr|
      arr.map! { |el| parse_key(el) }
    end

    decoded_url.each do |data|
      path, value = data
      new_params = { path.pop => value.first }

      until path.empty?
        new_params = { path.pop => new_params }
      end

      deep_merge(@params, new_params)
    end

    @params
  end

  def deep_merge(hash1, hash2)
    hash2.each do |key, value|
      if hash1.keys.include?(key)
        deep_merge(hash1[key], value)
      else
        hash1[key] = value
      end
    end

    hash1
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split('[').map { |k| k.gsub(']', '') }
  end
end