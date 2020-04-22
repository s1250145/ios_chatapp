from keras.models import Model
from keras.layers import Input, LSTM, Dense
from keras.utils import plot_model
import numpy as np
import os
import re
import jaconv
import lstm_seq2seq as lstm

if os.path.isfile('lstm_param.h5'):
    lstm.model.load_weights('lstm_param.h5')
    print('******* Nice to meet you! *******')
    while True:
        cns_input = input('you :')
        if cns_input == 'q':
            print('bot :またね')
            break

        # 入力された文の処理
        data = np.zeros((1, lstm.max_encoder_seq_length, lstm.num_encoder_tokens), dtype='float32')
        input_text = jaconv.hira2kata(cns_input)
        for t, char in enumerate(input_text):
            data[0, t, lstm.input_token_index[char]] = 1.

        # 応答文を生成
        response = lstm.decode_sequence(data)
        response = re.sub(r'[「」]', '', response)
        response = jaconv.kata2hira(response)
        if response.find('…………') != -1:
            response = 'ぶわーーーー！\n'
        print('bot :', response)
else:
    print('******* Cannot load weights! *******')
