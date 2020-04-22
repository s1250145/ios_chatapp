import requests
import urllib.parse
from flask import request, Flask
from flask_cors import CORS
from keras.models import Model
from keras.layers import Input, LSTM, Dense
from keras.utils import plot_model
from google.cloud import storage
import numpy as np
import os, sys
import re
import jaconv
import lstm_seq2seq as lstm # Model

app = Flask(__name__)
CORS(app)

GCS_BUCKET = 'chat-bot-259102.appspot.com'
MODEL_NAME = 'lstm_param.h5'
DOWNLOAD_FOLDER = '/tmp'

model_path = os.path.join(DOWNLOAD_FOLDER, MODEL_NAME)
storage_client = storage.Client()
bucket = storage_client.get_bucket(GCS_BUCKET)
blob = bucket.get_blob(MODEL_NAME)
blob.download_to_filename(model_path)
lstm.model.load_weights(model_path)

# lstm.model.load_weights('lstm_seq2seq/lstm_param.h5')

@app.route("/")
def check():
    return "Hello, chat bot!"

@app.route("/talk", methods=['GET'])
# input /talk?msg=[your message]
def talk():
    # 受け取ったmsgをもとに返事を生成
    msg = jaconv.hira2kata(urllib.parse.unquote(request.args.get('msg')))
    msg_data = np.zeros((1, lstm.max_encoder_seq_length, lstm.num_encoder_tokens), dtype='float32')
    for i, char in enumerate(msg):
        msg_data[0, i, lstm.input_token_index[char]] = 1.
    response = lstm.decode_sequence(msg_data)
    response = re.sub(r'[「」]', '', response)
    response = jaconv.kata2hira(response)
    if response.find('…………') != -1:
        response = 'ぶわーーーー！=3 =3\n'
    return response

if __name__ == "__main__":
    app.run(host='127.0.0.1', port=8080, debug=True)
