set -e

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

# train text2sql-t5-3b model
python -u text2sql.py \
    --batch_size 6 \
    --gradient_descent_step 16 \
    --device "0" \
    --learning_rate 5e-5 \
    --epochs 128 \
    --seed 42 \
#    --save_path "/mnt/pj_nfs/yicun/models/text2sql-t5-3b" \
    --save_path "./models/text2sql-t5-3b_${target}" \
#    --tensorboard_save_path "/mnt/pj_nfs/yicun/tensorboard_log/text2sql-t5-3b" \
    --tensorboard_save_path "./tensorboard_log/text2sql-t5-3b_${target}" \
    --model_name_or_path "t5-3b" \
    --use_adafactor \
    --mode train \
    --train_filepath "./${dataset_dir}/preprocessed_data/resdsql_train_spider.json"