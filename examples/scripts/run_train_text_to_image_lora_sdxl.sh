#!/bin/bash

cur_path=`pwd`
pretrained_model_name = ""
pretrained_model_name_path = ""

cur_path_last_dirname=${cur_path##*/}
if [ x"${cur_path_last_dirname}" == x"scripts" ];then
    scripts_path_dir=${cur_path}
    cd ../
    cur_path=`pwd`
else
    scripts_path_dir=${cur_path}/scripts
fi

#创建输出目录，不需要修改
if [ -d ${scripts_path_dir}/output ];then
    rm -rf ${scripts_path_dir}/output
    mkdir -p ${scripts_path_dir}/output
else
    mkdir -p ${scripts_path_dir}/output
fi

# 启动训练脚本
start_time=$(date +%s)
#nohup python3 -m torch.distributed.run --nproc_per_node 8 text_to_image/train_text_to_image_lora_sdxl.py \
  nohup python3 text_to_image/train_text_to_image_lora_sdxl.py \
  --pretrained_model_name_or_path {self.pretrained_model_name} \
  --dataset_name lambdalabs/pokemon-blip-captions \
  --caption_column "text" \
  --resolution 1024 \
  --random_flip \
  --train_batch_siz 1 \
  --num_train_epochs 1 \
  --checkpointing_steps 10 \
  --learning_rate 1e-04 \
  --lr_scheduler "constant" \
  --lr_warmup_steps 0 \
  --seed 42 \
  --train_text_encoder \
  --validation_prompt "cute dragon creature" \
  --overwrite_output_dir \
  --overwrite_output_dir \
  --output_dir ./output > ${scripts_path_dir}/output/${pretrained_model_name_path}/train_text_to_image_lora_sdxl.log 2>&1 &
wait
end_time=$(date +%s)
e2e_time=$(( $end_time - $start_time ))

# 打印端到端训练时间
echo "E2E Training Duration sec : $e2e_time"