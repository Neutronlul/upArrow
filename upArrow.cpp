#include <iostream>

//using namespace std;

const std::string BOT_TOKEN = "Testing";

int main() {

    //dpp::cluster bot(BOT_TOKEN, dpp::i_default_intents | dpp::i_message_content);
    //Test
    std::cout << "Hello, " << getenv("BOT_TOKEN") << "!" << std::endl;

    return 0;
}