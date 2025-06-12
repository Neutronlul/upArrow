#include <iostream>
#include <cstdlib>
#include <curl/curl.h>
#include <dpp/dpp.h>
#include <rapidjson/document.h>
#include <rapidjson/error/en.h>

std::string envVarFetcher(const char* name) {
    if (auto val = std::getenv(name)) {
        return std::string(val);
    }
    throw std::runtime_error(std::string("Required environment variable not set: ") + name);
}

const std::string BOT_TOKEN = envVarFetcher("BOT_TOKEN");
const std::string url = envVarFetcher("LLM_TOKEN");
const std::string prePrompt = envVarFetcher("PRE_PROMPT");
const dpp::snowflake TARGET_CHANNEL_ID = envVarFetcher("TARGET_CHANNEL_ID");
const dpp::snowflake TARGET_USER_ID = envVarFetcher("TARGET_USER_ID");

size_t WriteCallback(void* contents, size_t size, size_t nmemb, std::string* buffer) {
    buffer->append((char*)contents, size * nmemb);
    return size * nmemb;
}

std::string gAPICall(std::string prompt) {
    CURL* curl;
    CURLcode res;
    std::string response_buffer;

    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();

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

    std::cout << std::endl << std::endl << response_buffer;

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

void addManyReactions(const std::vector<std::string>& emoji, dpp::cluster& bot, const dpp::message& message, int index = 0) {
    if (index < emoji.size()) {
        bot.message_add_reaction(message, emoji[index], [emoji, &bot, message, index](const dpp::confirmation_callback_t& callback) {
            if (!callback.is_error()) {
                addManyReactions(emoji, bot, message, index + 1);
            }
        });
    }
}

int main() {
	/* Create bot cluster */
	dpp::cluster bot(BOT_TOKEN, dpp::i_default_intents | dpp::i_message_content);

	/* Output simple log messages to stdout */
	bot.on_log(dpp::utility::cout_logger());

	bot.on_message_create([&bot](const dpp::message_create_t& event) {
	   if (event.msg.author.id == TARGET_USER_ID && !event.msg.content.empty()) {
		  bot.message_create(dpp::message(TARGET_CHANNEL_ID, gAPICall(event.msg.content) + event.msg.get_url()));
	   }
	});

    bot.on_message_create([&bot](const dpp::message_create_t& event) {
        if (event.msg.content.find("^") != std::string::npos && !event.msg.author.is_bot()) {
            bot.message_create(dpp::message(event.msg.channel_id, "^"));
            addManyReactions({"🇹","🇭","🇮","🇸"}, bot, event.msg);
        }
    });

	/* Start the bot */
	bot.start(dpp::st_wait);
    
    return 0;
}