class Chunked < FaradayMiddleware::ResponseMiddleware
  define_parser { |body|
    return if body.empty?
    raw_body = body
    decoded_body = []
    until raw_body.empty?
      chunk_len, raw_body = raw_body.split("\r\n", 2)
      chunk_len = chunk_len.split(';',2).first.hex
      break if chunk_len == 0
      decoded_body << raw_body[0, chunk_len]
      # The 2 is to strip the extra CRLF at the end of the chunk
      raw_body = raw_body[chunk_len + 2, raw_body.length - chunk_len - 2]
    end
    decoded_body.join('')
  }

  def parse_response?(env)
    # Faraday is infected with the net/http behavior of joining multiple values of the same header
    super && env[:response_headers][:transfer_encoding].split(',').include?('chunked')
  end

end

Faraday.register_middleware :response, :chunked => lambda { Chunked }
