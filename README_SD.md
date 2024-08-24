# RESDSQL: Decoupling Schema Linking and Skeleton Parsing for Text-to-SQL
This README is used to guide the evaluation of SQLDriller project.

## Prerequisites
Follow the same instructions in the `Prerequisites` section of `README.md` to create a running environment.

After that, append the following code after line 441 of `./third_party/spider/evaluation.py`, 
and line 606 of `./third_party/test_suite/evaluation.py`:
```python
if not os.path.exists(db_path):
    db_path = os.path.join(self.db_dir, db_name, db_name + "_0.sqlite")
```

## Prepare data
Download [data](todo) and [database](todo) and then unzip them:
```sh
unzip data_refined.zip
unzip database_refined.zip
unzip test_suite_refined.zip
```

## Reproduce on Spider
### Re-fine-tuning model
#### Use the optimized dataset:
```sh
# Step1: preprocess dataset
sh scripts/train/text2sql/preprocess.sh refined
# Step2: train cross-encoder 
sh scripts/train/text2sql/train_text2sql_schema_item_classifier.sh refined
# Step3: prepare text-to-sql training and development set for T5
sh scripts/train/text2sql/generate_text2sql_dataset.sh refined
# Step4: fine-tune T5-3B (RESDSQL-3B)
sh scripts/train/text2sql/train_text2sql_t5_3b.sh refined
# Step5: 
sh scripts/train/text2sql/evaluate_text2sql_ckpts.sh refined
```

After running Step5, the terminal outputs the id of the checkpoint with the highest validated accuracy, 
marked as `ckpt_id` in this document (for example, `ckpt_id`=106624).

#### Use the original dataset:
By default, you can directly download the prepared checkpoints of models trained by the original dataset 
with the link provided in the RESDSQL's `README.md`:

| Cross-encoder Checkpoints | Google Drive | Baidu Netdisk |
|----------|-----------|--------------|
| text2sql_schema_item_classifier | [Link](https://drive.google.com/file/d/1zHAhECq1uGPR9Rt1EDsTai1LbRx0jYIo/view?usp=share_link) | [Link](https://pan.baidu.com/s/1trSi8OBOcPo5NkZb_o-T4g) (pwd: dr62) |

| T5 Checkpoints | Google Drive/OneDrive | Baidu Netdisk |
|-------|-------|-------|
| text2sql-t5-3b | [Google Drive link](https://drive.google.com/file/d/1M-zVeB6TKrvcIzaH8vHBIKeWqPn95i11/view?usp=sharing) | [Link](https://pan.baidu.com/s/1mZxakfes4wRSEwnRW43i5A) (pwd: sc62) |
remember to download to the path `./models` and rename the folders as follows:
```sh
mv ./models/text2sql_schema_item_classifier ./models/text2sql_schema_item_classifier_baseline
mv ./models/text2sql_t5-3b ./models/text2sql_t5-3b_baseline
```

If you want to reproduce results of fine-tuning model on the original dataset, 
replace the parameter `refined` to `baseline` and just run the same commands from Step1 to Step5 mentioned above. 

Finally, the output models are stored in the following folders:
- `./models/text2sql_schema_item_classifier_{baseline/refined}/` 
- `./models/text2sql_t5-3b_{baseline/refined}/`

### Inference
Inference using the model fine-tuned by **original** train dataset on **original** dev dataset:
```sh
sh scripts/inference/infer_text2sql.sh 3b {baseline model ckpt_id} spider baseline baseline
```
Inference using the model fine-tuned by **original** train dataset on **optimized** dev dataset:
```sh
sh scripts/inference/infer_text2sql.sh 3b {baseline model ckpt_id} spider baseline refined
```
Inference using the model fine-tuned by **optimized** train dataset on **optimized** dev dataset:
```sh
sh scripts/inference/infer_text2sql.sh 3b {refined model ckpt_id} spider refined refined
```

The inference SQL results is stored in `./predictions/spider_train_{baseline/refined}_dev_{baseline/refined}/resdsql_3b`, 
in which:
- `preds.sql` logs the SQL prediction of each Text-to-SQL case.
- `all_preds.sql` logs the multiple SQL predictions RESDSQL generates when inferring each Text-to-SQL case.

Copy the files back to the corresponding paths in SQLDriller project to perform accuracy evaluations:
- `./predictions/spider_train_baseline_dev_baseline/resdsql_3b/preds.sql` to [todo]
- `./predictions/spider_train_baseline_dev_refined/resdsql_3b/preds.sql` to [todo]
- `./predictions/spider_train_refined_dev_refined/resdsql_3b/preds.sql` 
and `./predictions/spider_train_refined_dev_refined/resdsql_3b/all_preds.sql` to [todo]
