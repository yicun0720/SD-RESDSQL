set -e

device="0"

model_size=$1
ckpt_id=$2
benchmark=$3
train_target=$4

model_name="resdsql_$1"

if [ $model_size = "base" ]
then
    text2sql_model_bs=16
elif [ $model_size = "large" ]
then
    text2sql_model_bs=8
elif [ $model_size = "3b" ]
then
    text2sql_model_bs=6
else
    echo "The first arg must in [base, large, 3b]."
    exit
fi


if [ $train_target = "baseline" ]
then
    text2sql_model_save_path="./models/text2sql-t5-${model_size}_baseline/checkpoint-${ckpt_id}"
elif [ $train_target = "refined" ]
then
#    text2sql_model_save_path="./models/text2sql-t5-${model_size}_refined/checkpoint-${ckpt_id}"
    text2sql_model_save_path="/mnt/pj_nfs/yicun/models/text2sql-t5-3b_refined/checkpoint-133280/"
else
    echo "The forth arg must in [baseline, refined]."
    exit
fi

test_dataset_dir="data_refined"
test_database_dir="database_refined"
#test_test_suite_dir="test_suite_refined"
test_pred_dir="spider_train_${train_target}_test"


if [ $benchmark = "spider" ]
then
    # spider's test set
    table_path="./${test_dataset_dir}/spider/tables.json"
    input_dataset_path="./${test_dataset_dir}/spider/test.json"
    db_path="./${test_database_dir}"
#    test_suite_path="./${test_test_suite_dir}"
    output="./predictions/${test_pred_dir}/${model_name}/"
else
    echo "The third arg must in [spider], only support spider now."
    exit
fi

schema_item_classifier_model_save_path="./models/text2sql_schema_item_classifier_${train_target}"

# preprocess test set
python preprocessing.py \
    --mode "test" \
    --table_path $table_path \
    --input_dataset_path $input_dataset_path \
    --output_dataset_path "./${test_dataset_dir}/preprocessed_data/preprocessed_test.json" \
    --db_path $db_path \
    --target_type "sql"

# predict probability for each schema item
python schema_item_classifier.py \
    --batch_size 32 \
    --device $device \
    --seed 42 \
    --save_path $schema_item_classifier_model_save_path \
    --dev_filepath "./${test_dataset_dir}/preprocessed_data/preprocessed_test.json" \
    --output_filepath "./${test_dataset_dir}/preprocessed_data/test_with_probs.json" \
    --use_contents \
    --add_fk_info \
    --mode "test"

# generate text2sql test set
python text2sql_data_generator.py \
    --input_dataset_path "./${test_dataset_dir}/preprocessed_data/test_with_probs.json" \
    --output_dataset_path "./${test_dataset_dir}/preprocessed_data/resdsql_test.json" \
    --topk_table_num 4 \
    --topk_column_num 5 \
    --mode "test" \
    --use_contents \
    --add_fk_info \
    --output_skeleton \
    --target_type "sql"

# inference using the best text2sql ckpt
python text2sql.py \
    --batch_size $text2sql_model_bs \
    --device $device \
    --seed 42 \
    --save_path $text2sql_model_save_path \
    --mode "test" \
    --dev_filepath "./${test_dataset_dir}/preprocessed_data/resdsql_test.json" \
    --original_dev_filepath $input_dataset_path \
    --db_path $db_path \
    --num_beams 8 \
    --num_return_sequences 8 \
    --target_type "sql" \
    --output $output
