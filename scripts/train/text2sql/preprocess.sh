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

python preprocessing.py \
    --mode "train" \
    --table_path "./${dataset_dir}/spider/tables.json" \
    --input_dataset_path "./${dataset_dir}/spider/train_spider.json" \
    --output_dataset_path "./${dataset_dir}/preprocessed_data/preprocessed_train_spider.json" \
    --db_path "./${database_dir}" \
    --target_type "sql"

# preprocess dev dataset
python preprocessing.py \
    --mode "eval" \
    --table_path "./${dataset_dir}/spider/tables.json" \
    --input_dataset_path "./${dataset_dir}/spider/dev.json" \
    --output_dataset_path "./${dataset_dir}/preprocessed_data/preprocessed_dev.json" \
    --db_path "./${database_dir}"\
    --target_type "sql"