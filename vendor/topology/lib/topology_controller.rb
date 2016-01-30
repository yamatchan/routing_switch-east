require 'command_line'
require 'topology'

# This controller collects network topology information using LLDP.
class TopologyController < Trema::Controller
  timer_event :flood_lldp_frames, interval: 1.sec

  attr_reader :topology
  attr_reader :command_line

  def start(args)
    @command_line = CommandLine.new(logger)
    @command_line.parse(args)
    @topology = Topology.new
    @topology.add_observer @command_line.view
    logger.info "Topology started (#{@command_line.view})."
  end

  def add_observer(observer)
    @topology.add_observer observer
  end

  def switch_ready(dpid)
	puts "switch_ready: #{dpid}"
	if dpid == 0x11 then
      puts "add flow entry"
      # xx.xx.xx.xx -> 169.254.32.11 => outport: 32
      send_flow_mod_add(
        dpid,
		match: Match.new(
		  in_port: 31,
		  destination_ip_address: '169.254.32.11',
		),
		actions: SendOutPort.new(32),
	  )

      # xx.xx.xx.xx -> 169.254.16.11 => outport: 31
      send_flow_mod_add(
        dpid,
		match: Match.new(
		  in_port: 32,
		  destination_ip_address: '169.254.16.11',
		),
		actions: SendOutPort.new(31),
	  )
	end

    send_message dpid, Features::Request.new
  end

  def features_reply(dpid, features_reply)
    @topology.add_switch dpid, features_reply.physical_ports.select(&:up?)
  end

  def switch_disconnected(dpid)
    @topology.delete_switch dpid
  end

  def port_modify(_dpid, port_status)
    updated_port = port_status.desc
    return if updated_port.local?
    if updated_port.down?
      @topology.delete_port updated_port
    elsif updated_port.up?
      @topology.add_port updated_port
    else
      fail 'Unknown port status.'
    end
  end

  def packet_in(dpid, packet_in)
    if packet_in.lldp?
      @topology.maybe_add_link Link.new(dpid, packet_in)
    elsif packet_in.ether_type == Pio::EthernetHeader::EtherType::IPV4
      @topology.maybe_add_host(packet_in.source_mac,
                               packet_in.source_ip_address,
                               dpid,
                               packet_in.in_port)
    end
  end

  def flood_lldp_frames
    @topology.ports.each do |dpid, ports|
      send_lldp dpid, ports
    end
  end

  private

  def send_lldp(dpid, ports)
    ports.each do |each|
      port_number = each.number
      send_packet_out(
        dpid,
        actions: SendOutPort.new(port_number),
        raw_data: lldp_binary_string(dpid, port_number)
      )
    end
  end

  def lldp_binary_string(dpid, port_number)
    destination_mac = @command_line.destination_mac
    if destination_mac
      Pio::Lldp.new(dpid: dpid,
                    port_number: port_number,
                    destination_mac: destination_mac).to_binary
    else
      Pio::Lldp.new(dpid: dpid, port_number: port_number).to_binary
    end
  end
end
