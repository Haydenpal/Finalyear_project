from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# Replace 'YOUR_BOT_TOKEN' with your new Telegram bot token
TELEGRAM_BOT_TOKEN = '6663052612:AAEIe0LH1m88u6AhHhGT2AjSYd8Q-j-Osws'
# Replace 'tradingview_chart' with your new channel name
TELEGRAM_CHANNEL_NAME = '@bot112020'

@app.route('/webhook', methods=['POST'])
def tradingview_webhook():
    # Get the raw data from the request
    data = request.data.decode('utf-8')

    # Assuming your message has a specific format
    message = data.strip()

    # Send message to Telegram channel without the "TradingView Alert" prefix
    send_telegram_message(message)

    return jsonify({'status': 'success'})

def send_telegram_message(message):
    # Construct the Telegram bot API endpoint
    telegram_url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    
    # Prepare the message data
    params = {
        'chat_id': TELEGRAM_CHANNEL_NAME,
        'text': message,
    }

    # Send the message using the requests library
    response = requests.post(telegram_url, params=params)
    
    # Print the response (optional, for debugging purposes)
    print(response.json())

if __name__ == '__main__':
    # Run the Flask web server on port 80, listen on all available interfaces, and enable debug mode
    app.run(host='0.0.0.0', port=80, debug=True)
