#!/bin/bash

# Copyright 2017 Johns Hopkins University (Shinji Watanabe)
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

. ./path.sh || exit 1;
. ./cmd.sh || exit 1;

train_set_ori=train_nodup
train_set=train_nodup_sp
train_dev=train_dev
wavefile_path="/home/geng17/nas02_home/Dataset/nuct/"

clean_text_mode=True
# recog_set=$(ls -d "data/sp20161013refined_evalset_clean_${clean_text_mode}"* | sed 's/data\///')
# recog_set=$(ls -d "data/NUCT講習会オンデマンド教材"*"_clean_"${clean_text_mode} | sed 's/data\///')
# recog_set="new_eval_1 new_eval_2 new_eval_3"
recog_set="eval1"
# recog_set="iis20160517"
# recog_set="iis20160531 iis20160607 iis20160614 sp20161006 sp20161013 sp20161222 sp20170110 sp20170112"


mfccdir=mfcc
# Uncomment and modify arguments in scripts below if you have any problems with data sorting
# utils/validate_data_dir.sh data/${recog_set}     # script for checking prepared data - here: for data/train directory
# utils/fix_data_dir.sh data/${recog_set}          # tool for data proper sorting if needed - here: for 
 
for x in ${recog_set}; do
  # utils/fix_data_dir.sh data/$x
  # steps/make_mfcc.sh --cmd "$train_cmd" --nj 1 data/$x exp/make_mfcc/$x $mfccdir
  # ../../../tools/kaldi/egs/sre08/v1/sid/compute_vad_decision.sh --nj 1 --cmd "$train_cmd" data/$x exp/make_mfcc/$x $mfccdir

  # ../../../tools/kaldi/egs/sre08/v1/sid/train_diag_ubm.sh --nj 4 --cmd "$train_cmd" --num-threads 4 \
  # data/${x} 512 exp/diag_ubm_512
 
# train full ubm
  # ../../../tools/kaldi/egs/sre08/v1/sid/train_full_ubm.sh --nj 4 --cmd "$train_cmd" data/${x} \
  # exp/diag_ubm_512 exp/full_ubm_512
 
# #train ivector
  # ../../../tools/kaldi/egs/sre08/v1/sid/train_ivector_extractor.sh --nj 2 --cmd "$train_cmd --mem 10G" \
  # --num-iters 5 exp/full_ubm_512/final.ubm data/${x} \
  # exp/extractor_512
 
#extract ivector
  ../../../tools/kaldi/egs/sre08/v1/sid/extract_ivectors.sh --cmd "$train_cmd" --nj 1 \
  exp/extractor_512 data/${x} exp/ivector_${x}_512
done
