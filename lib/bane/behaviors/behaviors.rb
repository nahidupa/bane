module Bane

  module Behaviors

    # Sends a large response.  Response consists of a repeated 'x' character.
    #
    # Options
    #  - length: The size in bytes of the response to send. Default: 1,000,000 bytes
    class DelugeResponse
      def initialize(options = {})
        @options = {length: 1_000_000}.merge(options)
      end
      def serve(io)
        length = @options[:length]

        length.times { io.write('x') }
      end
    end

    class DelugeResponseForEachLine < DelugeResponse
      include ForEachLine
    end

    # Sends an HTTP 401 response (Unauthorized) for every request.  This
    # attempts to mimic an HTTP server by reading a line (the request)
    # and then sending the response.  This behavior responds to all
    # incoming request URLs on the running port.
    class HttpRefuseAllCredentials
      UNAUTHORIZED_RESPONSE_BODY = <<EOF
<!DOCTYPE html>
<html>
  <head>
    <title>Bane Server</title>
  </head>
  <body>
    <h1>Unauthorized</h1>
  </body>
</html>
EOF

      def serve(io)
        io.gets # Read the request before responding
        response = NaiveHttpResponse.new(401, "Unauthorized", "text/html", UNAUTHORIZED_RESPONSE_BODY)
        io.write(response.to_s)
      end
    end

    class EchoResponse
      def serve(io)
        while(input = io.gets)
          io.write(input)
        end
        io.close
      end
    end

  end
end

