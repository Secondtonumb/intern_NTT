#!/bin/bash

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;

wavefile_path="/home/geng17/nas02_home/Dataset/LDNU_eval2/"
recog_set=$(ls $wavefile_path | sed 's/.wav//')
srtfile_path="/home/geng17/nas02_home/Dataset/srt/"
dumpdir=dump
do_delta=false
train_set=train_nodup_sp
dict=data/lang_1char/${train_set}_units.txt
speaker=Toda
clean_text_mode=False
sets=1
utts=100

fbankdir=fbank
for x in ${recog_set}; do
    echo $x
    mkdir -p data/${x}
    for ((i = 0; i < ${sets}; i++)); do
        mkdir -p data/${x}_evalset_clean_${clean_text_mode}_${i}
    done
    # pickle srt file
    # python local/pickle_srt.py \
    #     --input_file "${srtfile_path}/${x}.srt" \
    #     --output_file "data/${x}/pickle" \
    #     --wavefile_id "${x}" \
    #     --I_mode "1" \
    #     --S_mode "2" \
    #     --D_mode "1" \
    #     --remove_punctuation True\
    #     --remove_space True

    # # generate wav.scp, segments, text(blank) from pickle file    
    # python local/read_pickle_and_generate_eval_set.py \
    #     --input_file "data/${x}/pickle" \
    #     --wavefile_id "${x}" \
    #     --clean_text_mode ${clean_text_mode} \
    #     --use_all_utts True \
    #     --sets ${sets} \
    #     --utts ${utts} \
    #     --speaker ${speaker}
    eval_set=$(ls -d "data/${x}_clean_${clean_text_mode}"* | sed 's/data\///')
    for rtask in ${eval_set}; do
        echo "${x} cat ${wavefile_path}/${x}.wav |" > "data/${rtask}/wav.scp"
        for file in "segments" "text" "utt2spk"; do
            sort -o "data/${rtask}/$file" "data/${rtask}/$file"
        done
        utils/utt2spk_to_spk2utt.pl data/${rtask}/utt2spk > data/${rtask}/spk2utt
        steps/make_fbank_pitch.sh --cmd "$train_cmd" --nj 10 --write_utt2num_frames true \
            data/${rtask} exp/make_fbank/${rtask} ${fbankdir}
        utils/fix_data_dir.sh data/${rtask}
        feat_recog_dir=${dumpdir}/${rtask}/delta${do_delta}; mkdir -p ${feat_recog_dir}
        dump.sh --cmd "$train_cmd" --nj 4 --do_delta ${do_delta} \
            data/${rtask}/feats.scp data/${train_set}/cmvn.ark exp/dump_feats/recog/${rtask} \
            ${feat_recog_dir}
        feat_recog_dir=${dumpdir}/${rtask}/delta${do_delta}
        data2json.sh --feat ${feat_recog_dir}/feats.scp \
            data/${rtask} ${dict} > ${feat_recog_dir}/data.json
    done
done


# for rtask in ${eval_set}; do
#     feat_recog_dir=${dumpdir}/${rtask}/delta${do_delta}; mkdir -p ${feat_recog_dir}
#     dump.sh --cmd "$train_cmd" --nj 4 --do_delta ${do_delta} \
#         data/${rtask}/feats.scp data/${train_set}/cmvn.ark exp/dump_feats/recog/${rtask} \
#         ${feat_recog_dir}
# done

# for rtask in ${eval_set}; do
#     feat_recog_dir=${dumpdir}/${rtask}/delta${do_delta}
#     data2json.sh --feat ${feat_recog_dir}/feats.scp \
#         data/${rtask} ${dict} > ${feat_recog_dir}/data.json
# done
