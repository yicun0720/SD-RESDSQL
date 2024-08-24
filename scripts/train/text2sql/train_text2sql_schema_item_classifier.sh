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

# train schema item classifiifier.py \
    --batch_size 16 \
    --gradient_descent_step 2 \
    --device "0" \
    --learning_rate 1e-5 \
    --gamma 2.0 \
    --alpha 0.75 \
    --epochs 128 \
    --patience 16 \
    --seed 42 \
    --save_path "./models/text2sql_schema_item_classifier_${target}" \
    --tensorboard_save_path "./tensorboard_log/text2sql_schema_item_classifier_${target}" \
    --train_filepath "./${dataset_dir}/preprocessed_data/preprocessed_train_spider.json" \
    --dev_filepath "./${dataset_dir}/preprocessed_data/preprocessed_dev.json" \
    --model_name_or_path "roberta-large" \
    --use_contents \
    --add_fk_info \
    --mode "train"