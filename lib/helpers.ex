defmodule Helpers do

  @header_status_sample 'HTTP/1.0 200 OK'
  @header_params_sample [{'date', 'Fri, 16 Aug 2013 10:58:53 GMT'},
                         {'server', 'inets/5.9.5'},
                         {'content-length', '526'},
                         {'content-type', 'text/html'}
                         ]
  @html_sample '<HTML>\n<HEAD>\n<TITLE>Index of </TITLE>\n</HEAD>\n<BODY>\n<H1>Index of </H1>\n<PRE><IMG SRC="/icons/blank.gif" ALT=> Name                   Last modified         Size  Description <HR>\n<IMG SRC="/icons/back.gif" ALT="[DIR]"> <A HREF="">Parent directory</A>       16-Aug-2013 14:28        -\n<IMG SRC="/icons/unknown.gif" ALT="[]"> <A HREF="/a">a</A>                      16-Aug-2013 12:58       1k  \n<IMG SRC="/icons/unknown.gif" ALT="[]"> <A HREF="/b">b</A>                      16-Aug-2013 14:28       1k  \n</PRE>\n</BODY>\n</HTML>\n'

  def format_kv_pair(pair) do
    {k, v} = pair
    "#{k}: #{v}"
  end

  def parse_params(params) do
    Enum.map(params, Helpers.format_kv_pair(&1)) |>
      List.foldr("", fn(x, acc) -> x <> "\r\n" <> acc end)
  end

  def sample_params() do
    Helpers.parse_params(@header_params_sample)
  end

  def send_http(port) do
    :inets.start()
    :httpc.set_options([ {:verbose, :debug} ])
    :httpc.request(:get, {'http://localhost:#{port}', []},
      [{:version, 'HTTP/1.0'}],
      [])
  end

  def http_server() do
    :inets.start()
    {:ok, pid} = :inets.start(:httpd, [{:port, 0},
      {:server_name, 'httpd_test'}, {:server_root, '/tmp'},
      {:document_root, '/tmp/htdocs'}, {:bind_address, {127,0,0,1}}])
    info = :httpd.info(pid)
    {:port, port} = :proplists.lookup(:port, info)
    IO.puts "Opened webserver on port #{port}"
    {:ok, pid}
  end

  def listen_tcp(port) do
    {:ok, lsock} = :gen_tcp.listen(port, [:binary, {:packet, 0}, {:active, true}])
    accept_fun = fn() ->
      {:ok, sock} = :gen_tcp.accept(lsock)
      receive do
        a -> test = a
      end
      {:tcp, repsock, msg } = test
      {:ok, sock, repsock, msg}
    end
    {:ok, lsock, accept_fun}
  end

  def sample_reply_message() do
    "#{@header_status_sample}\r\n#{Helpers.sample_params}\r\n\r\n#{@html_sample}\r\n"
  end

  def reply_sample(repsock) do
  # :gen_tcp.send(repsock, "HTTP/1.0 200 OK\r\n\r\nHello\r\n")
    :gen_tcp.send(repsock, Helpers.sample_reply_message)
  end
end
