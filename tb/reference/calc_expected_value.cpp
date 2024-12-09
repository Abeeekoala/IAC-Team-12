#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
#include <cstdint>

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " input.mem" << std::endl;
        return 1;
    }

    const std::string filename = argv[1];

    std::ifstream infile(filename, std::ios::binary);
    if (!infile.is_open()) {
        std::cerr << "Error: Cannot open file " << filename << std::endl;
        return 1;
    }

    std::vector<uint8_t> data;
    std::string line;

    // Read the file line by line
    while (std::getline(infile, line)) {
        std::istringstream iss(line);
        std::string hex_value;

        // Read each hex value in the line
        while (iss >> hex_value) {
            // Convert the hex string to a uint8_t
            uint8_t byte = static_cast<uint8_t>(std::stoi(hex_value, nullptr, 16));
            data.push_back(byte);
        }
    }
    infile.close();

    const int max_count = 200;
    std::vector<uint8_t> pdf(256, 0);
    int a2 = 0;
    while (true) {
        if (a2 >= (int)data.size()) {
            // If we run out of data (very unlikely with the given large file)
            // just break
            break;
        }

        uint8_t val = data[a2];
        uint8_t count = pdf[val];
        count++;
        pdf[val] = count;

        a2++;

        if (count == max_count) {
            // Stop as soon as one bin hits 200 increments
            break;
        }
    }
    // Sum all bins to simulate "display"
    int sum = 0;
    for (int i = 0; i < 256; i++) {
        sum += pdf[i];
    }

    // sum now holds the final a0 value
    std::cout << "Final a0 (sum of pdf values): " << sum << std::endl;

    return 0;
}
