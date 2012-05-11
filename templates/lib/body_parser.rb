module BodyParser
  module_function

  JSON_TYPE = "application/json"

  # Parses the body
  def parse(params, body, content_type)
    case content_type
    when JSON_TYPE 
      params.merge(json_parser.parse(body.read))
    else
      params
    end
  end

  def json_parser=(parser_klass)
    @json_parser = parser_klass
  end

  def json_parser
    @json_parser
  end
  
end
