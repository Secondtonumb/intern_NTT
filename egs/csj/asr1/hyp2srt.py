import os
import time
import argparse
import MeCab

segment_duration = 10

parser = argparse.ArgumentParser()
parser.add_argument('--decode_dir', type=str)
parser.add_argument('--recording_id', type=str)
parser.add_argument('--mecablize', type=bool, default=False)
args = parser.parse_args()

decode_dir = args.decode_dir
recording_id = args.recording_id


def time_stamp_to_hms(time_stamp):
    """
    input: <timestamp> e.g. 3456.789
    output: <str> e.g. 00:57:36,789
    """
    hour = int(time_stamp // (60 * 60))
    minute = int((time_stamp - hour * 60 * 60) // 60)
    second = int((time_stamp - hour * 60 * 60 - minute * 60))
    hour_str = "%02d" % hour
    minute_str = "%02d" % minute
    second_str = "%02d" % second
    return(hour_str + ':' + minute_str + ':' + second_str + ',' + '000')


def arrange_subtitle_length(text, sublength):
    """
    input: text length over than 25
    output: split text length every sublength
    """
    arranged_text = []
    arranged_text = [text[i: i+sublength]
                     for i in range(0, len(text), sublength)]
    return arranged_text


def mecablize(text):
    """
    input: text with filler such as "えいと"

    """
    mecab = MeCab.Tagger()
    mecab.parse('')  # 文字列がGCされるのを防ぐ
    node = mecab.parseToNode(text)
    cleared_text = []

    while node:
        word = node.surface
        pos = node.feature.split(",")[0]
        if pos == 'フィラー' :
            cleared_text.append('\n') # Add Enter after filler
            node = node.next
        else:
            cleared_text.append(word)
            node = node.next
    result = arrange_subtitle_length(''.join(cleared_text), 30)
    return ''.join(cleared_text)


subtitle_container = []
hyp_file = os.path.join(decode_dir, 'hyp.trn')
with open(hyp_file, 'r') as h_file:
    for line in h_file.readlines():
        srt_container = []
        line = line.replace(' ', '')
        subtitle = line.split('(')[0]
        if args.mecablize == True:
            subtitle = mecablize(subtitle)
        subtitle = arrange_subtitle_length(subtitle, 100)
        utterance_id = line.split('(')[1].replace(')', '')

        begin_time_stamp = utterance_id.split('_')[1]
        end_time_stamp = utterance_id.split('_')[2]
        begin_time_stamp = float(begin_time_stamp)/1000
        end_time_stamp = float(end_time_stamp)/1000
        begin_time_stamp = time_stamp_to_hms(begin_time_stamp)
        end_time_stamp = time_stamp_to_hms(end_time_stamp)
        srt_container = [subtitle, begin_time_stamp, end_time_stamp]
        subtitle_container.append(srt_container)

srt = os.path.join(decode_dir, recording_id + '.srt')

with open(srt, 'w') as srt_file:
    count = 1
    for utterance in subtitle_container:
        print(
            "%d\n%s --> %s\n%s\n" % (count, utterance[1], utterance[2], '\n'.join(utterance[0])), file=srt_file
        )
        count = count + 1
