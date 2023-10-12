#!/bin/bash

cur_path=`pwd`
cur_path_last_dirname=${cur_path##*/}
if [ x"${cur_path_last_dirname}" == x"scripts" ];then
    scripts_path_dir=${cur_path}
    cd ..
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
nohup python3 -m torch.distributed.run --nproc_per_node 8 train_t2i_adapter_sdxl.py \
  --pretrained_model_name_or_path stabilityai/stable-diffusion-xl-base-1.0 \
  --dataset_name fusing/fill50k \
  --mixed_precision "fp16" \
  --resolution 1024 \
  --learning_rate 1e-5 \
  --max_train_steps 15000 \
  --validation_image "./conditioning_image_1.png" "./conditioning_image_2.png" \
  --validation_prompt "red circle with blue background" "cyan circle with brown floral background" \
  --validation_steps 100 \
  --train_batch_size 1 \
  --gradient_accumulation_steps 4 \
  --seed=42 \
  --output_dir ./output_t2i_adapter_sdxl > ${scripts_path_dir}/output_t2i_adapter_sdxl/run_t2i_adapter_sdxl.log 2>&1 &
wait
end_time=$(date +%s)
e2e_time=$(( $end_time - $start_time ))

# 打印端到端训练时间
echo "E2E Training Duration sec : $e2e_time"