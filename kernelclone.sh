git clone https://github.com/LineageOS/android_kernel_qcom_msm8998 -b lineage-18.0 kernel
cd kernel 
git branch -M master
git remote set-url origin https://ramadhannangga:$GH_TOKEN@github.com/ramadhannangga/android_kernel_qcom_sdm660.git
git push --force origin master
