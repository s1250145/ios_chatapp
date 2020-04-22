import lstm_seq2seq as lstm
import os

if os.path.isfile('lstm_param.h5'):
    print('**** Already ****')
    lstm.model.load_weights('lstm_param.h5')
    lstm.model.compile(optimizer='rmsprop', loss='categorical_crossentropy')
    lstm.model.summary()
    lstm.model.fit([lstm.encoder_input_data, lstm.decoder_input_data], lstm.decoder_target_data,
              batch_size=lstm.batch_size,
              epochs=lstm.epochs,
              validation_split=0.2)
    lstm.model.save('lstm_param.h5')
else:
    # Run training
    lstm.model.compile(optimizer='rmsprop', loss='categorical_crossentropy')
    lstm.model.summary()
    lstm.model.fit([lstm.encoder_input_data, lstm.decoder_input_data], lstm.decoder_target_data,
              batch_size=lstm.batch_size,
              epochs=lstm.epochs,
              validation_split=0.2)
    lstm.model.save('lstm_param.h5')
