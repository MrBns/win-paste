#ifndef UTILS_H_
#define UTILS_H_

#include <string>
#include <vector>

// Returns the command line arguments as a vector of strings, encoded as UTF-8.
std::vector<std::string> GetCommandLineArguments();

// Encodes a UTF-16 wchar_t string as a UTF-8 std::string.
std::string Utf8FromUtf16(const wchar_t* utf16_string);

#endif  // UTILS_H_
