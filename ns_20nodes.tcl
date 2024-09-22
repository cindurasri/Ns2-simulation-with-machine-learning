# NS2 Simulation Script for 20 Nodes
set ns [new Simulator]
set simulation_time 50 ;# Simulation time in seconds

# Read predictions from the CSV file
set prediction_file [open "model_predictions.csv" r]
set prediction_data [read $prediction_file]
close $prediction_file

# Split the predictions data by lines
set predictions_list [split $prediction_data "\n"]

# Define the finish procedure
proc finish {} {
    global ns
    $ns flush-trace
    puts "Simulation finished."
    exit 0
}

# Create a trace file for 20 nodes
set trace_file "trace_20.nodes"
set trace_file_handle [open $trace_file "w"]
$ns trace-all $trace_file_handle

# Number of nodes
set num_nodes 20
puts "Starting simulation with $num_nodes nodes..."

# Create nodes
set nodes {}
for {set i 0} {$i < $num_nodes} {incr i} {
    set node [$ns node]
    lappend nodes $node  ;# Store each node in the nodes list
}

# Create links between nodes
for {set i 0} {$i < $num_nodes} {incr i} {
    for {set j 0} {$j < $num_nodes} {incr j} {
        if {$i != $j} {
            $ns duplex-link [lindex $nodes $i] [lindex $nodes $j] 1Mb 10ms DropTail
        }
    }
}

# Create TCP agents and attach to source and sink
set tcp [new Agent/TCP/Newreno]
$ns attach-agent [lindex $nodes 0] $tcp

set sink [new Agent/TCPSink/DelAck]
$ns attach-agent [lindex $nodes 1] $sink

# Connect TCP agent to sink
$ns connect $tcp $sink

# Set TCP parameters
$tcp set fid_ 1
$tcp set packet_size_ 552  ;# Set packet size for TCP

# Schedule sending of TCP packets
$ns at 1.0 "$tcp send 1000"  ;# Send 1000 bytes

# Determine prediction for the current node count
set prediction_value [lindex $predictions_list 0]  ;# Assuming first line for 20 nodes

# Implement logic based on the prediction
if { $prediction_value == "2" } {
    puts "Simulation with $num_nodes nodes: Normal operation."
} elseif { $prediction_value == "1" } {
    puts "Simulation with $num_nodes nodes: Gray hole detected."
} elseif { $prediction_value == "0" } {
    puts "Simulation with $num_nodes nodes: Black hole detected."
}

# Schedule finish at simulation time
$ns at $simulation_time "finish"  ;# Schedule finish at simulation time

# Run the simulation
puts "Running simulation with $num_nodes nodes..."
$ns run

# Close the trace file handle
close $trace_file_handle

