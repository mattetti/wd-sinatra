# Reopening WSList to add custom methods specific to this library.
module WSList

  # We want to load all routes with more globing routes last
  def self.sorted_for_sinatra_load
    globbing, no_globbing = all.partition{|ws| ws.url.include?(":") }

    all.sort do |a,b|
      a_colon_idx = a.url.index(":")
      b_colon_idx = b.url.index(":")
      a_length = a_colon_idx ? a_colon_idx + 1 : a.url.length
      b_length = b_colon_idx ? b_colon_idx + 1 : b.url.length
      if a_length == b_length
        if a_colon_idx && !b_colon_idx
          a_length -= 1
        elsif b_colon_idx && !a_colon_idx
          b_length -= 1
        else
          a_length = a.url.gsub(/\/$/, '').length
          b_length = b.url.gsub(/\/$/, '').length
        end
      end
      b_length <=> a_length
    end
  end
end
