set -e

target=$1
start_id=$2
end_id=$3

if [ $target = "baseline" ]
then
    dataset_dir="data"
    database_dir="database"
    test_suite_dir="test_suite"
    pred_dir="spider_train_baseline_dev_baseline"
elif [ $target = "refined" ]
then
    dataset_dir="data_refined"
    database_dir="database_refined"
    test_suite_dir="test_suite_refined"
    pred_dir="spider_train_refined_dev_refined"
else
    echo "The first arg must in [baseline, refined]."
    exit
fi

if [ -z "$2" ];
then
    start_id=-1
    end_id=-1
else
    start_id=$2
    end_id=$3
fi

python -u evaluate_text2sql_ckpts.py \
    --batch_size 2 \
    --device "0" \
    --seed 42 \
#    --save_path "/mnt/pj_nfs/yicun/models/text2sql-t5-3b" \
    --save_path "./models/text2sql-t5-3b_${target}" \
    --eval_results_path "./eval_results/text2sql-t5-3b_${target}" \
    --mode "eval" \
    --dev_filepath "./${dataset_dir}/preprocessed_data/resdsql_dev.json" \
    --original_dev_filepath "./${dataset_dir}/spider/dev.json" \
    --db_path "./${test_suite_dir}" \
    --num_beams 8 \
    --num_return_sequences 8 \
    --target_type "sql" \
    --output "./predictions/${pred_dir}/resdsql_3b/" \
    --start_id $start_id \
    --end_id $end_id