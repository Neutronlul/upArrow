#include <iostream>
#include <cstdlib>

//using namespace std;

//const std::string BOT_TOKEN = "Testing";
const std::string url = envVarFetcher("BOT_TOKEN");

std::string envVarFetcher(const char* name) {
    if (auto val = std::getenv(name)) {
        return std::string(val);
    }
    throw std::runtime_error(std::string("Required environment variable not set: ") + name);
}
/*
size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* buffer) {
    buffer->append((char*)contents, size * nmemb);
    return size * nmemb;
}

string gAPICall(string prompt) {
    CURL* curl;
    CURLcode res;
    string response_buffer;

    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();

    const std::string url = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=AIzaSyDE-VW7_mipXsfIXDJpk8J4l22-5w08TdA";
    //std::string prePrompt = "Respond to this in one sentence:\n";
    std::string prePrompt = "The following is a message from a closeted gay man. Explain how its contents relates to his sexuality in one sentence.\n";
    // Set the JSON data
    const std::string json_data = R"(
        {
            "contents": [
                {
                    "parts": [
                        {
                            "text": ")" + prePrompt + prompt + R"("
                        }
                    ]
                }
            ],
            "safety_settings": [
                {
                    "category": "HARM_CATEGORY_HATE_SPEECH",
                    "threshold": "BLOCK_NONE"
                },
                {
                    "category": "HARM_CATEGORY_HARASSMENT",
                    "threshold": "BLOCK_NONE"
                },
                {
                    "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                    "threshold": "BLOCK_NONE"
                },
                {
                    "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                    "threshold": "BLOCK_NONE"
                }
            ]
        }
        )";

    // Set the headers
    struct curl_slist* headers = nullptr;
    headers = curl_slist_append(headers, "Content-Type: application/json");

    // Set CURL options
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_POST, 1L);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, json_data.c_str());

    // Set callback function to save response
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response_buffer);

    // Perform the request
    res = curl_easy_perform(curl);

    rapidjson::Document doc;
    doc.Parse(response_buffer.c_str());

    // Cleanup
    curl_slist_free_all(headers);
    curl_easy_cleanup(curl);

    cout << endl << endl << response_buffer;

    curl_global_cleanup();

    if (doc.HasMember("error")) {
        return "\"" + prompt + "\"\nError: " + doc["error"]["status"].GetString()
        + "\n" + doc["error"]["message"].GetString() + "\n";
    }
    else {
        return "\"" + prompt + "\"\nExplanation: "
        + doc["candidates"][0]["content"]["parts"][0]["text"].GetString();
    }  
}
*/
int main() {

    //dpp::cluster bot(BOT_TOKEN, dpp::i_default_intents | dpp::i_message_content);
    //Test
    std::cout << "Hello, " << url << "!" << std::endl;




    return 0;
}