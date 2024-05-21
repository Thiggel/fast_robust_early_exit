# no early exit
python -m torch.distributed.run --nproc_per_node=1 \
    ../src/run_summarization.py \
    --model_name_or_path ../src/model_checkpoints/t5-large \
    --tokenizer_name t5-large \
    --do_eval \
    --dataset_name cnn_dailymail \
    --dataset_config_name "3.0.0" \
    --output_dir ../src/save/cnndm_t5_large/ \
    --deploy_scenario True \
    --use_synchronize True \
    --per_device_train_batch_size 2 \
    --per_device_eval_batch_size 2 \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "summarize: " \
    --num_train_epochs 10 \
    --output_hidden_states_decoder True \
    --use_early_exit False \
    --deploy_scenario False

# last_three_hiddens_classifier
python -m torch.distributed.run --nproc_per_node=1 \
    ../src/run_summarization.py \
    --model_name_or_path ../src/model_checkpoints/t5-large \
    --tokenizer_name t5-large \
    --do_eval \
    --dataset_name cnn_dailymail \
    --dataset_config_name "3.0.0" \
    --output_dir ../src/save/cnndm_t5_large/ \
    --deploy_scenario True \
    --use_synchronize True \
    --per_device_train_batch_size 32 \
    --per_device_eval_batch_size 32 \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "summarize: " \
    --num_train_epochs 10 \
    --output_hidden_states_decoder True \
    --use_early_exit True \
    --exit_conf_type last_three_hiddens_classifier \
    --exit_position_temp 4 \
    --do_train \
    --train_meta_cm_head \
    --num_train_epochs 5 \
    --deploy_scenario False
    
    
# meta
python -m torch.distributed.run --nproc_per_node=1 \
    ../src/run_summarization.py \
    --model_name_or_path ../src/model_checkpoints/t5-large \
    --tokenizer_name t5-large \
    --do_eval \
    --dataset_name cnn_dailymail \
    --dataset_config_name "3.0.0" \
    --output_dir ../src/save/cnndm_t5_large/ \
    --deploy_scenario True \
    --use_synchronize True \
    --per_device_train_batch_size 2 \
    --per_device_eval_batch_size 2 \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "summarize: " \
    --num_train_epochs 10 \
    --output_hidden_states_decoder True \
    --use_early_exit True \
    --exit_conf_type meta \
    --exit_position_temp 4 \
    --do_train \
    --train_meta_cm_head \
    --num_train_epochs 5 \
    --deploy_scenario False

# recurrent classifier
python -m torch.distributed.run --nproc_per_node=1 \
    ../src/run_summarization.py \
    --model_name_or_path ../src/model_checkpoints/t5-large \
    --tokenizer_name t5-large \
    --do_eval \
    --dataset_name cnn_dailymail \
    --dataset_config_name "3.0.0" \
    --output_dir ../src/save/cnndm_t5_large/ \
    --deploy_scenario True \
    --use_synchronize True \
    --per_device_train_batch_size 32 \
    --per_device_eval_batch_size 32 \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "summarize: " \
    --num_train_epochs 10 \
    --output_hidden_states_decoder True \
    --use_early_exit True \
    --exit_conf_type recurrent_classifier \
    --exit_position_temp 4 \
    --do_train \
    --train_meta_cm_head \
    --num_train_epochs 5 \
    --deploy_scenario False \
    --exit_conf_threshold 0.5

# softmax
python -m torch.distributed.run --nproc_per_node=1 \
    ../src/run_summarization.py \
    --model_name_or_path ../src/model_checkpoints/t5-large \
    --tokenizer_name t5-large \
    --do_eval \
    --dataset_name cnn_dailymail \
    --dataset_config_name "3.0.0" \
    --output_dir ../src/save/cnndm_t5_large/ \
    --deploy_scenario True \
    --use_synchronize True \
    --per_device_train_batch_size 2 \
    --per_device_eval_batch_size 2 \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "summarize: " \
    --num_train_epochs 10 \
    --output_hidden_states_decoder True \
    --use_early_exit True \
    --exit_conf_type softmax \
    --exit_position_temp 4 \
    --deploy_scenario False

# hidden_state_saturation
python -m torch.distributed.run --nproc_per_node=1 \
    ../src/run_summarization.py \
    --model_name_or_path ../src/model_checkpoints/t5-large \
    --tokenizer_name t5-large \
    --do_eval \
    --dataset_name cnn_dailymail \
    --dataset_config_name "3.0.0" \
    --output_dir ../src/save/cnndm_t5_large/ \
    --deploy_scenario True \
    --use_synchronize True \
    --per_device_train_batch_size 2 \
    --per_device_eval_batch_size 2 \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "summarize: " \
    --num_train_epochs 10 \
    --output_hidden_states_decoder True \
    --use_early_exit True \
    --exit_conf_type hidden_state_saturation \
    --exit_position_temp 4 \
    --deploy_scenario False

# last_three_top_prob_heuristic
python -m torch.distributed.run --nproc_per_node=1 \
    ../src/run_summarization.py \
    --model_name_or_path ../src/model_checkpoints/t5-large \
    --tokenizer_name t5-large \
    --do_eval \
    --dataset_name cnn_dailymail \
    --dataset_config_name "3.0.0" \
    --output_dir ../src/save/cnndm_t5_large/ \
    --deploy_scenario True \
    --use_synchronize True \
    --per_device_train_batch_size 2 \
    --per_device_eval_batch_size 2 \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "summarize: " \
    --num_train_epochs 10 \
    --output_hidden_states_decoder True \
    --use_early_exit True \
    --exit_conf_type last_three_top_prob_heuristic \
    --exit_position_temp 4 \
    --deploy_scenario False
