import re

with open('corpus.distinct.txt') as f, open('train.txt', 'w') as w:
    print('Start...')
    for line in f:
        line = line.replace('___SP___', '\t')
        line = line.replace(' ', '')
        w.write(line)
    f.close()
    w.close()
    print('Finish')
