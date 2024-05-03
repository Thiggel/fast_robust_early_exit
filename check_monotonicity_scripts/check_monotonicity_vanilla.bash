python3 run_summarization.py \
    --check_monotonicity \
    --model_name_or_path google/long-t5-tglobal-base \
    --do_predict \
    --dataset_name big_patent \
    --dataset_config_name e \
    --output_dir ./save/bigpatent_longt5_base/ \
    --per_device_train_batch_size 2 \
    --per_device_eval_batch_size 16 \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "summarize: " \
    --save_steps 2583 \
    --learning_rate 1e-4 \
    --max_source_length 2048 \
    --max_target_length 512
