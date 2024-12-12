#include <iostream>
#include <vector>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <queue>
#include <algorithm>

// Define an instruction structure
struct Instruction {
    int id;
    std::string op, dest;
    std::vector<std::string> src;
    int latency;
};

// Function to build the dependency graph
std::unordered_map<int, std::vector<int>> build_dependency_graph(const std::vector<Instruction>& instructions) {
    std::unordered_map<int, std::vector<int>> graph;
    std::unordered_map<std::string, int> last_written;

    for (const auto& instr : instructions) {
        graph[instr.id] = {};
    }

    for (size_t i = 0; i < instructions.size(); ++i) {
        const auto& instr = instructions[i];

        // Check for dependencies
        for (const auto& src : instr.src) {
            if (last_written.count(src)) {
                graph[last_written[src]].push_back(instr.id); // RAW dependency
            }
        }

        // Update last written for WAR/WAW dependencies
        last_written[instr.dest] = instr.id;
    }

    return graph;
}

// Function to account for latencies
std::vector<int> schedule_with_latencies(const std::unordered_map<int, std::vector<int>>& graph, const std::unordered_map<int, int>& latencies) {
    std::unordered_map<int, int> inDegree;
    std::unordered_map<int, int> earliest_start_time;

    // Initialize in-degrees and earliest start times
    for (const auto& node : graph) {
        inDegree[node.first] = 0;
        earliest_start_time[node.first] = 0;
    }

    for (const auto& node : graph) {
        for (int neighbor : node.second) {
            inDegree[neighbor]++;
        }
    }

    // Collect nodes with zero in-degree
    std::queue<int> zeroInDegreeQueue;
    for (const auto& node : inDegree) {
        if (node.second == 0) {
            zeroInDegreeQueue.push(node.first);
        }
    }

    std::vector<int> sortedOrder;
    while (!zeroInDegreeQueue.empty()) {
        int current = zeroInDegreeQueue.front();
        zeroInDegreeQueue.pop();
        sortedOrder.push_back(current);

        for (int neighbor : graph.at(current)) {
            earliest_start_time[neighbor] = std::max(earliest_start_time[neighbor], earliest_start_time[current] + latencies.at(current));
            inDegree[neighbor]--;
            if (inDegree[neighbor] == 0) {
                zeroInDegreeQueue.push(neighbor);
            }
        }
    }

    if (sortedOrder.size() != graph.size()) {
        throw std::runtime_error("Cyclic dependencies found!");
    }

    return sortedOrder;
}

// Main function to simulate the instruction reordering
void reorderInstructions(const std::vector<Instruction>& instructions) {
    try {
        // Build dependency graph
        auto dependencyGraph = build_dependency_graph(instructions);

        // Extract latencies
        std::unordered_map<int, int> latencies;
        for (const auto& instr : instructions) {
            latencies[instr.id] = instr.latency;
        }

        // Schedule considering latencies
        auto sortedIds = schedule_with_latencies(dependencyGraph, latencies);

        // Print reordered instructions
        std::cout << "Reordered Instructions (with latency considerations):" << std::endl;
        for (int id : sortedIds) {
            const auto& instr = *std::find_if(instructions.begin(), instructions.end(),
                                              [id](const Instruction& instr) { return instr.id == id; });
            std::cout << "Instruction " << instr.id << ": " << instr.op << " " << instr.dest << " <- ";
            for (const auto& src : instr.src) {
                std::cout << src << " ";
            }
            std::cout << std::endl;
        }
    } catch (const std::runtime_error& e) {
        std::cout << "Error: " << e.what() << std::endl;
    }
}

// Test the implementation
int main() {
    std::vector<Instruction> instructions = {
        {1, "LOAD", "R1", {"MEM[100]"}, 2},
        {2, "ADD", "R2", {"R1", "R3"}, 1},
        {3, "STORE", "MEM[200]", {"R2"}, 3},
        {4, "MUL", "R4", {"R3", "R5"}, 4}
    };

    reorderInstructions(instructions);
    return 0;
}
