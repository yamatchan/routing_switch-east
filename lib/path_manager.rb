require 'dijkstra'
require 'path'
require 'trema'

# L2 routing path manager
class PathManager < Trema::Controller
  def start
    @path = []
    @graph = Hash.new([].freeze)
    logger.info 'Path Manager started.'
  end

  # This method smells of :reek:FeatureEnvy but ignores them
  def packet_in(_dpid, message)
    path = maybe_create_shortest_path(message)
    ports = path ? [path.out_port] : external_ports

#    ports.each do |each|
#      return if each.nil?
#      p "send_packet_out"
#      send_packet_out(each.dpid,
#                      raw_data: message.raw_data,
#                      actions: SendOutPort.new(each.number))
#    end
    port_arr = [31,32,33]
    port_arr.delete(message.in_port)
p port_arr
    port_arr.each do |each|
      send_packet_out(_dpid,
                      raw_data: message.raw_data,
                      actions: SendOutPort.new(each))
    end

#      send_packet_out(_dpid,
#                      raw_data: message.raw_data,
#                      actions: SendOutPort.new(:flood))
  end

  def add_port(port, _topology)
    add_graph_path port.dpid, port
  end

  def delete_port(port, _topology)
    @graph.delete(port)
    @graph[port.dpid] -= [port]
  end

  def add_link(port_a, port_b, _topology)
    add_graph_path port_a, port_b
    # TODO: update all paths
  end

  def delete_link(port_a, port_b, _topology)
    delete_graph_path port_a, port_b
    paths_containing_link(port_a, port_b).each do |each|
      @path.delete each
      each.delete
      maybe_create_shortest_path(each.packet_in)
    end
  end

  def add_host(ip_address, port, _topology)
    add_graph_path ip_address, port
  end

  def add_graphviz(graphviz)
    @graphviz = graphviz
  end

  private

  def external_ports
    @graph.select do |key, value|
      key.is_a?(Topology::Port) && value.size == 1
    end.keys
  end

  def add_graph_path(node_a, node_b)
    @graph[node_a] += [node_b]
    @graph[node_b] += [node_a]
  end

  def delete_graph_path(node_a, node_b)
    @graph[node_a] -= [node_b]
    @graph[node_b] -= [node_a]
  end

  def paths_containing_link(port_a, port_b)
    @path.select { |each| each.link?(port_a, port_b) }
  end

  def maybe_create_shortest_path(packet_in)
    case packet_in.data
    when Arp::Request, Arp::Reply
      source_ip = packet_in.sender_protocol_address
      destination_ip = packet_in.target_protocol_address
    when Parser::IPv4Packet
      source_ip = packet_in.source_ip_address
      destination_ip = packet_in.destination_ip_address
    else
      source_ip = ""
      destiantion_ip = ""
    end
    p "source_ip: #{source_ip} -> destination_ip: #{destination_ip}"

    #shortest_path = dijkstra(source_ip, destination_ip)
    shortest_path = nil
    return unless shortest_path
    @graphviz.update_shortest_path shortest_path
    Path.create(shortest_path, packet_in).tap { |new_path| @path << new_path }
  end

  def dijkstra(source_ip_address, destination_ip_address)
    return if @graph[source_ip_address].empty?
    return if @graph[destination_ip_address].empty?
    route = Dijkstra.new(@graph).run(source_ip_address, destination_ip_address)
    route.reject { |each| each.is_a? Integer }
  end
end
