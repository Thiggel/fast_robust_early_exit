. jobs/environment.sh

# no early exit
python -m torch.distributed.run --nproc_per_node=1 \
    src/run_translation.py \
    --model_name_or_path checkpoints/IWSLT \
    --tokenizer_name t5-large \
    --do_eval \
    --dataset_name iwslt2017 \
    --dataset_config_name iwslt2017-de-en \
    --output_dir ./save/iwslt_t5_large/ \
    --per_device_eval_batch_size 32 \
    --deploy_scenario false \
    --use_synchronize true \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "translate german to english: " \
    --output_hidden_states_decoder true \
    --use_early_exit false \
    --dataloader_drop_last True \
    --source_lang "de" \
    --target_lang "en"

# normal classifier
python -m torch.distributed.run --nproc_per_node=1 \
    src/run_translation.py \
    --model_name_or_path checkpoints/IWSLT \
    --tokenizer_name t5-large \
    --do_eval \
    --do_train \
    --dataset_name iwslt2017 \
    --dataset_config_name iwslt2017-de-en \
    --output_dir ./save/iwslt_t5_large/ \
    --per_device_eval_batch_size 32 \
    --per_device_train_batch_size 4 \
    --deploy_scenario false \
    --use_synchronize true \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "translate german to english: " \
    --output_hidden_states_decoder true \
    --use_early_exit true \
    --source_lang "de" \
    --target_lang "en" \
    --exit_conf_type meta \
    --exit_position_temp 4 \
    --train_meta_cm_head \
    --exit_conf_threshold 0.7 \
    --num_train_epochs 5 \
    --dataloader_drop_last True \
    --max_train_samples 10000

# Last Three Hidden States Classifier
python -m torch.distributed.run --nproc_per_node=1 \
    src/run_translation.py \
    --model_name_or_path checkpoints/IWSLT \
    --tokenizer_name t5-large \
    --do_eval \
    --do_train \
    --dataset_name iwslt2017 \
    --dataset_config_name iwslt2017-de-en \
    --output_dir ./save/iwslt_t5_large/ \
    --per_device_eval_batch_size 32 \
    --per_device_train_batch_size 4 \
    --deploy_scenario False \
    --use_synchronize True \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "translate German to English: " \
    --output_hidden_states_decoder True \
    --use_early_exit True \
    --source_lang "de" \
    --target_lang "en" \
    --exit_conf_type last_three_hiddens_classifier \
    --exit_position_temp 4 \
    --train_meta_cm_head \
    --exit_conf_threshold 0.7 \
    --num_train_epochs 5 \
    --dataloader_drop_last True \
    --max_train_samples 10000


# Recurrent Classifier
python -m torch.distributed.run --nproc_per_node=1 \
    src/run_translation.py \
    --model_name_or_path checkpoints/IWSLT \
    --tokenizer_name t5-large \
    --do_eval \
    --do_train \
    --dataset_name iwslt2017 \
    --dataset_config_name iwslt2017-de-en \
    --output_dir ./save/iwslt_t5_large/ \
    --per_device_eval_batch_size 32 \
    --per_device_train_batch_size 4 \
    --deploy_scenario False \
    --use_synchronize True \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "translate German to English: " \
    --output_hidden_states_decoder True \
    --use_early_exit True \
    --source_lang "de" \
    --target_lang "en" \
    --exit_conf_type recurrent_classifier \
    --exit_position_temp 4 \
    --train_meta_cm_head \
    --exit_conf_threshold 0.7 \
    --num_train_epochs 5 \
    --dataloader_drop_last True \
    --max_train_samples 10000


# Softmax Heuristic
python -m torch.distributed.run --nproc_per_node=1 \
    src/run_translation.py \
    --model_name_or_path checkpoints/IWSLT \
    --tokenizer_name t5-large \
    --do_eval \
    --dataset_name iwslt2017 \
    --dataset_config_name iwslt2017-de-en \
    --output_dir ./save/iwslt_t5_large/ \
    --per_device_eval_batch_size 32 \
    --per_device_train_batch_size 4 \
    --deploy_scenario False \
    --use_synchronize True \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "translate German to English: " \
    --output_hidden_states_decoder True \
    --use_early_exit True \
    --source_lang "de" \
    --target_lang "en" \
    --exit_conf_type softmax \
    --exit_conf_threshold 0.7 \
    --dataloader_drop_last True \
    --exit_position_temp 4

# Hidden State Saturation Heuristic
python -m torch.distributed.run --nproc_per_node=1 \
    src/run_translation.py \
    --model_name_or_path checkpoints/IWSLT \
    --tokenizer_name t5-large \
    --do_eval \
    --dataset_name iwslt2017 \
    --dataset_config_name iwslt2017-de-en \
    --output_dir ./save/iwslt_t5_large/ \
    --per_device_eval_batch_size 32 \
    --per_device_train_batch_size 4 \
    --deploy_scenario False \
    --use_synchronize True \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "translate German to English: " \
    --output_hidden_states_decoder True \
    --use_early_exit True \
    --source_lang "de" \
    --target_lang "en" \
    --exit_conf_type hidden_state_saturation \
    --exit_conf_threshold 0.7 \
    --dataloader_drop_last True \
    --exit_position_temp 4

# Last Three Top Probabilities Heuristic
python -m torch.distributed.run --nproc_per_node=1 \
    src/run_translation.py \
    --model_name_or_path checkpoints/IWSLT \
    --tokenizer_name t5-large \
    --do_eval \
    --dataset_name iwslt2017 \
    --dataset_config_name iwslt2017-de-en \
    --output_dir ./save/iwslt_t5_large/ \
    --per_device_eval_batch_size 32 \
    --per_device_train_batch_size 4 \
    --deploy_scenario False \
    --use_synchronize True \
    --overwrite_output_dir \
    --predict_with_generate \
    --source_prefix "translate German to English: " \
    --output_hidden_states_decoder True \
    --use_early_exit True \
    --source_lang "de" \
    --target_lang "en" \
    --exit_conf_type last_three_top_prob_heuristic \
    --exit_conf_threshold 0.7 \
    --dataloader_drop_last True \
    --exit_position_temp 4
