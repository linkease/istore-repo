# istore-repo
iStore的ipk仓库，存放已编译的ipk文件

# PR指南
## 原则
为节省仓库体积以及防止恶意软件：
1. 请勿提交OpenWRT官方仓库已经存在的包
2. 如果是开源软件请在PR信息中提供仓库地址
3. 如果是非开源软件请在PR信息中提供官方网站链接

## 流程
1. Fork本仓库，如果已经fork过则打开fork的仓库。
2. 切换到 `main` 分支
3. 同步上游仓库：点击 `Fetch upstream`，再点击 `Fetch and merge` 即可，这一步如有疑问请参考[官方文档](https://docs.github.com/en/github/collaborating-with-pull-requests/working-with-forks/syncing-a-fork#syncing-a-fork-from-the-web-ui) 
4. 创建PR用的临时分支：切换到 `main` 分支，点击分支下拉菜单，在输入框输入新分支的名称（也就是不存在的分支名称），例如 `add_app_jellyfin` ，搜索结果会变成 `Create branch: *** from 'main'` ，点这个搜索结果，稍等会自动创建并切换到新分支
5. 在新分支中进行更改，上传ipk文件。如果是更新一个包，不需要删除老版本ipk文件，只需上传新的ipk，合并时会自动清理老版本ipk文件
6. 完成以后提交PR，目标分支选择`pending`
7. 等PR合并以后，可以在 `branches` 页面删除临时分支，也可以保留临时分支，但是不要再进行变更和PR

注意：`main`分支是保护分支，任何人包括管理员都不能直接提交，必须通过其它分支发起PR来变更
