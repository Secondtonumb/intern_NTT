#!/bin/bash

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;

set -e 
set -u 
set -o pipefail

wavefile_path="/home/geng17/nas02_home/Dataset/LDNU_eval4/"
recog_set=$(ls $wavefile_path | sed 's/.wav//')
# recog_set="syn ori"
srtfile_path="/home/geng17/nas02_home/Dataset/srt/"
dumpdir=dump
do_delta=false
train_set=train_nodup_sp
dict=data/lang_1char/${train_set}_units.txt
speaker=Toda
clean_text_mode=False
sets=3
utts=100

fbankdir=fbank

for x in ${recog_set}; do
    # echo $x
    # mkdir -p data/${x}
    # for ((i = 0; i < ${sets}; i++)); do
    #     mkdir -p data/${x}_evalset_clean_${clean_text_mode}_${i}
    # done
    # pickle srt file
    python local/pickle_srt.py \
        --input_file "${srtfile_path}/${x}.srt" \
        --output_file "data/${x}/pickle" \
        --wavefile_id "${x}" \
        --remove_punctuation True\
        --remove_space True

    # generate wav.scp, segments, text(blank) from pickle file    
    # python local/read_pickle_and_generate_eval_set.py \
    #     --input_file "data/${x}/pickle" \
    #     --wavefile_id "${x}" \
    #     --clean_text_mode ${clean_text_mode} \
    #     --use_all_utts True \
    #     --sets ${sets} \
    #     --utts ${utts} \
    #     --speaker ${speaker}
    # # eval_set=$(ls -d "data/${x}_clean_${clean_text_mode}"* | sed 's/data\///')
    # eval_set=$(ls -d "data/${x}_evalset_clean_${clean_text_mode}"* | sed 's/data\///')  
    # eval_set=$(echo {22..31})
    eval_set="iis20160517 iis20160531 iis20160607 iis20160614 sp20161006 sp20161013 sp20161222 sp20170110 sp20170112"
    # eval_set='new_eval_1 new_eval_2 new_eval_3'
    for rtask in ${eval_set}; do
        # echo "${x} cat ${wavefile_path}/${x}.wav |" > "data/${rtask}/wav.scp"
        for file in "wav.scp" "text" "utt2spk"; do
            sort -o "data/${rtask}/$file" "data/${rtask}/$file"
        done
        utils/utt2spk_to_spk2utt.pl data/${rtask}/utt2spk > data/${rtask}/spk2utt
        steps/make_fbank_pitch.sh --cmd "$train_cmd" --nj 8 --write_utt2num_frames true \
            data/${rtask} exp/make_fbank/${rtask} ${fbankdir}
        utils/fix_data_dir.sh data/${rtask}
        feat_recog_dir=${dumpdir}/${rtask}/delta${do_delta}; mkdir -p ${feat_recog_dir}
        dump.sh --cmd "$train_cmd" --nj 8 --do_delta ${do_delta} \
            data/${rtask}/feats.scp data/${train_set}/cmvn.ark exp/dump_feats/recog/${rtask} \
            ${feat_recog_dir}
        feat_recog_dir=${dumpdir}/${rtask}/delta${do_delta}
        data2json.sh --feat ${feat_recog_dir}/feats.scp \
            data/${rtask} ${dict} > ${feat_recog_dir}/data.json
    done
done


for rtask in ${eval_set}; do
    feat_recog_dir=${dumpdir}/${rtask}/delta${do_delta}; mkdir -p ${feat_recog_dir}
    dump.sh --cmd "$train_cmd" --nj 8 --do_delta ${do_delta} \
        data/${rtask}/feats.scp data/${train_set}/cmvn.ark exp/dump_feats/recog/${rtask} \
        ${feat_recog_dir}
done

for rtask in ${eval_set}; do
    feat_recog_dir=${dumpdir}/${rtask}/delta${do_delta}
    data2json.sh --feat ${feat_recog_dir}/feats.scp \
        data/${rtask} ${dict} > ${feat_recog_dir}/data.json
done
