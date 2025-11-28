# 大道一念 基于MoonBit与Selene开发的类幸存者游戏【2025MGPIC】

这里是《大道一念》项目的全部源码以及素材。

音乐素材使用Suno AI生成并做了些许裁剪，美术素材来自 https://assetstore.unity.com/packages/2d/undead-survivor-assets-pack-238068

本项目基于Selene 0.17.1开发，采用js作为后端，需要在moon.mod.json中添加

```
"preferred-target": "js"//注意，上传的源码中已有该条目
```

要编译项目，请使用

```
moon build
```

编译完成后，使用python创建服务器预览，前提是需要在电脑上预先安装python环境

```
python -m http.server 8080
```
