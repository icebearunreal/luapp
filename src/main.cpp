#include <iostream>
#include <fstream>
#include <sstream>
#include <optional>
#include <vector>
#include <string>

enum class TokenType {
    _return,
    int_lit,
    semi
};

struct Token {
    TokenType type;
    std::optional<std::string> value;
};

std::vector<Token> tokenize(const std::string& str) {
    for (char c : str) {
        std::cout << c << std::endl;
    }
    return {};
}

int main(int argc, char* argv[]) {

    if (argc != 2) {
        std::cerr << "Incorrect usage! Correct usage: " << std::endl;
        std::cerr << "luapp <input.lpp>" << std::endl;
        return EXIT_FAILURE;
    }

    std::string contents;
    {
        std::stringstream contents_stream;
        std::fstream input(argv[1], std::ios::in);
        contents_stream << input.rdbuf();
        contents = contents_stream.str();
    }

    tokenize(contents);

    return EXIT_SUCCESS;
}