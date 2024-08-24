set -e

target=$1

if [ $target = "baseline" ]
then
    dataset_dir="data"
    database_dir="database"
elif [ $target = "refined" ]
then
    dataset_dir="data_refined"
    database_dir="database_refined"
else
    echo "The first arg must in [baseline, refined]."
    exit
fi

# generate text2sql training dataset with noise_rate 0.2
python text2sql_data_generator.py \
    --input_dataset_path "./${dataset_dir}/preprocessed_data/preprocessed_train_spider.json" \
    --output_dataset_path "./${dataset_dir}/preprocessed_data/resdsql_train_spider.json" \
    --topk_table_num 4 \
    --topk_column_num 5 \
    --mode "train" \
    --noise_rate 0.2 \
    --use_contents \
    --add_fk_info \
    --output_skeleton \
    --target_type "sql"

# predict probability for each schema item in the eval set
python schema_item_classifier.py \
    --batch_size 32 \
    --device "0" \
    --seed 42 \
    --save_path "./models/text2sql_schema_item_classifier_${target}" \
    --dev_filepath "./${dataset_dir}/preprocessed_data/preprocessed_dev.json" \
    --output_filepath "./${dataset_dir}/preprocessed_data/dev_with_probs.json" \
    --use_contents \
    --add_fk_info \
    --mode "eval"

# generate text2sql development dataset
python text2sql_data_generator.py \
    --input_dataset_path "./${dataset_dir}/preprocessed_data/dev_with_probs.json" \
    --output_dataset_path "./${dataset_dir}/preprocessed_data/resdsql_dev.json" \
    --topk_table_num 4 \
    --topk_column_num 5 \
    --mode "eval" \
    --use_contents \
    --add_fk_info \
    --output_skeleton \
    --target_type "sql"