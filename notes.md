pip3 install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt

### 问题：
1. 运行图像生成测试dag的时候，dry run模式下，完成后输出文件到/outputs。真实模式下，不自动下载文件，传出prompt后，成功调用api没有任何问题后，轮询到该图片生成的任务，过程中如果报错，可休眠后继续轮训，知道成功或超时，超时时间设置为20mins，此dag就可以结束。真实模式下，如果调用api失败，直接使整个dag失败，不要创建占位符文件，也不要创建空的png文件。如果dag超时，此条prompt不需要回退到pending，只需要增加一个手动重试功能，将该dag放到待重试状态下，手动触发重试后，重新轮询该prompt对应的谷歌生成任务的状态，如果成功就返回成功，如果报错就显示失败并输出错误信息。总之核心思想：生成图像一个单独dag，下载一个dag，相互不影响。生成图像的dag只负责生成，确保生成成功并储存在google的桶里。
2. 通过download_workflow下载所有生成但没有下载的文件。在 dry_run 模式下生成的占位符文件（如 ..._image_test_dry_run.txt）并不符合这个清理规则，因此不会被这个特定的清理任务删除。 这里逻辑需要改，占位符文件超过24小时都进行清理。png文件不需要清理。
3. 生产环境的video生产dag也按照上述逻辑，请你检查代码并做需求修改。
把我以上所有需求按你的理解复述给我，可以添加你认为必要的细节，确保我们的需求认知对齐。

### 新问题：
1. 中间状态的dag（图像和视频生成），5mins后自动重试。
2. prompt需要用用户真实传的prompt，不要写死成默认值。