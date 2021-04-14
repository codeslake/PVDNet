## Getting Started
1. Download and unzip [Su *et al.*'s dataset](https://www.dropbox.com/s/8daduee9igqx5cw/DVD.zip?dl=1) and [Nah *et al.*'s dataset](https://www.dropbox.com/s/5ese6qtbwy7fsoh/nah.zip?dl=1) under `[DATASET_ROOT]`:

    ```
    ├── [DATASET_ROOT]
    │   ├── train_DVD
    │   ├── test_DVD
    │   ├── train_nah
    │   ├── test_nah
    ```

2. Evaluation

    > **Note:**
    >
    > * Specify `test_offset`, which should be `[DATASET_ROOT]`.
    > * Specify `result_root`, which should be `[LOG_ROOT]/PVDNet_TOG2021`.

    * Option 1.
        * Run `eval_notebook` in the matlab GUI.
        
    * Option 2.
        * Type `run_evaluation` in the matlab console.

