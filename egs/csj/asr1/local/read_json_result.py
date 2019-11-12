import json
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_file', type=str)
    # parser.add_argument('--', type=str)
    # parser.add_argument('--mecablize', type=bool, default=False)
    args = parser.parse_args()
    input_file = args.input_file

    input_file = "/home/geng17/espnet/egs/csj/asr1/dump/iis20160517_5m_clean_False/deltafalse/data.json"
    with open(input_file, 'r') as f:
        a = json.load(f)    
    # print(type(a))
    # print(a['utts']['input'])
    # print(a.keys())
    utts = a['utts']
    for utt in utts:
        print(utts[utt])


    

        

if __name__ == "__main__":
    main()
