#!/bin/bash

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;

wavefile_path="/home/geng17/nas02_home/Dataset/LDNU_eval/"
recog_set=$(ls $wavefile_path | sed 's/.wav//')
dumpdir=dump
do_delta=false
train_set=train_nodup_sp
dict=data/lang_1char/${train_set}_units.txt
 
for x in ${recog_set}; do
    mkdir -p data/${x}
    # generate wav.scp, segments, text(blank)
    python local/generate_wavefile_segments.py \
        --wavefile_path ${wavefile_path} \
        --target_path 'data/' \
        --speaker 'TODA' 
    # utt2spk to spk2utt
    utils/utt2spk_to_spk2utt.pl data/${x}/utt2spk > data/${x}/spk2utt
done

fbankdir=fbank

for x in ${recog_set}; do
    steps/make_fbank_pitch.sh --cmd "$train_cmd" --nj 10 --write_utt2num_frames true \
        data/${x} exp/make_fbank/${x} ${fbankdir}
    utils/fix_data_dir.sh data/${x}
done

for rtask in ${recog_set}; do
    feat_recog_dir=${dumpdir}/${rtask}/delta${do_delta}; mkdir -p ${feat_recog_dir}
    dump.sh --cmd "$train_cmd" --nj 4 --do_delta ${do_delta} \
        data/${rtask}/feats.scp data/${train_set}/cmvn.ark exp/dump_feats/recog/${rtask} \
        ${feat_recog_dir}
done

for rtask in ${recog_set}; do
    feat_recog_dir=${dumpdir}/${rtask}/delta${do_delta}
    data2json.sh --feat ${feat_recog_dir}/feats.scp \
        data/${rtask} ${dict} > ${feat_recog_dir}/data.json
done